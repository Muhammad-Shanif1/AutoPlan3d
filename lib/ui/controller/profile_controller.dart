import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import '../services/api_service.dart';

import '../services/stripe_service.dart';
import '../view/auth/login_screen.dart';
import '../view/main_menu/pages/profile_pages/pricing_page.dart';
import 'auth/authcontroller.dart';

class ProfileController extends GetxController {
  final storage = GetStorage();
  final api = ApiService.instance;

  // Reactive variables
  final RxString name = 'Loading...'.obs;
  final RxString email = 'Loading...'.obs;
  final RxString phone = 'Loading...'.obs;
  final RxString subscription = 'free'.obs;
  final RxInt credits = 0.obs;
  final Rx<DateTime?> subscriptionExpiry = Rx<DateTime?>(null);
  final Rx<DateTime?> creditsResetAt = Rx<DateTime?>(null);
  final RxBool isGuest = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isOffline = false.obs;
  Timer? _connectivityTimer;
  
  final loadpurchase = false.obs;
  var selectedTab = 0.obs; 
  var selectedPlan = 0.obs; 

  @override
  void onInit() {
    super.onInit();
    
    final userData = storage.read('user');
    if (userData != null) {
      name.value = userData['name'] ?? '';
      email.value = userData['email'] ?? '';
      phone.value = userData['phone'] ?? '';
      subscription.value = userData['subscription'] ?? 'free';
      credits.value = userData['credits'] ?? (subscription.value == 'pro' ? 1000 : 40);
      subscriptionExpiry.value = userData['subscription_expiry'] != null
          ? DateTime.parse(userData['subscription_expiry']) 
          : null;
      creditsResetAt.value = userData['credits_reset_at'] != null
          ? DateTime.parse(userData['credits_reset_at'])
          : null;
      isGuest.value = false;
      _validateSubscription(); // Local check for expiry
    } else {
      isGuest.value = true;
      name.value = 'Guest User';
      email.value = 'guest@autoplan.com';
      phone.value = 'N/A';
      subscription.value = 'free';
      credits.value = 40;
    }
    
    _initData();
  }

  void refreshUserStatus() {
    final userData = storage.read('user');
    if (userData != null) {
      name.value = userData['name'] ?? '';
      email.value = userData['email'] ?? '';
      phone.value = userData['phone'] ?? '';
      subscription.value = userData['subscription'] ?? 'free';
      credits.value = userData['credits'] ?? (subscription.value == 'pro' ? 1000 : 40);
      subscriptionExpiry.value = userData['subscription_expiry'] != null
          ? DateTime.parse(userData['subscription_expiry']) 
          : null;
      creditsResetAt.value = userData['credits_reset_at'] != null
          ? DateTime.parse(userData['credits_reset_at'])
          : null;
      isGuest.value = false;
      _validateSubscription(); // Local check for expiry
    } else {
      isGuest.value = true;
      name.value = 'Guest User';
      email.value = 'guest@autoplan.com';
      phone.value = 'N/A';
      subscription.value = 'free';
      credits.value = 40;
    }
    fetchUserInfo();
  }

  /// Locally validate subscription expiry
  void _validateSubscription() {
    if (subscriptionExpiry.value != null && 
        subscriptionExpiry.value!.isBefore(DateTime.now()) && 
        subscription.value != 'free') {
      print('🚩 Subscription expired locally (${subscription.value} -> free)');
      subscription.value = 'free';

      // Update local storage to persist the expired state
      final userData = storage.read('user');
      if (userData != null) {
        userData['subscription'] = 'free';
        storage.write('user', userData);
      }
    }
  }

  Future<void> _initData() async {
    // Check connectivity first before doing anything else
    await _checkConnectivity();
    _startConnectivityTimer();
    fetchUserInfo();
  }

  void _startConnectivityTimer() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _checkConnectivity();
    });
  }

  @override
  void onClose() {
    _connectivityTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkConnectivity() async {
    try {
      // Pinging a hostname like google.com is a reliable way to check for actual internet access
      // because it requires a successful DNS lookup and network round-trip.
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      final bool offline = result.isEmpty || result[0].rawAddress.isEmpty;
      
      if (isOffline.value != offline) {
        print('📡 Connectivity changed: ${offline ? "OFFLINE" : "ONLINE"}');
        isOffline.value = offline;
      }
    } catch (e) {
      // If lookup fails (SocketException, Timeout, etc.), we are offline
      if (!isOffline.value) {
        print('📡 Connectivity changed: OFFLINE');
        isOffline.value = true;
      }
    }
  }

  Future<void> fetchUserInfo() async {
    if (isOffline.value) {
      _validateSubscription();
      return;
    }

    final userData = storage.read('user');
    final token = storage.read('token');

    if (userData == null || userData['id'] == null || token == null) {
      isGuest.value = true;
      return;
    }

    int userId = userData['id'];
    isGuest.value = false;
    isLoading.value = true;

    try {
      final response = await api.get('/user/get_user_info/$userId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        name.value = data['name'] ?? 'No Name';
        email.value = data['email'] ?? 'No Email';
        phone.value = data['phone'] ?? 'No Phone';
        subscription.value = data['subscription'] ?? 'free';
        credits.value = data['credits'] ?? (subscription.value == 'pro' ? 1000 : 40);
        subscriptionExpiry.value = data['subscription_expiry'] != null
            ? DateTime.parse(data['subscription_expiry']) 
            : null;
        creditsResetAt.value = data['credits_reset_at'] != null
            ? DateTime.parse(data['credits_reset_at'])
            : null;
        _validateSubscription();
        storage.write('user', data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Get.find<AuthController>().logout();
      }
    } catch (e) {
      print('Profile fetch error: $e');
      _validateSubscription(); // Fallback to local check if API fails
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedPlan.value = 0; 
  }

  void changePlan(int index) {
    selectedPlan.value = index;
  }

  void _showOfflineSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSnackbars.show(
        title: "Connection Error",
        message: "You are currently offline. Please check your internet connection to perform this action.",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      );
    });
  }

  void showPlansBottomSheet({required bool ispremium}) {
    Get.bottomSheet(
      PlanBottomSheet(ispremium: ispremium),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> saveProfile() async {
    if (isOffline.value) {
      _showOfflineSnackbar();
      return;
    }

    final userData = storage.read('user');
    final token = storage.read('token');
    if (userData == null || userData['id'] == null || token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.error(title: 'Error', message: 'Session expired. Please log in again.');
      });
      return;
    }

    int userId = userData['id'];
    isSaving.value = true;

    try {
      final response = await api.put(
        '/user/update_user_info/$userId',
        body: {
          'name': name.value,
          'email': email.value,
          'phone': phone.value,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        storage.write('user', data);
        refreshUserStatus(); // Update local reactive variables
        Get.back(); 
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.success(title: 'Success', message: 'Profile updated successfully');
        });
      } else {
        final error = jsonDecode(response.body);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.error(title: 'Error', message: error['detail'] ?? 'Failed to update profile');
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
      });
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (isOffline.value) {
      _showOfflineSnackbar();
      return;
    }

    final userData = storage.read('user');
    if (userData == null || userData['id'] == null) return;

    isSaving.value = true;
    try {
      final response = await api.put(
        '/user/update-password?user_id=${userData['id']}',
        body: {'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.success(title: 'Success', message: 'Password updated successfully');
        });
      } else {
        final error = jsonDecode(response.body);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.error(title: 'Error', message: error['detail'] ?? 'Failed to update password');
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
      });
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      final response = await api.post(
        '/user/verify-password-only',
        body: {'password': password},
        autoLogout: false, // Don't logout if password is wrong
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// TEMPORARY: Debug method to update subscription for testing
  Future<void> debugUpdateSubscription(String type) async {
    if (isGuest.value || isOffline.value) return;
    
    final userData = storage.read('user');
    if (userData == null || userData['id'] == null) return;

    isLoading.value = true;
    try {
      final response = await api.post(
        '/user/update-subscription?user_id=${userData['id']}&subscription_type=$type&subscription_days=30',
      );

      if (response.statusCode == 200) {
        await fetchUserInfo();
        AppSnackbars.success(title: 'Debug Success', message: 'Subscription updated to $type');
      } else {
        AppSnackbars.error(title: 'Debug Error', message: 'Failed to update subscription');
      }
    } catch (e) {
      AppSnackbars.error(title: 'Debug Error', message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCredits() async {
    if (isGuest.value || isOffline.value) return;

    try {
      final response = await api.get('/user/credits');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        credits.value = data['credits'];
        creditsResetAt.value = data['credits_reset_at'] != null
            ? DateTime.parse(data['credits_reset_at'])
            : null;
        
        // Update local storage
        final userData = storage.read('user');
        if (userData != null) {
          userData['credits'] = credits.value;
          userData['credits_reset_at'] = data['credits_reset_at'];
          storage.write('user', userData);
        }
      }
    } catch (e) {
      print('Error fetching credits: $e');
    }
  }

  bool canCreateProject(int currentProjectCount) {
    if (isGuest.value) {
      return currentProjectCount < 1;
    }

    // Always ensure we are checking the latest validated state
    _validateSubscription();
    final sub = subscription.value;

    if (sub == 'free' || sub == null) {
      return currentProjectCount < 3;
    } else if (sub == 'premium') {
      return currentProjectCount < 10;
    }
    
    // Pro or other plans allow unlimited
    return true;
  }

  bool hasEnoughCredits(int amount) {
    if (isGuest.value) return false;
    return credits.value >= amount;
  }

  void useCredits(int amount) {
    if (credits.value >= amount) {
      credits.value -= amount;
      // Ideally sync with backend here
      final userData = storage.read('user');
      if (userData != null) {
        userData['credits'] = credits.value;
        storage.write('user', userData);
      }
    }
  }

  void showLimitSnackbar() {
    bool isGuestUser = isGuest.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSnackbars.show(
        title: isGuestUser ? "Guest Limit Reach" : "Limit Finished!",
        message: isGuestUser
            ? "Guests are limited to 1 project. Sign in to create more!"
            : "Your plan limit has been reached. Upgrade to continue.",
        icon: Icon(
            isGuestUser ? Icons.info_outline : Icons.warning_rounded,
            color: Colors.white,
            size: 30
        ),
      );
    });
  }
}

class PlanBottomSheet extends StatelessWidget {
  final bool ispremium;

  PlanBottomSheet({super.key, required this.ispremium});
  final ProfileController controller = Get.find();

  Future<void> _subscribe(SubscriptionPlan plan) async {
    if (controller.isOffline.value) {
      controller._showOfflineSnackbar();
      return;
    }
    controller.loadpurchase.value = true;
    final success = await StripeService.instance.subscribe(plan: plan);

    if (success) {
      // Sync subscription status with backend
      try {
        final userData = controller.storage.read('user');
        if (userData != null && userData['id'] != null) {
          // Determine plan type from ID (e.g., 'pro-year' -> 'pro')
          final String planType = plan.id.startsWith('pro') ? 'pro' : 'premium';
          final int days = plan.id.endsWith('year') ? 365 : 30;
          
          await controller.api.post(
            '/user/update-subscription?user_id=${userData['id']}&subscription_type=$planType&subscription_days=$days',
          );
          // Refresh user info to ensure local state is perfectly in sync with server
          await controller.fetchUserInfo();
        }
      } catch (e) {
        print('⚠️ Backend sync failed after purchase: $e');
        // We don't fail the whole UI flow if just the sync fails, 
        // as the local Stripe status is already saved.
      }

      controller.loadpurchase.value = false;
      Get.back();
      Get.back();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.show(
          title: 'Success',
          message: 'Welcome to ${plan.name}!',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      });
    } else {
      controller.loadpurchase.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    // Always default to first plan (Yearly) when opening
    controller.selectedPlan.value = 0;
    
    // We only show the Pro plans as requested (Index 2 and 3 in StripeService)
    final yearlyPlan = StripeService.instance.plans[2];
    final monthlyPlan = StripeService.instance.plans[3];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Obx(() {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Your Plan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _planTile(
                title: "Yearly", 
                price: yearlyPlan.price, 
                subtitle: "BEST VALUE", 
                index: 0
              ),
              _planTile(
                title: "Monthly", 
                price: monthlyPlan.price, 
                index: 1
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  final isYearly = controller.selectedPlan.value == 0;
                  _subscribe(isYearly ? yearlyPlan : monthlyPlan);
                },
                child: controller.loadpurchase.value
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Continue", 
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
    );
  }

  Widget _planTile({required String title, required String price, String? subtitle, required int index}) {
    final isDarkMode = Get.isDarkMode;
    final isSelected = controller.selectedPlan.value == index;
    return GestureDetector(
      onTap: () => controller.changePlan(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blueAccent.withOpacity(isDarkMode ? 0.1 : 0.05) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blueAccent : (isDarkMode ? Colors.grey[500] : Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 16,
                        )
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600, 
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(
                            subtitle, 
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price, 
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
