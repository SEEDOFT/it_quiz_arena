import 'package:flutter/material.dart';
import 'package:it_quiz_arena/main.dart';
import 'package:it_quiz_arena/screens/login/login_screen.dart';
import 'package:it_quiz_arena/services/auth_service.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'This will permanently delete all your quiz history, scores, XP, and achievements. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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
          appBar: AppBar(
            title: const Text("Settings"),
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (auth.isAuthenticated) _buildUserSection(context, auth),
              const SizedBox(height: 24),
              _buildSettingCard(
                context,
                children: [
                  SwitchListTile(
                    value: settings.soundEnabled,
                    title: const Text("Sound"),
                    onChanged: _controller.updateSound,
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  SwitchListTile(
                    value: settings.musicEnabled,
                    title: const Text("Music"),
                    onChanged: _controller.updateMusic,
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  SwitchListTile(
                    value: settings.showExplanation,
                    title: const Text("Show Explanation"),
                    subtitle: const Text(
                      "Display explanation after wrong answer",
                    ),
                    onChanged: _controller.updateShowExplanation,
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
                  onPressed: _controller.saving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.saving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onSurface,
                          ),
                        )
                      : Text(
                          'Save Settings',
                          style: TextStyle(color: cs.onSurface),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _controller.resetting
                      ? null
                      : () => _confirmReset(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    onPressed: _handleLogout,
                    icon: Icon(Icons.logout, color: cs.error),
                    label: Text('Logout', style: TextStyle(color: cs.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
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
        onTap: () => _controller.updateTheme(label.toLowerCase()),
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
