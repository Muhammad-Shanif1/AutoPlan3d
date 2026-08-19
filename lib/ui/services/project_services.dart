import 'dart:convert';
import 'dart:async';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'api_service.dart';

import '../controller/home_page_controller.dart';
import '../controller/profile_controller.dart';
import '../models/object_model.dart';
import '../models/project_model.dart';

class ProjectService {
  ProjectService._();
  static final ProjectService instance = ProjectService._();

  static const String _idsKeyBase = 'project_ids';
  static const String _projectPrefix = 'project_';
  final api = ApiService.instance;

  String get _currentIdsKey {
    final userData = storage.read('user');
    if (userData != null && userData['id'] != null) {
      return '${_idsKeyBase}_user_${userData['id']}';
    }
    return '${_idsKeyBase}_guest';
  }

  final storage = GetStorage();
  final List<Project> _projects = [];
  bool _initialized = false;
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  Future<void> init() async {
    Get.put(HomePageController(), permanent: true);
    final profileController = Get.find<ProfileController>();

    // Only sync when transitioning from offline to online, not on initial load
    _connectivitySubscription?.cancel();
    _connectivitySubscription = profileController.isOffline.listen((offline) {
      if (offline == false && _initialized) {
        print('🌐 Internet restored, triggering sync...');
        Future.delayed(const Duration(seconds: 2), () {
          performFullSync();
        });
      }
    });

    if (_initialized) return;

    await _loadAllProjects();
    _initialized = true;
    _notifyController();
  }

  Future<void> performFullSync({bool showSnackbars = true}) async {
    final profileController = Get.find<ProfileController>();
    final userData = storage.read('user');
    final bool isUserLoggedIn = userData != null && userData['id'] != null;

    print('🔄 Full Sync Requested. Online: ${!profileController.isOffline.value}, LoggedIn: $isUserLoggedIn');

    if (_isSyncing) {
      print('⚠️ Sync already in progress.');
      return;
    }
    
    if (profileController.isOffline.value) {
      print('🚫 Cannot sync while offline.');
      return;
    }

    if (!isUserLoggedIn) {
      print('👤 Guest mode - no cloud sync performed.');
      return;
    }

    _isSyncing = true;
    
    try {
      if (showSnackbars) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.closeAllSnackbars();
          AppSnackbars.show(
            title: 'Syncing',
            message: 'Updating your projects...',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            colorText: Colors.white,
          );
        });
      }

      print('☁️ Pulling from cloud...');
      await syncWithCloud();
      
      print('📦 Syncing guest projects...');
      await _syncGuestProjectsToCloud();
      
      print('📤 Syncing unsynced projects...');
      await _syncUnsyncedProjects();
      
      if (showSnackbars) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.closeAllSnackbars();
          AppSnackbars.show(
            title: 'Sync Complete',
            message: 'All projects are up to date',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            icon: const Icon(Icons.cloud_done, color: Colors.white),
          );
        });
      }
    } catch (e) {
      print('❌ Sync failed: $e');
      if (showSnackbars) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.closeAllSnackbars();
          AppSnackbars.error(title: 'Sync Failed', message: 'Could not connect to server');
        });
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncUnsyncedProjects() async {
    print('🔍 Checking for unsynced projects...');
    final profileController = Get.find<ProfileController>();
    if (profileController.isOffline.value) return;

    final userData = storage.read('user');
    if (userData == null || userData['id'] == null) return;

    bool anySynced = false;
    final projectsToSync = _projects.where((p) => p.cloudId == null).toList();
    print('📤 Found ${projectsToSync.length} unsynced projects.');

    for (final project in projectsToSync) {
      try {
        print('📤 Syncing project: ${project.name}');
        final response = await api.post(
          '/projects/create_project/for_user/${userData['id']}',
          body: {
            'title': project.name,
            'description': project.description,
            'visibility': project.visibility,
            'project_data': project.toMap(),
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          project.cloudId = result['project_id'];
          await _persistProject(project);
          anySynced = true;
          print('✅ Project synced: ${project.name}');
        }
      } catch (e) {
        print('❌ Failed to sync unsynced project ${project.id}: $e');
      }
    }

    if (anySynced) {
      _notifyController();
    }
  }

  Future<void> _syncGuestProjectsToCloud() async {
    final profileController = Get.find<ProfileController>();
    if (profileController.isOffline.value) return;

    final userData = storage.read('user');
    final token = storage.read('token');
    if (userData == null || userData['id'] == null || token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final guestIdsKey = '${_idsKeyBase}_guest';
    String? guestIdsJson = prefs.getString(guestIdsKey);
    
    // Also check the old legacy key during migration
    if (guestIdsJson == null) {
      guestIdsJson = prefs.getString(_idsKeyBase);
    }

    if (guestIdsJson == null) return;

    final List<String> guestIds = (jsonDecode(guestIdsJson) as List<dynamic>).cast<String>();
    if (guestIds.isEmpty) return;

    bool anySynced = false;
    bool limitReached = false;
    List<String> remainingGuestIds = List.from(guestIds);

    for (final id in guestIds) {
      final projectJson = prefs.getString('$_projectPrefix$id');
      if (projectJson == null) {
        remainingGuestIds.remove(id);
        continue;
      }

      try {
        final project = Project.fromJson(projectJson);
        
        // Skip if this project is already in our list (e.g. pulled from cloud sync)
        if (_projects.any((p) => p.id == project.id)) {
          // Note: We no longer remove from guest list as requested
          continue;
        }

        // Upload to cloud
        final response = await api.post(
          '/projects/create_project/for_user/${userData['id']}',
          body: {
            'title': project.name,
            'description': project.description,
            'visibility': project.visibility,
            'project_data': project.toMap(),
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          project.cloudId = result['project_id'];
          
          // Move to current user's local list
          if (!_projects.any((p) => p.id == project.id)) {
            _projects.add(project);
            await _persistProject(project);
            anySynced = true;
          }
        } else if (response.statusCode == 403) {
          // Limit reached: Do not move to user's list as requested
          limitReached = true;
        } else {
          print('Failed to sync guest project $id: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Failed to sync guest project $id to cloud: $e');
      }
    }

    if (anySynced) {
      await _persistIds();
      _notifyController();
    }

    if (limitReached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.warning(
          title: 'Storage Limit',
          message: 'Guest mode project is saved locally only. Upgrade to sync project to cloud.',
        );
      });
    }

    // Update guest IDs list (removing those that were successfully moved/synced)
    await prefs.setString(guestIdsKey, jsonEncode(remainingGuestIds));
    // Clean up old legacy key if it exists
    if (prefs.containsKey(_idsKeyBase)) {
      await prefs.remove(_idsKeyBase);
    }
  }

  Future<void> reInitialize() async {
    _initialized = false;
    _projects.clear();
    _connectivitySubscription?.cancel();
    await init();
  }

  Future<void> syncWithCloud() async {
    final profileController = Get.find<ProfileController>();
    if (profileController.isOffline.value) return;

    final userData = storage.read('user');
    final token = storage.read('token');
    if (userData == null || userData['id'] == null || token == null) return;

    int userId = userData['id'];

    try {
      final response = await api.get('/projects/list_projects/for_user/$userId');
      print('📡 Cloud Projects API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> cloudProjectsRaw = jsonDecode(response.body);
        print('✅ Found ${cloudProjectsRaw.length} projects in cloud.');
        
        List<Project> projectsToPush = [];

        for (var p in cloudProjectsRaw) {
          Map<String, dynamic> projectMap = p['project_data'] ?? {};
          projectMap['cloud_id'] = p['project_id'];
          projectMap['name'] = p['title'];
          projectMap['description'] = p['description'];
          projectMap['visibility'] = p['visibility'];
          projectMap['projectImage'] = p['project_image'];
          
          final Project cp = Project.fromMap(projectMap);
          final localIdx = _projects.indexWhere((lp) => lp.id == cp.id);
          
          if (localIdx != -1) {
            final localProject = _projects[localIdx];
            if (cp.lastModified.isAfter(localProject.lastModified)) {
              _projects[localIdx] = cp;
              await _persistProject(cp);
            } else if (localProject.lastModified.isAfter(cp.lastModified)) {
              projectsToPush.add(localProject);
            }
          } else {
            _projects.add(cp);
            await _persistProject(cp);
          }
        }
        
        for (var lp in projectsToPush) {
          await _updateCloudProject(lp);
        }

        await _persistIds();
        _notifyController();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Cloud sync failed: $e');
      rethrow;
    }
  }

  List<Project> get projects {
    final list = List<Project>.from(_projects);
    list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return list;
  }

/*
  void _spawnFullObject(SceneObject obj, controller) {
    final String json = jsonEncode({
      'furnitureName': obj.type,
      'positionX': obj.position.x,
      'positionY': obj.position.y,
      'positionZ': obj.position.z,
      'rotationX': obj.rotation.x,
      'rotationY': obj.rotation.y,
      'rotationZ': obj.rotation.z,
      'scaleX':    obj.scale.x,
      'scaleY':    obj.scale.y,
      'scaleZ':    obj.scale.z,
      'color':     obj.color,
    });
    controller?.postMessage('FurnitureManager', 'SpawnFullObject', json);
  }
*/

  Future<void> loadProjectScene(String projectId, Controller) async {
    final project = getProject(projectId);
    if (project == null || project.objects.isEmpty) return;

    final String json = jsonEncode({
      'objects': project.objects.map((obj) => {
        'furnitureName': obj.type,
        'category':      obj.category,
        'positionX': obj.position.x,
        'positionY': obj.position.y,
        'positionZ': obj.position.z,
        'rotationX': obj.rotation.x,
        'rotationY': obj.rotation.y,
        'rotationZ': obj.rotation.z,
        'scaleX':    obj.scale.x,
        'scaleY':    obj.scale.y,
        'scaleZ':    obj.scale.z,
        'color':     obj.color,
      }).toList(),
    });
    Controller?.postMessage('FurnitureManager', 'SpawnAllObjects', json);
  }

  Future<Project> createProject({
    required String name,
    String description = '',
    String visibility = 'Private',
    String previewColor = '#4A90D9',
  }) async {
    _assertInitialized();

    final project = Project(
      id: _generateId(),
      name: name.trim(),
      description: description.trim(),
      visibility: visibility,
      previewColor: previewColor,
    );

    _projects.add(project);
    await _persistProject(project);
    await _persistIds();
    
    final userData = storage.read('user');
    final token = storage.read('token');
    final profileController = Get.find<ProfileController>();
    
    if (userData != null && userData['id'] != null && token != null && !profileController.isOffline.value) {
      try {
        final response = await api.post(
          '/projects/create_project/for_user/${userData['id']}',
          body: {
            'title': project.name,
            'description': project.description,
            'visibility': project.visibility,
            'project_data': project.toMap(),
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          project.cloudId = result['project_id'];
          await _persistProject(project);
        }
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.warning(title: 'Cloud Save Failed', message: 'Project saved locally only.');
        });
      }
    }

    _notifyController();
    return project;
  }

  Future<void> updateProject({
    required String projectId,
    String? name,
    String? description,
    String? visibility,
    String? previewColor,
  }) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final profileController = Get.find<ProfileController>();

    if (project.cloudId != null && profileController.isOffline.value) {
      throw Exception('Cannot edit cloud projects while offline');
    }

    if (name != null) project.name = name.trim();
    if (description != null) project.description = description.trim();
    if (visibility != null) project.visibility = visibility;
    if (previewColor != null) project.previewColor = previewColor;
    
    project.lastModified = DateTime.now();
    await _persistProject(project);

    final token = storage.read('token');
    if (token != null && project.cloudId != null) {
      try {
        await api.put(
          '/projects/update_project/${project.cloudId}',
          body: {
            'title': project.name,
            'description': project.description,
            'visibility': project.visibility,
            'project_data': project.toMap(),
          },
        );
      } catch (e) {
        print('Cloud update failed: $e');
      }
    }
    _notifyController();
  }

  Future<void> renameProject(String projectId, String newName) async {
    await updateProject(projectId: projectId, name: newName);
  }

  Future<void> updateProjectDescription(String projectId, String description) async {
    await updateProject(projectId: projectId, description: description);
  }

  Future<void> updateProjectColor(String projectId, String hexColor) async {
    await updateProject(projectId: projectId, previewColor: hexColor);
  }

  Future<String?> uploadProjectImage(String projectId, String filePath) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final profileController = Get.find<ProfileController>();

    if (profileController.isOffline.value) {
      throw Exception('Cannot upload images while offline');
    }

    if (project.cloudId == null) {
      throw Exception('Project must be synced to cloud before uploading an image');
    }

    try {
      final response = await api.uploadImage('/projects/${project.cloudId}/upload_image', filePath);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final imageUrl = result['project_image'];
        
        // Update local project with new image URL
        project.projectImage = imageUrl;
        await _persistProject(project);
        _notifyController();
        
        return imageUrl;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('Image upload failed: $e');
      rethrow;
    }
  }

  void _notifyController() {
    try {
      final HomePageController controller = Get.find();
      controller.projects.value = List<Project>.from(_projects);
      controller.projects.refresh();
    } catch (_) {}
  }

  Future<void> deleteProject(String projectId, {String? password}) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final profileController = Get.find<ProfileController>();

    if (project.cloudId != null && profileController.isOffline.value) {
      throw Exception('Cannot delete cloud projects while offline');
    }

    final userData = storage.read('user');
    final token = storage.read('token');
    
    // Only attempt cloud deletion if we have a user, a token, and it's a cloud project
    if (userData != null && token != null && project.cloudId != null && !profileController.isOffline.value) {
      if (password == null || password.isEmpty) {
        throw Exception('Password required to delete project from cloud');
      }
      try {
        final response = await api.delete(
          '/projects/delete_project/${project.cloudId}',
          body: {'password': password},
          autoLogout: false,
        );
        if (response.statusCode != 200) {
          final error = jsonDecode(response.body);
          throw Exception(error['detail'] ?? 'Failed to delete project from cloud');
        }
      } catch (e) {
        rethrow;
      }
    }

    _projects.remove(project);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_projectPrefix$projectId');
    await _persistIds();

    // Also remove from guest list if it exists there
    final guestIdsKey = '${_idsKeyBase}_guest';
    String? guestIdsJson = prefs.getString(guestIdsKey);
    if (guestIdsJson != null) {
      try {
        List<String> guestIds = (jsonDecode(guestIdsJson) as List<dynamic>).cast<String>();
        if (guestIds.contains(projectId)) {
          guestIds.remove(projectId);
          await prefs.setString(guestIdsKey, jsonEncode(guestIds));
        }
      } catch (_) {}
    }

    _notifyController();
  }

  Future<Project> duplicateProject(String projectId) async {
    _assertInitialized();
    final original = _findOrThrow(projectId);
    final copy = original.duplicate();
    _projects.add(copy);
    await _persistProject(copy);
    await _persistIds();

    final userData = storage.read('user');
    final token = storage.read('token');
    final profileController = Get.find<ProfileController>();

    if (userData != null && userData['id'] != null && token != null && !profileController.isOffline.value) {
      try {
        final response = await api.post(
          '/projects/create_project/for_user/${userData['id']}',
          body: {
            'title': copy.name,
            'description': copy.description,
            'project_data': copy.toMap(),
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          copy.cloudId = result['project_id'];
          await _persistProject(copy);
        }
      } catch (e) {
        print('Cloud duplication failed');
      }
    }

    _notifyController();
    return copy;
  }

  Project? getProject(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAllProjects() async {
    _assertInitialized();
    final prefs = await SharedPreferences.getInstance();
    for (final project in _projects) {
      await prefs.remove('$_projectPrefix${project.id}');
    }
    _projects.clear();
    await prefs.remove(_currentIdsKey);
    _notifyController();
  }

  Future<SceneObject> addObject(String projectId, {
    required String name,
    required String type,
    required String category,
    ObjectPosition? position,
    ObjectRotation? rotation,
    ObjectScale? scale,
    String color = '#FFFFFF',
  }) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final obj = SceneObject(
      id: _generateId(),
      name: name.trim(),
      type: type,
      category: category,
      position: position,
      rotation: rotation,
      scale: scale,
      color: color,
    );
    project.objects.add(obj);
    project.lastModified = DateTime.now();
    await _persistProject(project);
    await _updateCloudProject(project);
    return obj;
  }

  Future<void> updateObject(String projectId, String objectId, {
    String? name,
    ObjectPosition? position,
    ObjectRotation? rotation,
    ObjectScale? scale,
    String? color,
  }) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final obj = _findObjectOrThrow(project, objectId);
    if (name != null) obj.name = name.trim();
    if (position != null) obj.position = position;
    if (rotation != null) obj.rotation = rotation;
    if (scale != null) obj.scale = scale;
    if (color != null) obj.color = color;
    obj.lastModified = DateTime.now();
    project.lastModified = DateTime.now();
    await _persistProject(project);
    await _updateCloudProject(project);
  }

  Future<void> removeObject(String projectId, String objectId) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    project.objects.removeWhere((o) => o.id == objectId);
    project.lastModified = DateTime.now();
    await _persistProject(project);
    await _updateCloudProject(project);
  }

  Future<void> clearAllObjects(String projectId) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    project.objects.clear();
    project.lastModified = DateTime.now();
    await _persistProject(project);
    await _updateCloudProject(project);
  }

  Future<SceneObject> duplicateObject(String projectId, String objectId) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    final original = _findObjectOrThrow(project, objectId);
    final copy = original.duplicate();
    project.objects.add(copy);
    project.lastModified = DateTime.now();
    await _persistProject(project);
    await _updateCloudProject(project);
    return copy;
  }

  Future<void> syncObjectsFromUnity(String projectId, List<SceneObject> objects) async {
    _assertInitialized();
    final project = _findOrThrow(projectId);
    project.objects..clear()..addAll(objects);
    project.lastModified = DateTime.now();
    await _persistProject(project);

    final profileController = Get.find<ProfileController>();
    if (profileController.isOffline.value) return;

    final token = storage.read('token');
    if (token != null && project.cloudId != null) {
      try {
        await api.put(
          '/projects/update_project/${project.cloudId}',
          body: {
            'title': project.name,
            'description': project.description,
            'project_data': project.toMap(),
          },
        );
      } catch (e) {
        print('Cloud object sync failed');
      }
    }
  }

  String exportProject(String projectId) {
    _assertInitialized();
    return _findOrThrow(projectId).toJson();
  }

  Future<Project> importProject(String jsonString) async {
    _assertInitialized();
    var project = Project.fromJson(jsonString);
    if (_projects.any((p) => p.id == project.id)) {
      project = Project(
        id: _generateId(),
        name: project.name,
        description: project.description,
        previewColor: project.previewColor,
        objects: project.objects,
      );
    }
    _projects.add(project);
    await _persistProject(project);
    await _persistIds();
    _notifyController();
    return project;
  }

  Future<void> _loadAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    String? idsJson = prefs.getString(_currentIdsKey);
    
    // Migration: If guest key is empty, try loading from old 'project_ids' key
    if (idsJson == null && _currentIdsKey == '${_idsKeyBase}_guest') {
      idsJson = prefs.getString(_idsKeyBase);
    }

    if (idsJson == null) return;
    final ids = (jsonDecode(idsJson) as List<dynamic>).cast<String>();
    for (final id in ids) {
      final projectJson = prefs.getString('$_projectPrefix$id');
      if (projectJson != null) {
        try {
          _projects.add(Project.fromJson(projectJson));
        } catch (e) {
          print('⚠️ Could not load project $id: $e');
        }
      }
    }
  }

  Future<void> _persistProject(Project project) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_projectPrefix${project.id}', project.toJson());
  }

  Future<void> _persistIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _projects.map((p) => p.id).toList();
    await prefs.setString(_currentIdsKey, jsonEncode(ids));
  }

  Project _findOrThrow(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      throw ProjectNotFoundException(projectId);
    }
  }

  SceneObject _findObjectOrThrow(Project project, String objectId) {
    final obj = project.findObject(objectId);
    if (obj == null) throw ObjectNotFoundException(objectId, project.id);
    return obj;
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('ProjectService not initialized.');
    }
  }

  static String _generateId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  Future<void> _updateCloudProject(Project project) async {
    final profileController = Get.find<ProfileController>();
    if (profileController.isOffline.value) return;

    final token = storage.read('token');
    if (token != null && project.cloudId != null) {
      try {
        await api.put(
          '/projects/update_project/${project.cloudId}',
          body: {
            'title': project.name,
            'description': project.description,
            'project_data': project.toMap(),
          },
        );
      } catch (e) {
        print('Cloud update failed: $e');
      }
    }
  }
}

class ProjectNotFoundException implements Exception {
  final String projectId;
  const ProjectNotFoundException(this.projectId);
  @override
  String toString() => 'Project not found: $projectId';
}

class ObjectNotFoundException implements Exception {
  final String objectId;
  final String projectId;
  const ObjectNotFoundException(this.objectId, this.projectId);
  @override
  String toString() => 'Object $objectId not found in project $projectId';
}
