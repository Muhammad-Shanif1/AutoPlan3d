import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/view/auth/login_screen.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/full_screen_image_view.dart';
import 'package:intl/intl.dart';
import '../../../services/camera_snapshot_service.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final GalleryController controller = Get.put(GalleryController());

  @override
  void initState() {
    super.initState();
    // Load snapshots when the page is first initialized
    controller.loadSnapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
            surfaceTintColor: Colors.transparent,
            floating: true,
            pinned: true,
            title: Text(
              "Gallery",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
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
              Obx(() {
                final profileController = Get.find<ProfileController>();
                return profileController.isGuest.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            ],
            // ── TABS ─────────────────────────────────────────────────────────
            bottom: PreferredSize(
              preferredSize: Size(MediaQuery.sizeOf(context).width, 50),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Floor Plans tab
                  GestureDetector(
                    onTap: () => controller.changeTab(0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: MyText(
                              color: controller.selectedTab.value == 0
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : (isDarkMode ? Colors.white54 : Colors.black54),
                              text: "Floor Plans",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: 4,
                            width: 100,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorites tab
                  GestureDetector(
                    onTap: () => controller.changeTab(1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                MyText(
                                  text: "My Favorite",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: controller.selectedTab.value == 1
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                                Icon(
                                  Icons.favorite,
                                  size: 18,
                                  color: controller.selectedTab.value == 1
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : (isDarkMode ? Colors.white54 : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 4,
                            width: 120,
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ),

          // ── CONTENT ────────────────────────────────────────────────────────
          Obx(() {
            final list = controller.selectedTab.value == 0
                ? controller.snapshots.toList()
                : controller.favorites;

            if (list.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    controller.selectedTab.value == 0
                        ? 'No snapshots yet.\nCapture a top view from the scene!'
                        : 'No favorites yet.\nTap ♥ on a snapshot to save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }

            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          controller.currentdesign.value = !controller.currentdesign.value;
                        },
                        child: Obx(() => Image.asset(
                          !controller.currentdesign.value
                              ? "assets/bulletmenuicon.png"
                              : "assets/foursquar.jpg",
                          height: 20,
                          width: 20,
                        )),
                      ),
                    ),
                  ),
                ),
                Obx(() => controller.currentdesign.value
                  ? SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final snap = list[index];
                            return snapshotTile(
                              snap: snap,
                              controller: controller,
                              isDarkMode: isDarkMode,
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final snap = list[index];
                            return snapshotCard(
                              snap: snap,
                              controller: controller,
                              isDarkMode: isDarkMode,
                            );
                          },
                          childCount: list.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                      ),
                    ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

Widget snapshotTile({
  required CameraSnapshot snap,
  required GalleryController controller,
  required bool isDarkMode,
}) {
  final file = File(snap.filePath);
  return GestureDetector(
    onTap: () => Get.to(() => FullScreenImageView(
      imagePath: snap.filePath,
      title: controller.formatDate(snap.capturedAt),
    )),
    child: Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.black87 : Colors.black45,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                color: isDarkMode ? Colors.grey[800] : const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: Icon(Icons.broken_image,
                    size: 40,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 10,
            child: MyText(
              text: DateFormat("dd/MM/yyyy, h:mm a").format(snap.capturedAt),
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Positioned(
            bottom: 10, right: 10,
            child: GestureDetector(
              onTap: () => controller.toggleFavorite(snap.filePath),
              child: Icon(
                snap.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: snap.isFavorite ? Colors.red : Colors.black,
                size: 30,
              ),
            ),
          ),
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(snap, controller),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black45,
                child: Icon(Icons.delete, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget snapshotCard({
  required CameraSnapshot snap,
  required GalleryController controller,
  required bool isDarkMode,
}) {
  final file = File(snap.filePath);
  return GestureDetector(
    onTap: () => Get.to(() => FullScreenImageView(
      imagePath: snap.filePath,
      title: controller.formatDate(snap.capturedAt),
    )),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? Colors.black87 : Colors.black45,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                color: isDarkMode ? Colors.grey[800] : const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: Icon(Icons.broken_image,
                    size: 30,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => controller.toggleFavorite(snap.filePath),
              child: Icon(
                snap.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: snap.isFavorite ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(snap, controller),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black45,
                child: Icon(Icons.delete, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDeleteDialog(CameraSnapshot snap, GalleryController controller) async {
  final confirm = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Delete Snapshot'),
      content: const Text('Remove this snapshot?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirm==true) {
    controller.deleteSnapshot(snap.filePath);
    controller.loadSnapshots();
  }
}