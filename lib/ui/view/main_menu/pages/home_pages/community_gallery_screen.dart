import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/community_gallery_controller.dart';
import 'package:flutter_unity_widget_example/ui/controller/home_page_controller.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class CommunityGalleryScreen extends StatelessWidget {
  const CommunityGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityGalleryController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Community Gallery",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => controller.isLoading.value 
            ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            : IconButton(
                icon: Icon(Icons.refresh, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => controller.fetchPublicProjects(isRefresh: true),
              ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Selection & Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabButton("Explore", 0, controller, isDarkMode),
                const SizedBox(width: 12),
                _buildTabButton("Favorites", 1, controller, isDarkMode),
                const Spacer(),
                // Sort Dropdown
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.sortBy.value,
                      icon: const Icon(Icons.sort, color: Colors.blueAccent, size: 18),
                      dropdownColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                      onChanged: (String? newValue) {
                        if (newValue != null) controller.sortBy.value = newValue;
                      },
                      items: <String>['Newest', 'Oldest', 'A-Z']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )),
                ),
              ],
            ),
          ),

          // Search Bar Section (Alone)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchTextController,
                onChanged: (value) => controller.searchQuery.value = value,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "Search projects or users...",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent.shade400),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          controller.searchTextController.clear();
                          controller.searchQuery.value = '';
                        },
                      )
                    : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Project List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allProjects.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }

              if (controller.filteredProjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.selectedTab.value == 0 ? Icons.search_off : Icons.favorite_border, 
                        size: 80, 
                        color: Colors.grey.withOpacity(0.3)
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.selectedTab.value == 0 
                            ? "No public projects found" 
                            : "No favorite projects yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: controller.filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = controller.filteredProjects[index];
                        return _buildCommunityProjectCard(project, isDarkMode);
                      },
                    ),
                  ),
                  // Show More Button
                  if (controller.hasMore.value && controller.selectedTab.value == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                      child: Obx(() => controller.isMoreLoading.value
                        ? const CircularProgressIndicator(color: Colors.blueAccent)
                        : SizedBox(
                            width: 200,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () => controller.fetchPublicProjects(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text(
                                "Show More", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, CommunityGalleryController controller, bool isDarkMode) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blueAccent 
                : (isDarkMode ? const Color(0xFF1F2937) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCommunityProjectCard(CommunityProject project, bool isDarkMode) {
    final controller = Get.find<CommunityGalleryController>();
    return InkWell(
      onTap: () => _showProjectDetailsDialog(Get.context!, project, isDarkMode),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Preview / Thumbnail
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: project.projectImage != null && project.projectImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.network(
                                project.projectImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  "assets/project.png",
                                  width: 50,
                                  height: 50,
                                  opacity: const AlwaysStoppedAnimation(0.8),
                                ),
                              ),
                            )
                          : Image.asset(
                              "assets/project.png",
                              width: 50,
                              height: 50,
                              opacity: const AlwaysStoppedAnimation(0.8),
                            ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Obx(() {
                      final isFav = controller.isFavorite(project.projectId);
                      return GestureDetector(
                        onTap: () => controller.toggleFavorite(project.projectId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.black38 : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFav ? Colors.redAccent : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Project Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.blueAccent.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetailsDialog(BuildContext context, CommunityProject project, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image/Banner Area
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: project.projectImage != null && project.projectImage!.isNotEmpty
                        ? null
                        : LinearGradient(
                            colors: [
                              Colors.blueAccent.shade400,
                              Colors.blueAccent.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  ),
                  child: Stack(
                    children: [
                      if (project.projectImage != null && project.projectImage!.isNotEmpty)
                        Positioned.fill(
                          child: Image.network(
                            project.projectImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.shade400,
                                    Colors.blueAccent.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (project.projectImage == null || project.projectImage!.isEmpty)
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.architecture_rounded,
                            size: 150,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black26,
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      if (project.projectImage == null || project.projectImage!.isEmpty)
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                ),
                                child: const Icon(Icons.maps_home_work_outlined, color: Colors.white, size: 40),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent.withOpacity(0.1),
                              child: const Icon(Icons.person, color: Colors.blueAccent, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Project Author",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Project Title
                      Text(
                        project.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Description Area
                      Container(
                        height: 150,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.black26 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            project.description.isEmpty ? "No description provided." : project.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (project.projectData == null) {
                                    AppSnackbars.error(title: "Error", message: "Project data is not available");
                                    return;
                                  }
                                  
                                  final profileController = Get.find<ProfileController>();
                                  final homeController = Get.find<HomePageController>();
                                  
                                  if (profileController.canCreateProject(homeController.projects.length)) {
                                    try {
                                      Navigator.pop(context);
                                      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                                      
                                      final projectJson = jsonEncode(project.projectData);
                                      await ProjectService.instance.importProject(projectJson);
                                      
                                      Get.back(); // Remove loading
                                      AppSnackbars.success(
                                        title: "Success", 
                                        message: "Project added to your collection",
                                      );
                                    } catch (e) {
                                      Get.back(); // Remove loading
                                      AppSnackbars.error(title: "Error", message: "Failed to import project: $e");
                                    }
                                  } else {
                                    profileController.showLimitSnackbar();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Use Project", 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
