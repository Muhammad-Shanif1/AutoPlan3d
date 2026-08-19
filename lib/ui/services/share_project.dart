import 'dart:convert';
import 'dart:io';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/project_model.dart';

class ProjectShareHelper {

  /// Share a Project object as a JSON file
  static Future<void> shareProjectAsJsonFile(
      Project project, {
        String ?fileName,
      }) async {
    try {
      // Use project name for filename (sanitized)
      String sanitizedName = project.name
          .replaceAll(RegExp(r'[^\w\-]'), '_')
          .replaceAll(' ', '_');
      String finalFileName = fileName ?? '${sanitizedName}_project.json';

      // Get temporary directory (no permissions needed)
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      // Convert Project to JSON string using your existing toJson() method
      String jsonString = project.toJson();

      // Write to file
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is the project: ${project.name}',
      );

      // Clean up temporary file
      await file.delete();
      Get.back();
    } catch (e) {
      print('Error sharing project: $e');
      rethrow;
    }
  }

  /// Share multiple projects as a single JSON file
  static Future<void> shareProjectsAsJsonFile(
      List<Project> projects, {
        String fileName = 'projects_export.json',
      }) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Convert list of projects to JSON
      final projectsJson = {
        'projects': projects.map((p) => p.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'count': projects.length,
      };

      String jsonString = jsonEncode(projectsJson);
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '${projects.length} project(s) shared',
      );

      await file.delete();

    } catch (e) {
      print('Error sharing projects: $e');
      rethrow;
    }
  }

  /// Share as text (simpler, but file is better for JSON)
  static Future<void> shareProjectAsText(Project project) async {
    String jsonString = project.toJson();
    await Share.share(jsonString);
  }
}


class ProjectJsonImporter {

  /// Pick and import a single project from JSON file
  static Future<Project?> importProjectFromFile() async {
    try {
      // Let user pick a JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        // dialogTitle: 'Select a project JSON file',
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        print(jsonString);
        // Use your existing fromJson() method
        Project importedProject = await ProjectService.instance.importProject(jsonString);

        return importedProject;
      }
      return null;

    } catch (e) {
      print('Error importing project: $e');
      return null;
    }
  }

  /// Import multiple projects from a file containing a list
  static Future<List<Project>?> importProjectsFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        // dialogTitle: 'Select projects JSON file',
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        Map<String, dynamic> jsonData = jsonDecode(jsonString);

        if (jsonData.containsKey('projects')) {
          List<Project> projects = (jsonData['projects'] as List)
              .map((p) => Project.fromMap(p as Map<String, dynamic>))
              .toList();
          return projects;
        }
      }
      return null;

    } catch (e) {
      print('Error importing projects: $e');
      return null;
    }
  }
}