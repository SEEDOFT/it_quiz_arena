import 'package:flutter/material.dart';
import 'package:it_quiz_arena/core/app_colors.dart';
import 'package:it_quiz_arena/core/app_routes.dart';
import 'package:it_quiz_arena/screens/course_selection/course_selection_controller.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  late final CourseSelectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CourseSelectionController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color categoryColor(String category) {
    switch (category) {
      case 'Programming':
        return AppColors.categoryProgramming;
      case 'Networking':
        return AppColors.categoryNetworking;
      case 'Database':
        return AppColors.categoryDatabase;
      case 'Web Development':
        return AppColors.categoryWebDevelopment;
      case 'Cloud & DevOps':
        return AppColors.categoryCloudDevOps;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          title: const Text("Select Course"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.error != null) {
              return Center(child: Text('Error: ${_controller.error}'));
            }

            final filtered = _controller.filteredCourses;
            final selectedCourse = _controller.selectedCourse;

            return RefreshIndicator(
              onRefresh: _controller.refresh,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _controller.searchController,
                      onChanged: (_) => _controller.onSearchChanged(),
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: cs.outline),
                        prefixIcon: Icon(Icons.search, color: cs.outline),
                        filled: true,
                        fillColor: cs.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _controller.categories.length,
                      itemBuilder: (_, index) {
                        final category = _controller.categories[index];
                        final active = _controller.activeCategory == category;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: active,
                            selectedColor: cs.primary,
                            labelStyle: TextStyle(
                              color: active
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant,
                            ),
                            backgroundColor: cs.surfaceContainer,
                            onSelected: (_) =>
                                _controller.setCategory(category),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filtered.length} courses available',
                        style: TextStyle(color: cs.outline),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game Settings',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: ['Beginner', 'Intermediate', 'Advanced']
                              .map(
                                (d) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _controller.setDifficulty(d),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _controller.difficulty == d
                                              ? cs.primary
                                              : cs.surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          d,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontSize: 11,
                                            fontWeight:
                                                _controller.difficulty == d
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Questions',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                min: 5,
                                max: 50,
                                divisions: 9,
                                value: _controller.questionCount.toDouble(),
                                label: _controller.questionCount.toString(),
                                onChanged: (v) =>
                                    _controller.setQuestionCount(v.toInt()),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${_controller.questionCount}',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Time per Q',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                min: 10,
                                max: 60,
                                divisions: 10,
                                value: _controller.timePerQuestion.toDouble(),
                                label: '${_controller.timePerQuestion}s',
                                onChanged: (v) =>
                                    _controller.setTimePerQuestion(v.toInt()),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${_controller.timePerQuestion}s',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .75,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final course = filtered[index];
                        final selected =
                            _controller.selectedCourseId == course.id;

                        return GestureDetector(
                          onTap: () =>
                              _controller.toggleCourseSelection(course.id),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? cs.primary.withValues(alpha: 0.12)
                                  : cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? cs.primary
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.school,
                                  color: categoryColor(course.category),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  course.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  course.difficulty,
                                  style: TextStyle(
                                    color: course.difficulty == 'Advanced'
                                        ? AppColors.difficultyAdvanced
                                        : course.difficulty == 'Intermediate'
                                        ? AppColors.difficultyIntermediate
                                        : AppColors.difficultyBeginner,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(value: 0),
                                const SizedBox(height: 6),
                                Text(
                                  '${_controller.questionCount} Questions',
                                  style: TextStyle(
                                    color: cs.outline,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(20),
                    child: selectedCourse != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: cs.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedCourse.title,
                                        style: TextStyle(color: cs.onSurface),
                                      ),
                                    ),
                                    Text(
                                      '${selectedCourse.questionCount} Q',
                                      style: TextStyle(color: cs.outline),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text("Start Quiz"),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.countdown,
                                      arguments: {
                                        'courseId': selectedCourse.id,
                                        'questionCount':
                                            _controller.questionCount,
                                        'timePerQuestion':
                                            _controller.timePerQuestion,
                                        'difficulty': _controller.difficulty,
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Select a course to start",
                                style: TextStyle(color: cs.outline),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
