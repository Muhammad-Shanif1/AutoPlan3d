import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/services/stripe_service.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/gallery_page.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/home_page.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/home_pages/new_project_screen.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/profile_page.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/projects_pages.dart';

import '../../controller/home_page_controller.dart';

class MenuScreen1 extends StatelessWidget {
  final MenubarControlller controller = Get.put(MenubarControlller());
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    print(StripeService.instance.info);
    return Scaffold(
      extendBody: true,
      backgroundColor: ThemeHelper.scaffoldBackgroundColor,

      body: Obx(() => Column(
            children: [
              if (profileController.isGuest.value)
                SafeArea(
                  // minimum: EdgeInsets.symmetric(vertical: 0),
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    color: Colors.orange.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Center(
                      child: Text(
                        "GUEST MODE - Login to Sync & Unlock Premium",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              else if (profileController.isOffline.value)
                SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    color: Colors.redAccent.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Center(
                      child: Text(
                        "OFFLINE MODE - Limited Functionality",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: controller.controller,
                  onPageChanged: (value) {
                    controller.currentIndex.value = value;
                    print("page view");
                  },
                  scrollDirection: Axis.horizontal,
                  children: [
                    HomePage(),
                    ProjectsPages(),
                    GalleryPage(),
                    ProfilePage(),
                  ],
                ),
              ),
            ],
          )),

      // Floating Button
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: Material(
          elevation: 20,
          shadowColor: Colors.blueAccent.shade700,
          shape: const CircleBorder(),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            elevation: 0, // Set to 0 to use Material's shadow
            backgroundColor: Colors.blueAccent.shade400,
            tooltip: "Create project",
            onPressed: () {
              Get.to(() => StartProjectScreen());
            },
            child: const Icon(
              Icons.add,
              size: 35,
              color: Colors.white,
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        // color: ThemeHelper.bottomAppBarColor,
        // shadowColor: ThemeHelper.shadowColor,
        height: 70,
        notchMargin: 5,
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Icons
              Row(
                children: [
                  Obx(
                        () => IconButton(
                      icon: Image.asset(
                        'assets/home_icon.png',
                        width: 28,
                        height: 28,
                        color: controller.currentIndex.value == 0
                            ? ThemeHelper.iconActiveColor
                            : ThemeHelper.iconInactiveColor,
                      ),
                      onPressed: () => controller.onpagechange(0),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Obx(
                        () => IconButton(
                      icon: Image.asset(
                        'assets/project.png',
                        width: 28,
                        height: 28,
                        color: controller.currentIndex.value == 1
                            ? ThemeHelper.iconActiveColor
                            : ThemeHelper.iconInactiveColor,
                      ),
                      onPressed: () => controller.onpagechange(1),
                    ),
                  ),
                ],
              ),

              // Right Icons
              Row(
                children: [
                  Obx(
                        () => IconButton(
                      icon: Image.asset(
                        'assets/gallery.png',
                        width: 28,
                        height: 28,
                        color: controller.currentIndex.value == 2
                            ? ThemeHelper.iconActiveColor
                            : ThemeHelper.iconInactiveColor,
                      ),
                      onPressed: () => controller.onpagechange(2),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Obx(
                        () => IconButton(
                      icon: Image.asset(
                        'assets/profile.png',
                        width: 28,
                        height: 28,
                        color: controller.currentIndex.value == 3
                            ? ThemeHelper.iconActiveColor
                            : ThemeHelper.iconInactiveColor,
                      ),
                      onPressed: () => controller.onpagechange(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}