
import 'package:flutter/material.dart';

import 'package:flutter_unity_widget_example/ui/app/theme.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/auth/authcontroller.dart';
import 'package:flutter_unity_widget_example/ui/controller/themeservier.dart';
import 'package:flutter_unity_widget_example/ui/services/camera_snapshot_service.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:flutter_unity_widget_example/ui/services/stripe_service.dart';
import 'package:flutter_unity_widget_example/ui/view/auth/login_screen.dart';
import 'package:flutter_unity_widget_example/ui/view/splash_screen.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoPlan 3d',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/home', page: () => MenuScreen1()),
      ],
      routes: {
        // '/oar':(context)=>Optionforar(),
      },
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLES  (copy-paste anywhere in your app)
// ─────────────────────────────────────────────────────────────────────────────

/*
final svc = ProjectService.instance;
// Already initialized in main(), no need to call init() again.

// ── PROJECT OPERATIONS ──────────────────────────────────────────────────────

// Create
final project = await svc.createProject(name: 'Living Room', description: 'Open plan');

// Rename
await svc.renameProject(project.id, 'Living Room v2');

// Update description
await svc.updateProjectDescription(project.id, 'Updated open plan layout');

// Change accent color
await svc.updateProjectColor(project.id, '#7C3AED');

// Duplicate (deep copies all objects)
final copy = await svc.duplicateProject(project.id);

// Delete
await svc.deleteProject(project.id);

// Get all projects (sorted newest first)
final allProjects = svc.projects;

// Get single project
final p = svc.getProject(project.id);

// Export to JSON string (for sharing/backup)
final json = svc.exportProject(project.id);

// Import from JSON string
final imported = await svc.importProject(json);

// ── OBJECT OPERATIONS ───────────────────────────────────────────────────────

// Add object (matching FurnitureManager output)
final chair = await svc.addObject(
  project.id,
  name: 'Chair 01',
  type: 'Chair_01',
  position: ObjectPosition(x: 2.0, y: 0.0, z: 3.0),
  rotation: ObjectRotation(x: 0, y: 45, z: 0),
  scale: ObjectScale(x: 1, y: 1, z: 1),
  color: '#FF5733',
);

// Update any property
await svc.updateObject(
  project.id, chair.id,
  position: ObjectPosition(x: 3.0, y: 0.0, z: 4.0),
  color: '#2563EB',
);

// Rename object
await svc.updateObject(project.id, chair.id, name: 'Blue Chair');

// Duplicate object (offset by 0.5 on X/Z)
final chairCopy = await svc.duplicateObject(project.id, chair.id);

// Remove single object
await svc.removeObject(project.id, chair.id);

// Clear all objects from a project
await svc.clearAllObjects(project.id);
*/
