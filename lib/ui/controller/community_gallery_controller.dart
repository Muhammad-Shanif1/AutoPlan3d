import 'dart:convert';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/services/api_service.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

class CommunityProject {
  final int projectId;
  final int userId;
  final String title;
  final String description;
  final String visibility;
  final String userName;
  final String? projectImage;
  final Map<String, dynamic>? projectData;

  CommunityProject({
    required this.projectId,
    required this.userId,
    required this.title,
    required this.description,
    required this.visibility,
    required this.userName,
    this.projectImage,
    this.projectData,
  });

  factory CommunityProject.fromJson(Map<String, dynamic> json) {
    return CommunityProject(
      projectId: json['project_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      visibility: json['visibility'],
      userName: json['user_name'],
      projectImage: json['project_image'],
      projectData: json['project_data'],
    );
  }
}

class CommunityGalleryController extends GetxController {
  final ApiService api = ApiService.instance;
  final TextEditingController searchTextController = TextEditingController();

  final RxList<CommunityProject> allProjects = <CommunityProject>[].obs;
  final RxList<CommunityProject> filteredProjects = <CommunityProject>[].obs;
  final RxList<int> favoriteProjectIds = <int>[].obs;
  final RxInt selectedTab = 0.obs; // 0: Explore, 1: Favorites
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'Newest'.obs;
  final GetStorage storage = GetStorage();
  static const String _favKey = 'favorite_community_projects';
  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    fetchPublicProjects(isRefresh: true);
    
    // Setup listener for search and sort
    debounce(searchQuery, (_) {
      if (selectedTab.value == 0) {
        fetchPublicProjects(isRefresh: true);
      } else {
        applyFilters();
      }
    }, time: const Duration(milliseconds: 600));

    ever(sortBy, (_) => applyFilters());
    ever(selectedTab, (int tab) {
      if (tab == 0 && allProjects.isEmpty) {
        fetchPublicProjects(isRefresh: true);
      }
      applyFilters();
    });
  }

  List<CommunityProject> get favoriteProjects {
    return allProjects.where((p) => favoriteProjectIds.contains(p.projectId)).toList();
  }

  void _loadFavorites() {
    final storedFavs = storage.read<List<dynamic>>(_favKey);
    if (storedFavs != null) {
      favoriteProjectIds.assignAll(storedFavs.cast<int>());
    }
  }

  void toggleFavorite(int projectId) {
    if (favoriteProjectIds.contains(projectId)) {
      favoriteProjectIds.remove(projectId);
    } else {
      favoriteProjectIds.add(projectId);
    }
    storage.write(_favKey, favoriteProjectIds.toList());
  }

  bool isFavorite(int projectId) {
    return favoriteProjectIds.contains(projectId);
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> fetchPublicProjects({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      allProjects.clear();
      hasMore.value = true;
    } else {
      if (!hasMore.value || isMoreLoading.value) return;
      isMoreLoading.value = true;
    }

    try {
      int skip = isRefresh ? 0 : allProjects.length;
      String endpoint = '/projects/public?skip=$skip&limit=$_limit';
      
      if (searchQuery.value.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(searchQuery.value.trim())}';
      }

      final response = await api.get(endpoint, requireAuth: false);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<CommunityProject> fetched = data.map((p) => CommunityProject.fromJson(p)).toList();
        
        if (isRefresh) {
          allProjects.assignAll(fetched);
        } else {
          allProjects.addAll(fetched);
        }

        hasMore.value = fetched.length == _limit;
        applyFilters();
      }
    } catch (e) {
      print('Error fetching public projects: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void applyFilters() {
    List<CommunityProject> results = selectedTab.value == 0 
        ? allProjects.toList() 
        : favoriteProjects;

    // Local search only for Favorites tab (Explore is handled by API)
    if (selectedTab.value == 1 && searchQuery.value.isNotEmpty) {
      results = results.where((p) {
        return p.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               p.userName.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply Sort
    if (sortBy.value == 'Newest') {
      results.sort((a, b) => b.projectId.compareTo(a.projectId));
    } else if (sortBy.value == 'Oldest') {
      results.sort((a, b) => a.projectId.compareTo(b.projectId));
    } else if (sortBy.value == 'A-Z') {
      results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    filteredProjects.value = results;
  }
}
