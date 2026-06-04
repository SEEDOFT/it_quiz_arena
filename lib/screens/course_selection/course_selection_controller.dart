import 'package:flutter/material.dart';
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
  String? error;

  int questionCount = 10;
  int timePerQuestion = 30;
  String difficulty = 'Beginner';

  CourseSelectionController() {
    searchController.addListener(_onSearchChanged);
    _init();
  }

  Future<void> _init() async {
    await Future.wait([_loadCourses(), _loadSettings()]);
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
  }

  void _onSearchChanged() {
    notifyListeners();
  }

  void setCategory(String category) {
    if (activeCategory != category) {
      activeCategory = category;
      notifyListeners();
    }
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
      final matchesSearch =
          course.title.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ) ||
          course.description.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      final matchesCategory =
          activeCategory == 'All' || course.category == activeCategory;

      return matchesSearch && matchesCategory;
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
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
