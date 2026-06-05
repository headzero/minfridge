import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/auth_controller.dart';
import 'dialogs.dart';
import 'widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = Provider.of<AuthController?>(context);
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);

    final shortUid = state.uid.length > 14 ? '${state.uid.substring(0, 12)}…' : state.uid;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ScreenTitle(title: '설정'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              children: <Widget>[
                _Group(
                  title: '계정',
                  children: <Widget>[
                    _Row(
                      icon: Icons.person_outline,
                      title: auth?.isLoggedIn == true ? '회원으로 사용 중' : '비회원으로 사용 중',
                      subtitle: 'UID · $shortUid',
                    ),
                    if (auth != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: auth.isBusy ? null : () => _login(context, auth, google: true),
                                    icon: const Text('G', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                                    label: const Text('Google'),
                                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: auth.isBusy ? null : () => _login(context, auth, google: false),
                                    icon: const Icon(Icons.apple, size: 17),
                                    label: const Text('Apple'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: scheme.onSurface,
                                      foregroundColor: scheme.surface,
                                      minimumSize: const Size(0, 44),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (auth.isLoggedIn) ...<Widget>[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: auth.isBusy ? null : auth.signOutToGuest,
                                child: const Text('비회원으로 전환'),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              auth.lastError != null
                                  ? '오류: ${auth.lastError}'
                                  : '로그인 시 기존 비회원 데이터는 계정에 연결돼요. 클라우드에 데이터가 있으면 병합 방식을 물어봐요.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: auth.lastError != null ? mf.urgent.main : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                _Group(
                  title: '알림',
                  children: <Widget>[
                    _Row(
                      icon: Icons.notifications_active_outlined,
                      title: '오늘의 추천 알림',
                      subtitle: '매일 오전 7시',
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                  ],
                ),
                _Group(
                  title: '활동',
                  children: <Widget>[
                    _Row(
                      icon: Icons.favorite_border,
                      iconColor: mf.fresh.main,
                      title: '최근 7일 좋아요 비율',
                      trailing: Text(
                        '${(state.recent7DayLikeRatio * 100).round()}%',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: mf.fresh.main),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context, AuthController auth, {required bool google}) async {
    if (google) {
      await auth.signInWithGoogle();
    } else {
      await auth.signInWithApple();
    }
    if (!context.mounted) return;
    final prompt = auth.pendingMergePrompt;
    if (prompt == null) return;
    final choice = await showMergeDialog(context, prompt);
    if (choice != null) {
      await auth.resolvePendingMerge(choice);
    }
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(title, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: scheme.onSurfaceVariant)),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: mf.lineSoft),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, this.subtitle, this.trailing, this.iconColor});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mf = mfColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: mf.sunken, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor ?? scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: scheme.onSurface)),
                if (subtitle != null)
                  Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
