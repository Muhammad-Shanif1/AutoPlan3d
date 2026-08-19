import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'auth/login_screen.dart';
import '../constants/libraries/app_libraries.dart';
import '../controller/auth/authcontroller.dart';
import '../controller/profile_controller.dart';
import '../controller/themeservier.dart';
import '../services/camera_snapshot_service.dart';
import '../services/project_services.dart';
import '../services/stripe_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RxDouble _loadingProgress = 0.0.obs;
  final RxString _loadingStatus = "Initializing...".obs;

  @override
  void initState() {
    super.initState();
    _startBootProcess();
  }

  Future<void> _startBootProcess() async {
    try {
      final storage = GetStorage();
      // Small initial delay to allow UI to settle
      await Future.delayed(const Duration(seconds: 1));

      // 1. Initialize core storage & GetX services
      _loadingStatus.value = "Loading settings...";
      _loadingProgress.value = 0.2;
      await Get.putAsync(() async => ThemeService());
      
      _loadingStatus.value = "Preparing account...";
      _loadingProgress.value = 0.4;
      Get.put(AuthController(), permanent: true);
      final profileController = Get.put(ProfileController(), permanent: true);
      
      // Ensure profile data is refreshed from server if online
      if (storage.hasData('token')) {
        _loadingStatus.value = "Fetching profile...";
        await profileController.fetchUserInfo();
      }

      await Future.delayed(const Duration(seconds: 1));

      // 2. Initialize application services
      _loadingStatus.value = "Loading projects...";
      _loadingProgress.value = 0.6;
      await ProjectService.instance.init();
      
      // Sync projects from cloud during splash if logged in
      if (storage.hasData('token')) {
        _loadingStatus.value = "Syncing cloud projects...";
        await ProjectService.instance.performFullSync(showSnackbars: false);
      }

      await Future.delayed(const Duration(seconds: 1));

      _loadingStatus.value = "Setting up camera...";
      _loadingProgress.value = 0.8;
      await CameraSnapshotService.instance.init();

      await Future.delayed(const Duration(seconds: 1));

      _loadingStatus.value = "Checking subscriptions...";
      _loadingProgress.value = 0.9;
      StripeService.instance.init();

      await Future.delayed(const Duration(seconds: 1));

      _loadingProgress.value = 1.0;
      _loadingStatus.value = "Ready!";

      // Final short delay for smooth transition
      await Future.delayed(const Duration(seconds: 1));
      
      _navigateToNext();
    } catch (e) {
      debugPrint("Boot error: $e");
      // You might want to show an error message or retry button here
      _loadingStatus.value = "Something went wrong. Please restart.";
    }
  }

  void _navigateToNext() {
    final storage = GetStorage();
    final bool isLoggedIn = storage.hasData('token');
    
    if (isLoggedIn) {
      Get.offAll(() => MenuScreen1());
    } else {
      Get.offAll(() => LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      backgroundColor: Color.fromARGB(255, 7, 14, 24),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with rounded corners and premium shadow
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(54),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(54),
                    child: Image.asset(
                      'assets/splash_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Loading Section
            Positioned(
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF1E293B) 
                            : Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Obx(() => Text(
                      _loadingStatus.value,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        letterSpacing: 0.5
                      ),
                    )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
