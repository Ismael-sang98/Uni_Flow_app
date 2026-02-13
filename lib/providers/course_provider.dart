import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/course.dart';
import '../services/notification_service.dart';

class CourseProvider with ChangeNotifier {
  final Box<Course> _courseBox = Hive.box<Course>('courses');

  List<Course> _courses = [];
  List<Course> get courses => _courses;

  void loadCourses() {
    _courses = _courseBox.values.toList();

    _courses.sort((a, b) {
      if (a.dayOfWeeks != b.dayOfWeeks) {
        return a.dayOfWeeks.compareTo(b.dayOfWeeks);
      }
      return a.startTime.compareTo(b.startTime);
    });
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await _courseBox.put(course.id, course);
    loadCourses();
  }

  Future<void> updateCourse(Course updatedCourse) async {
    await _courseBox.put(updatedCourse.id, updatedCourse);
    loadCourses();
  }

  Future<void> deleteCourse(String courseId) async {
    await NotificationService().cancelNotification(
      NotificationService.notificationIdFromCourseId(courseId),
    );
    await _courseBox.delete(courseId);
    loadCourses();
  }
}
