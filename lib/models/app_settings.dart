class AppSettings {
  bool soundEnabled;
  bool musicEnabled;
  bool showExplanation;
  int questionCount;
  int timePerQuestion;
  String themeMode; // 'system', 'dark', 'light'
  String difficulty; // 'Beginner', 'Intermediate', 'Advanced'

  AppSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.questionCount,
    required this.timePerQuestion,
    this.showExplanation = true,
    this.themeMode = 'system',
    this.difficulty = 'Beginner',
  });

  factory AppSettings.defaults() {
    return AppSettings(
      soundEnabled: true,
      musicEnabled: true,
      questionCount: 10,
      timePerQuestion: 30,
      showExplanation: true,
      themeMode: 'system',
      difficulty: 'Beginner',
    );
  }
}
