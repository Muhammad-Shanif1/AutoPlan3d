import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/project_page_controller.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/models/project_model.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:flutter_unity_widget_example/ui/view/auth/login_screen.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/home_pages/new_project_screen.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/project_pages/help_page.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:intl/intl.dart';
import '../../../controller/home_page_controller.dart';
import '../../../services/share_project.dart';
import '../../../widgets/cloud_delete_alert_box.dart';
import '../../../widgets/delete_alert_box.dart';
import '../../../widgets/project_edit_bottom_sheet.dart';

class ProjectsPages extends StatelessWidget {
  final controller = Get.put(ProjectPageController());
  final HomePageController homecontroller=Get.find();


  // Get sorted projects based on selected option
  List getSortedProjects() {
    List<Project> sortedProjects = List.from(homecontroller.projects);

    if (controller.selectedSortOption.value == 'name') {
      sortedProjects.sort((a, b) => a.name.compareTo(b.name));
    } else if (controller.selectedSortOption.value == 'last_modified') {
      sortedProjects.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } else if (controller.selectedSortOption.value == 'created_at') {
      sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sortedProjects;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: Color(0xFF111827),
      //  Color(0xFF1F2937)
      body: CustomScrollView(
        slivers: [
          /// APP BAR
          SliverAppBar(
            backgroundColor: isDarkMode ? const Color(0xFF111827): Colors.white,
            surfaceTintColor: Colors.transparent,
            floating: true,
            title: Obx(() {
              final profileController = Get.find<ProfileController>();
              return Text(
                profileController.isGuest.value ? "Local Projects" : "My Projects",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              );
            }),
            actions: [
              Obx(() {
                final profileController = Get.find<ProfileController>();
                if (profileController.isGuest.value) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${profileController.credits.value}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Guest Sign In Button
              Obx(() {
                final profileController = Get.find<ProfileController>();
                return profileController.isGuest.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextButton.icon(
                          onPressed: () => Get.offAll(() => LoginView()),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            foregroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              // Help Button
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: GestureDetector(
              //     onTap: () {
              //       Get.to(() => HelpScreen());
              //     },
              //     child: Container(
              //       height: 30,
              //       width: 30,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         border: Border.all(
              //           color: isDarkMode ? Colors.white : Colors.black,
              //           width: 2.5,
              //         ),
              //       ),
              //       child: Icon(
              //         Icons.question_mark_outlined,
              //         size: 18,
              //         color: isDarkMode ? Colors.white : Colors.black87,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 10),
            ],
            pinned: true,
            bottom: const PreferredSize(preferredSize: Size(12, 0), child: SizedBox()),
          ),

          /// HEADER with sort indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 15, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sort dropdown
                  Obx(() => Container(
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedSortOption.value,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        dropdownColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.setSortOption(newValue);
                          }
                        },
                        items: [
                          {'value': 'last_modified', 'label': 'Last Modified'},
                          {'value': 'created_at', 'label': 'Created Date'},
                          {'value': 'name', 'label': 'Name'},
                        ].map<DropdownMenuItem<String>>((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'] as String,
                            child: Text(
                              "Sort by ${option['label']}",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )),

                  // View toggle button
                  InkWell(
                    onTap: () {
                      controller.currentdesign.value = !controller.currentdesign.value;
                    },
                    child: Obx(() => Image.asset(
                      !controller.currentdesign.value
                          ? "assets/bulletmenuicon.png"
                          : "assets/foursquar.jpg",
                      height: 20,
                      width: 20,
                      // color: isDarkMode ? Colors.white : null,
                    )),
                  ),
                ],
              ),
            ),
          ),

          /// Projects List/Grid with sorting
          Obx(() {
            final sortedProjects = getSortedProjects();

            return controller.currentdesign.value
                ? SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return newProjectTile(context: context);
                    } else {
                      final Project project = sortedProjects[index - 1];
                      return projectTile(
                        project: project,
                        context: context,
                        title: project.name,
                        date: "Created: ${DateFormat("dd/MM/yyyy").format(project.createdAt)}",
                        image: 'https://picsum.photos/300/300?random=1',
                      );
                    }
                  },
                  childCount: sortedProjects.length + 1,
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == 0) {
                      return newProjectCard(context: context);
                    } else {
                      final Project project = sortedProjects[index - 1];
                      return projectCard(
                        project: project,
                        context: context,
                        title: project.name,
                        date: "Created: ${DateFormat("dd/MM/yyyy").format(project.createdAt)}",
                        image:'https://picsum.photos/300/300?random=1',
                      );
                    }
                  },
                  childCount: sortedProjects.length + 1,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.82,
                ),
              ),
            );
          }),

          SliverToBoxAdapter(
            child: SizedBox(height: 120),
          )
        ],
      ),
    );
  }
}

Widget newProjectCard({required BuildContext context}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: InkWell(
          onTap: () {
            Get.to(() => StartProjectScreen());
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.shade100,
                  Colors.blueAccent.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New project",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Tap to get started",
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.blueAccent.shade100,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "New project",
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      Text(
        "Tap + to get started",
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  );
}

Widget projectCard({
  required Project project,
  required BuildContext context,
  required String title,
  required String date,
  required String image,
}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// VISIBILITY ICON
      Expanded(
        child: GestureDetector(
          onTap: () {
            // Get.to(() => HouseSceneScreen(project: project,issnap: false,));
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              project.visibility == "Public" ? Icons.public : Icons.lock_outline,
              size: 40,
              color: Colors.blueAccent.shade400,
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      /// TITLE + MENU
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              showCustomBottomSheet(context, title,project);
            },
            child: Icon(
              Icons.more_vert,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      /// DATE
      Text(
        date,
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  );
}

void showCustomBottomSheet(BuildContext context, String title,Project project) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Material(
        color: isDarkMode ? const Color(0xFF111827): Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 16, right: 16, left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
            /// MENU ITEMS
            buildItem(context, Icons.copy, "Make a copy",ontap:  () {
              final profileController = Get.find<ProfileController>();
              final homecontroller = Get.find<HomePageController>();
              int len = homecontroller.projects.length;
              
              if (profileController.canCreateProject(len)) {
                ProjectService.instance.duplicateProject(project.id);
                Get.back();
              } else {
                Get.back(); // Close bottom sheet
                profileController.showLimitSnackbar();
              }
            },),
            buildItem(context, Icons.edit, "Edit",ontap:  () {
              final profileController = Get.find<ProfileController>();
              if (project.cloudId != null && profileController.isOffline.value) {
                AppSnackbars.warning(title: 'Offline', message: 'Cannot edit cloud projects while offline');
                return;
              }
              Get.back(); // Close the menu bottom sheet
              showProjectEditBottomSheet(
                context: context,
                initialName: project.name,
                initialDescription: project.description,
                initialVisibility: project.visibility,
                onSave: (newName, newDesc, newVisibility) async {
                  try {
                    await ProjectService.instance.updateProject(
                      projectId: project.id,
                      name: newName,
                      description: newDesc,
                      visibility: newVisibility,
                    );
                    AppSnackbars.success(title: 'Success', message: 'Project updated successfully');
                  } catch (e) {
                    AppSnackbars.error(title: 'Error', message: e.toString());
                  }
                },
              );
            },),
            // buildItem(context, Icons.photo, "Send to gallery",ontap: (){
            //   // Get.to(HouseSceneScreen(project: project, issnap: true));
            // }),
            buildItem(context, Icons.share, "Share",ontap: (){
              ProjectShareHelper.shareProjectAsJsonFile(project);
            }),
            buildItem(context, Icons.delete, "Delete", isDelete: true,ontap: () {
              final profileController = Get.find<ProfileController>();
              
              if (project.cloudId != null) {
                if (profileController.isOffline.value) {
                  AppSnackbars.warning(title: 'Offline', message: 'Cannot delete cloud projects while offline');
                  return;
                }
                
                if (!profileController.isGuest.value) {
                  Get.back(); // Close bottom sheet
                  showDialog(
                    context: context,
                    builder: (context) => CloudDeleteAlertBox(
                      projectName: project.name,
                      onDelete: (password) async {
                        await ProjectService.instance.deleteProject(project.id, password: password);
                        AppSnackbars.success(title: 'Success', message: 'Project deleted from cloud and local');
                      },
                    ),
                  );
                  return;
                }
              }

              // Local deletion for offline projects or guest projects
              showDeleteProjectDialog(
                context: context,
                projectName: project.name,
                onDelete: () async {
                  await ProjectService.instance.deleteProject(project.id);
                  Get.back();
                },
              );
            },),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

/// Reusable Item Widget
Widget buildItem(BuildContext context, IconData icon, String text, {bool isDelete = false,ontap}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return ListTile(
    leading: Icon(
      icon,
      color: isDelete ? Colors.red : (isDarkMode ? Colors.white70 : Colors.black54),
    ),
    title: Text(
      text,
      style: TextStyle(
        color: isDelete
            ? Colors.red
            : (isDarkMode ? Colors.white : Colors.black87),
      ),
    ),
    onTap: ontap
  );
}

Widget projectTile({
  required Project project,
  required BuildContext context,
  required String title,
  required String date,
  required String image,
}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return ListTile(
    onTap: () {
      // Get.to(() => HouseSceneScreen(project: project,issnap: false,));
    },
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    /// VISIBILITY ICON
    leading: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        project.visibility == "Public" ? Icons.public : Icons.lock_outline,
        size: 24,
        color: Colors.blueAccent.shade400,
      ),
    ),
    /// TITLE + DATE
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    ),
    subtitle: Text(
      date,
      style: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
    ),
    /// MENU BUTTON
    trailing: IconButton(
      icon: Icon(
        Icons.more_vert,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      onPressed: () {
        showCustomBottomSheet(context, title,project);
      },
    ),
  );
}

Widget newProjectTile({required BuildContext context}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    leading: Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Container(
          height: 30,
          width: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            Icons.add,
            color: Colors.blueAccent.shade100,
          ),
        ),
      ),
    ),
    subtitle: MyText(
      text: "Tap + to get started",
      color: isDarkMode ? Colors.grey[400] : Colors.black54,
    ),
    title: Text(
      "Create New Project",
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    ),
    onTap: () {
      Get.to(() => StartProjectScreen());
    },
  );
}
