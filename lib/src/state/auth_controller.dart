import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repositories/sync_repository.dart';
import '../services/sync_event_logger.dart';
import 'app_state.dart';

enum MergeChoice { mergeByLatest, keepLocal, useCloud }

class MergePromptData {
  MergePromptData({
    required this.localUpdatedAt,
    required this.cloudUpdatedAt,
  });

  final DateTime localUpdatedAt;
  final DateTime cloudUpdatedAt;

  bool get isCloudNewer => cloudUpdatedAt.isAfter(localUpdatedAt);
}

class AuthController extends ChangeNotifier {
  AuthController({
    required FirebaseAuth firebaseAuth,
    required SyncRepository syncRepository,
    SyncEventLogger? syncEventLogger,
  })  : _firebaseAuth = firebaseAuth,
        _syncRepository = syncRepository,
        _syncEventLogger = syncEventLogger ?? NoopSyncEventLogger();

  final FirebaseAuth _firebaseAuth;
  final SyncRepository _syncRepository;
  final SyncEventLogger _syncEventLogger;

  AppState? _appState;
  StreamSubscription<User?>? _authSub;

  bool _isBusy = false;
  String? _lastError;
  MergePromptData? _pendingMergePrompt;

  bool get isBusy => _isBusy;
  String? get lastError => _lastError;
  bool get isLoggedIn => !(_firebaseAuth.currentUser?.isAnonymous ?? true);
  String get uid => _firebaseAuth.currentUser?.uid ?? 'guest-local-user';
  MergePromptData? get pendingMergePrompt => _pendingMergePrompt;

  void attachAppState(AppState appState) {
    _appState = appState;
  }

  Future<void> bootstrap() async {
    _authSub ??= _firebaseAuth.authStateChanges().listen((user) {
      final nextUid = user?.uid;
      if (nextUid != null) {
        _appState?.setUid(nextUid);
      }
      notifyListeners();
    });

    if (_firebaseAuth.currentUser == null) {
      await _firebaseAuth.signInAnonymously();
    } else {
      _appState?.setUid(_firebaseAuth.currentUser!.uid);
    }

    await _syncOnAppStart();
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _withBusy(() async {
      final current = _firebaseAuth.currentUser;
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (current != null && current.isAnonymous) {
        await current.linkWithCredential(credential);
      } else {
        await _firebaseAuth.signInWithCredential(credential);
      }

      await _handlePostLoginSync();
    });
  }

  Future<void> signInWithApple() async {
    await _withBusy(() async {
      final provider = AppleAuthProvider();
      final current = _firebaseAuth.currentUser;
      if (current != null && current.isAnonymous) {
        await current.linkWithProvider(provider);
      } else {
        await _firebaseAuth.signInWithProvider(provider);
      }
      await _handlePostLoginSync();
    });
  }

  Future<void> signOutToGuest() async {
    await _withBusy(() async {
      await _firebaseAuth.signOut();
      await _firebaseAuth.signInAnonymously();
      _pendingMergePrompt = null;
      await _syncOnAppStart();
    });
  }

  Future<void> resolvePendingMerge(MergeChoice choice) async {
    final appState = _appState;
    if (appState == null) {
      return;
    }
    final current = _firebaseAuth.currentUser;
    if (current == null) {
      return;
    }

    final currentUid = current.uid;
    final local = appState.exportSnapshot();

    await _withBusy(() async {
      if (choice == MergeChoice.mergeByLatest) {
        final report = await _syncRepository.mergeByLatest(currentUid, local);
        await _syncEventLogger.logMergeResult(
          uid: currentUid,
          source: 'manual_merge_latest',
          report: report,
        );
      }
      if (choice == MergeChoice.keepLocal) {
        await _syncRepository.uploadLocalSnapshot(
          currentUid,
          local,
          overwrite: true,
        );
      }

      final remote = await _syncRepository.downloadSnapshot(currentUid);
      if (remote != null) {
        appState.replaceFromSnapshot(remote);
      }

      _pendingMergePrompt = null;
    });
  }

  Future<void> _syncOnAppStart() async {
    final appState = _appState;
    final user = _firebaseAuth.currentUser;
    if (appState == null || user == null) {
      return;
    }

    final currentUid = user.uid;
    appState.setUid(currentUid);

    try {
      final local = appState.exportSnapshot();
      final cloud = await _syncRepository.downloadSnapshot(currentUid);

      if (cloud == null) {
        await _syncRepository.uploadLocalSnapshot(
          currentUid,
          local,
          overwrite: true,
        );
        await _syncEventLogger.logAppStartSync(
          uid: currentUid,
          action: 'push_local_initial',
        );
        return;
      }

      if (cloud.updatedAt.isAfter(local.updatedAt)) {
        appState.replaceFromSnapshot(cloud);
        await _syncEventLogger.logAppStartSync(
          uid: currentUid,
          action: 'pull_cloud_newer',
        );
        return;
      }

      if (local.updatedAt.isAfter(cloud.updatedAt)) {
        await _syncRepository.uploadLocalSnapshot(
          currentUid,
          local,
          overwrite: true,
        );
        await _syncEventLogger.logAppStartSync(
          uid: currentUid,
          action: 'push_local_newer',
        );
        return;
      }

      await _syncEventLogger.logAppStartSync(
        uid: currentUid,
        action: 'no_change',
      );
    } catch (e) {
      _lastError = e.toString();
      await _syncEventLogger.logSyncError(
        uid: currentUid,
        stage: 'app_start_sync',
        error: e.toString(),
      );
    }
  }

  Future<void> _handlePostLoginSync() async {
    final appState = _appState;
    final user = _firebaseAuth.currentUser;
    if (appState == null || user == null) {
      return;
    }

    final currentUid = user.uid;
    appState.setUid(currentUid);

    final hasCloudData = await _syncRepository.hasCloudData(currentUid);
    final local = appState.exportSnapshot();

    if (!hasCloudData) {
      await _syncRepository.uploadLocalSnapshot(currentUid, local, overwrite: true);
      _pendingMergePrompt = null;
      return;
    }

    final cloudUpdatedAt = await _syncRepository.getCloudLastUpdatedAt(currentUid) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    _pendingMergePrompt = MergePromptData(
      localUpdatedAt: local.updatedAt,
      cloudUpdatedAt: cloudUpdatedAt,
    );
  }

  Future<void> _withBusy(Future<void> Function() task) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();
    try {
      await task();
    } on FirebaseAuthException catch (e) {
      _lastError = e.message ?? e.code;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
