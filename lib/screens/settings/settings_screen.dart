import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:it_quiz_arena/main.dart';
import 'package:it_quiz_arena/screens/login/login_screen.dart';
import 'package:it_quiz_arena/services/audio_service.dart';
import 'package:it_quiz_arena/services/auth_service.dart';
import 'package:it_quiz_arena/widgets/adaptive.dart';

import 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await _controller.save();
    AppThemeNotifier().setTheme(_controller.settings.themeMode);
    if (mounted) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) {
            Future.delayed(const Duration(seconds: 1), () {
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            });
            return const CupertinoAlertDialog(title: Text('Settings saved'));
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Reset Progress'),
              content: const Text(
                'This will permanently delete all your quiz history, scores, XP, and achievements. This cannot be undone.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    AudioService().playTap();
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          )
        : await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Reset Progress'),
              content: const Text(
                'This will permanently delete all your quiz history, scores, XP, and achievements. This cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    AudioService().playTap();
                    Navigator.pop(ctx, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    AudioService().playTap();
                    Navigator.pop(ctx, true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );

    if (confirmed == true && mounted) {
      await _controller.reset();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Progress has been reset')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = _controller.settings;
        final auth = AuthService();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: buildAdaptiveAppBar(title: "Settings", context: context),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (auth.isAuthenticated) _buildUserSection(context, auth),
              const SizedBox(height: 24),
              _buildSettingCard(
                context,
                children: [
                  ListTile(
                    title: const Text("Sound"),
                    trailing: buildAdaptiveSwitch(
                      value: settings.soundEnabled,
                      onChanged: (value) {
                        AudioService().playTap();
                        _controller.updateSound(value);
                      },
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  ListTile(
                    title: const Text("Show Explanation"),
                    subtitle: const Text(
                      "Display explanation after wrong answer",
                    ),
                    trailing: buildAdaptiveSwitch(
                      value: settings.showExplanation,
                      onChanged: (value) {
                        AudioService().playTap();
                        _controller.updateShowExplanation(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingCard(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme', style: TextStyle(color: cs.onSurface)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _themeOption(
                              context,
                              'System',
                              Icons.brightness_auto,
                              settings,
                            ),
                            const SizedBox(width: 6),
                            _themeOption(
                              context,
                              'Dark',
                              Icons.dark_mode,
                              settings,
                            ),
                            const SizedBox(width: 6),
                            _themeOption(
                              context,
                              'Light',
                              Icons.light_mode,
                              settings,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _controller.saving
                      ? null
                      : () {
                          AudioService().playTap();
                          _handleSave();
                        },
                  child: _controller.saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Settings'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _controller.resetting
                      ? null
                      : () {
                          AudioService().playTap();
                          _confirmReset(context);
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.error),
                    backgroundColor: cs.error.withValues(alpha: 0.15),
                    foregroundColor: cs.error,
                  ),
                  child: _controller.resetting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.error,
                          ),
                        )
                      : const Text('Reset Progress'),
                ),
              ),
              if (auth.isAuthenticated) ...[
                const SizedBox(height: 24),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AudioService().playTap();
                      _handleLogout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error),
                      foregroundColor: cs.error,
                      backgroundColor: cs.error.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSection(BuildContext context, AuthService auth) {
    final cs = Theme.of(context).colorScheme;
    final user = auth.user;
    final name = user?.name ?? 'Player';
    final email = user?.email ?? '';
    final rank = user?.currentRank ?? 'Beginner';
    final avatar = user?.avatar;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primary,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar != null
                ? null
                : Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(email, style: TextStyle(color: cs.outline, fontSize: 13)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rank,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _themeOption(
    BuildContext context,
    String label,
    IconData icon,
    settings,
  ) {
    final cs = Theme.of(context).colorScheme;
    final selected = settings.themeMode == label.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService().playTap();
          _controller.updateTheme(label.toLowerCase());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: cs.onSurface, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
