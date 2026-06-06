import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_quiz_arena/models/course.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:it_quiz_arena/services/settings_service.dart';

class CourseSelectionController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  List<Course> allCourses = [];
  List<String> categories = [];
  String activeCategory = 'All';
  int? selectedCourseId;
  bool loading = true;
  bool refreshing = false;
  String? error;

  int questionCount = 10;
  int timePerQuestion = 30;
  String difficulty = 'Beginner';

  CourseSelectionController() {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([_loadCourses(), _loadSettings()]);
  }

  Future<void> refresh() async {
    refreshing = true;
    error = null;
    notifyListeners();

    try {
      await Future.wait([_loadCourses(), _loadSettings()]);
    } catch (e) {
      error = e.toString();
    }

    refreshing = false;
    notifyListeners();
  }

  Future<void> _loadCourses() async {
    try {
      final data = await ApiService.getCourses();
      final courses = data
          .map((j) => Course.fromJson(j as Map<String, dynamic>))
          .toList();
      allCourses = courses;

      final cats = <String>{'All'};
      for (final c in courses) {
        cats.add(c.category);
      }
      categories = cats.toList()..sort();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService().load();
    questionCount = settings.questionCount;
    timePerQuestion = settings.timePerQuestion;
    difficulty = settings.difficulty;
    notifyListeners();
  }

  void setCategory(String category) {
    if (activeCategory != category) {
      activeCategory = category;
      notifyListeners();
    }
  }

  void onSearchChanged() {
    notifyListeners();
  }

  Future<void> setDifficulty(String value) async {
    difficulty = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsService.difficultyKey, value);
  }

  Future<void> setQuestionCount(int value) async {
    questionCount = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsService.questionCountKey, value);
  }

  Future<void> setTimePerQuestion(int value) async {
    timePerQuestion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsService.timerKey, value);
  }

  void toggleCourseSelection(int courseId) {
    if (selectedCourseId == courseId) {
      selectedCourseId = null;
    } else {
      selectedCourseId = courseId;
    }
    notifyListeners();
  }

  List<Course> get filteredCourses {
    return allCourses.where((course) {
      final query = searchController.text.toLowerCase();

      final matchesSearch = query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.description.toLowerCase().contains(query);

      final matchesCategory =
          activeCategory == 'All' || course.category == activeCategory;

      final matchesDifficulty = difficulty == course.difficulty;

      final matchesQuestionCount = course.questionCount >= questionCount;

      return matchesSearch && matchesCategory && matchesDifficulty && matchesQuestionCount;
    }).toList();
  }

  Course? get selectedCourse {
    try {
      return allCourses.firstWhere((e) => e.id == selectedCourseId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
