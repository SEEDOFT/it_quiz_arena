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
      ).showSnackBar(const SnackBar(content: Text('Settings Saved')));
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: const Text("Settings"),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (auth.isAuthenticated) _buildUserSection(context, auth),
              const SizedBox(height: 24),
              Text(
                'Game Settings',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Difficulty',
                          style: TextStyle(color: cs.onSurface),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: ['Beginner', 'Intermediate', 'Advanced']
                              .map(
                                (d) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _controller.updateDifficulty(d),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: settings.difficulty == d
                                              ? cs.primary
                                              : cs.surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          d,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontSize: 12,
                                            fontWeight: settings.difficulty == d
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Questions per game',
                              style: TextStyle(color: cs.onSurface),
                            ),
                            Text(
                              '${settings.questionCount}',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 5,
                          max: 50,
                          divisions: 9,
                          value: settings.questionCount.toDouble(),
                          label: settings.questionCount.toString(),
                          onChanged: (value) =>
                              _controller.updateQuestionCount(value.toInt()),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time per question (s)',
                              style: TextStyle(color: cs.onSurface),
                            ),
                            Text(
                              '${settings.timePerQuestion}s',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 10,
                          max: 60,
                          divisions: 10,
                          value: settings.timePerQuestion.toDouble(),
                          label: settings.timePerQuestion.toString(),
                          onChanged: (value) =>
                              _controller.updateTimePerQuestion(value.toInt()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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
                  onPressed: _controller.reset,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset Progress'),
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
    final name = user?['name'] as String? ?? 'Player';
    final email = user?['email'] as String? ?? '';
    final rank = user?['current_rank'] as String? ?? 'Beginner';
    final avatar = user?['avatar'] as String?;

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
