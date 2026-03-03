import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/repositories/firebase_sync_repository.dart';
import 'src/repositories/local_snapshot_repository.dart';
import 'src/repositories/mock_recipe_repository.dart';
import 'src/services/app_state_persistence_manager.dart';
import 'src/services/firebase_sync_event_logger.dart';
import 'src/services/local_notification_service.dart';
import 'src/services/recommendation_automation_service.dart';
import 'src/services/recommendation_scheduler.dart';
import 'src/state/app_state.dart';
import 'src/state/auth_controller.dart';
import 'src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appState = AppState(
    recipeRepository: MockRecipeRepository(),
    scheduler: RecommendationScheduler(),
  );

  final localRepository = LocalSnapshotRepository();
  final persistenceManager = AppStatePersistenceManager(
    repository: localRepository,
  );
  await persistenceManager.hydrate(appState);
  await appState.bootstrap();
  persistenceManager.bindAutoSave(appState);

  final authController = AuthController(
    firebaseAuth: FirebaseAuth.instance,
    syncRepository: FirebaseSyncRepository(),
    syncEventLogger: FirebaseSyncEventLogger(),
  )..attachAppState(appState);
  await authController.bootstrap();

  final notificationService = LocalNotificationService();
  await notificationService.initialize();

  final automationService = RecommendationAutomationService(
    appState: appState,
    scheduler: RecommendationScheduler(),
    notificationService: notificationService,
  );
  await automationService.start();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        Provider<LocalNotificationService>.value(value: notificationService),
        Provider<RecommendationAutomationService>.value(
          value: automationService,
        ),
      ],
      child: const MinFridgeApp(),
    ),
  );
}
