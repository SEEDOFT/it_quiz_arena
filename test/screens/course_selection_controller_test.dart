import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:it_quiz_arena/screens/course_selection/course_selection_controller.dart';
import 'package:it_quiz_arena/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/mocks.dart';

http.Response _jsonResponse(dynamic data, int status) =>
    http.Response(jsonEncode(data), status, headers: {
      'content-type': 'application/json',
    });

Future<void> waitForInit() async {
  await Future.delayed(const Duration(milliseconds: 100));
}

void main() {
  group('CourseSelectionController', () {
    setUp(() async {
      await dotenv.load(fileName: '.env');
      SharedPreferences.setMockInitialValues({});
      ApiService.httpClient = MockClient((request) async {
        if (request.url.path == '/api/courses') {
          return _jsonResponse(
            MockApiResponses.successEnvelope([
              {
                'id': 1,
                'title': 'Dart Basics',
                'description': 'Learn Dart',
                'category': 'Programming',
                'difficulty': 'Beginner',
                'question_count': 20,
              },
              {
                'id': 2,
                'title': 'Advanced Dart',
                'description': 'Deep Dart',
                'category': 'Programming',
                'difficulty': 'Advanced',
                'question_count': 30,
              },
              {
                'id': 3,
                'title': 'Database Systems',
                'description': 'DB fundamentals',
                'category': 'Database',
                'difficulty': 'Intermediate',
                'question_count': 15,
              },
            ]),
            200,
          );
        }
        return _jsonResponse(
          MockApiResponses.errorEnvelope('Not found', 404),
          404,
        );
      });
    });

    test('loads courses and categories on init', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      expect(ctrl.allCourses.length, 3);
      expect(ctrl.categories, contains('All'));
      expect(ctrl.categories, contains('Programming'));
      expect(ctrl.categories, contains('Database'));
      expect(ctrl.loading, false);
    });

    test('filteredCourses defaults to showing only Beginner courses', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Dart Basics');
    });

    test('filteredCourses filters by category', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.setDifficulty('Intermediate');
      ctrl.setCategory('Database');
      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Database Systems');
    });

    test('filteredCourses filters by search query', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.searchController.text = 'Dart';
      ctrl.onSearchChanged();

      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Dart Basics');
    });

    test('filteredCourses filters by difficulty', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.setDifficulty('Advanced');

      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Advanced Dart');
    });

    test('filteredCourses filters by question count', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.setDifficulty('Advanced');
      ctrl.setQuestionCount(25);

      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Advanced Dart');
    });

    test('filteredCourses combines all filters', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.setCategory('Programming');
      ctrl.setDifficulty('Advanced');
      ctrl.setQuestionCount(5);

      expect(ctrl.filteredCourses.length, 1);
      expect(ctrl.filteredCourses.first.title, 'Advanced Dart');
    });

    test('toggleCourseSelection selects and deselects', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.toggleCourseSelection(1);
      expect(ctrl.selectedCourseId, 1);
      expect(ctrl.selectedCourse, isNotNull);
      expect(ctrl.selectedCourse!.id, 1);

      ctrl.toggleCourseSelection(1);
      expect(ctrl.selectedCourseId, null);
      expect(ctrl.selectedCourse, null);
    });

    test('setDifficulty persists to SharedPreferences', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      await ctrl.setDifficulty('Advanced');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('difficulty'), 'Advanced');
    });

    test('setQuestionCount persists to SharedPreferences', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      await ctrl.setQuestionCount(20);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('question_count'), 20);
    });

    test('setTimePerQuestion persists to SharedPreferences', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      await ctrl.setTimePerQuestion(45);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('time_per_question'), 45);
    });

    test('refresh reloads courses', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.allCourses.clear();
      expect(ctrl.allCourses.length, 0);

      await ctrl.refresh();
      expect(ctrl.allCourses.length, 3);
    });

    test('error state is captured on API failure', () async {
      ApiService.httpClient = MockClient((_) async => _jsonResponse(
            MockApiResponses.errorEnvelope('Server error', 500),
            500,
          ));

      final ctrl = CourseSelectionController();
      await waitForInit();

      expect(ctrl.error, isNotNull);
      expect(ctrl.loading, false);
    });

    test('dispose cleans up searchController', () async {
      final ctrl = CourseSelectionController();
      await waitForInit();

      ctrl.dispose();
      expect(ctrl.searchController.hasListeners, false);
    });
  });
}
