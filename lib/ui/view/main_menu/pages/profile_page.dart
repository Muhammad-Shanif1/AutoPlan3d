import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/services/stripe_service.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/profile_pages/about_page.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/profile_pages/pricing_page.dart';
import 'package:flutter_unity_widget_example/ui/view/main_menu/pages/project_pages/help_page.dart';
import 'package:flutter_unity_widget_example/ui/controller/auth/authcontroller.dart';
import 'package:flutter_unity_widget_example/ui/widgets/delete_account_dialog.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:intl/intl.dart';
import 'edit_profile.dart';
import '../../auth/legal_screen.dart';

class ProfilePage extends StatelessWidget {
  final controller = Get.find<ProfileController>();
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
      body: Obx(() => Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    title: Text(
                      "Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          if (controller.isGuest.value || controller.isOffline.value) {
                            return;
                          }
                          Get.to(() => EditProfileView());
                        },
                        child: Opacity(
                          opacity: (controller.isGuest.value || controller.isOffline.value) ? 0.5 : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MyText(
                              text: "Edit   ",
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      )
                    ],
                    pinned: true,
                    bottom: const PreferredSize(preferredSize: Size(12, 0), child: SizedBox()),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              /// Profile Card
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.4)
                                          : Colors.blueAccent.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    children: [
                                      // Subtle decorative circles
                                      Positioned(
                                        top: -30,
                                        right: -30,
                                        child: CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.blueAccent.withOpacity(isDarkMode ? 0.05 : 0.03),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        controller.name.value,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                          color: isDarkMode ? Colors.white : Colors.black87,
                                                          letterSpacing: -0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (!controller.isGuest.value)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blueAccent.withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            controller.subscription.value.toUpperCase(),
                                                            style: const TextStyle(
                                                              color: Colors.blueAccent,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w800,
                                                              letterSpacing: 1,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            
                                            const SizedBox(height: 24),
                                            
                                            _buildProfileInfoRow(
                                              context, 
                                              Icons.email_outlined, 
                                              "Email", 
                                              controller.email.value,
                                              isDarkMode
                                            ),
                                            const SizedBox(height: 16),
                                            _buildProfileInfoRow(
                                              context, 
                                              Icons.phone_android_outlined, 
                                              "Phone", 
                                              controller.phone.value,
                                              isDarkMode
                                            ),
                                            
                                            const SizedBox(height: 28),

                                            /// Upgrade Button or Expiry Date
                                            if (controller.subscription.value == 'pro' && controller.subscriptionExpiry.value != null)
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
                                                        const SizedBox(width: 8),
                                                        const Text(
                                                          "Pro Plan Active",
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Expires on: ${DateFormat('dd MMM yyyy').format(controller.subscriptionExpiry.value!)}",
                                                      style: TextStyle(
                                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              GestureDetector(
                                                onTap: () {
                                                  if (controller.isOffline.value) {
                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                      AppSnackbars.show(
                                                        title: "Connection Error",
                                                        message: "You are currently offline. Please check your internet connection to perform this action.",
                                                        backgroundColor: Colors.orange.withOpacity(0.8),
                                                        colorText: Colors.white,
                                                        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
                                                      );
                                                    });
                                                    return;
                                                  }
                                                  Get.to(() => PricingScreen());
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 52,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.blueAccent.shade400,
                                                        const Color(0xFF2563EB),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blueAccent.withOpacity(0.3),
                                                        blurRadius: 12,
                                                        offset: const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Upgrade Plan",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            if (!controller.isGuest.value) ...[
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () => controller.debugUpdateSubscription('pro'),
                                                      child: Container(
                                                        height: 45,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.orange.withOpacity(0.5)),
                                                          borderRadius: BorderRadius.circular(16),
                                                          color: controller.subscription.value == 'pro' 
                                                              ? Colors.orange.withOpacity(0.1) 
                                                              : Colors.transparent,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Debug: Pro",
                                                            style: TextStyle(
                                                              color: Colors.orange.shade700,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () => controller.debugUpdateSubscription('free'),
                                                      child: Container(
                                                        height: 45,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                                          borderRadius: BorderRadius.circular(16),
                                                          color: controller.subscription.value == 'free' 
                                                              ? Colors.grey.withOpacity(0.1) 
                                                              : Colors.transparent,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Debug: Free",
                                                            style: TextStyle(
                                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// Help title
                              Text(
                                "Help",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),

                              buildTile(
                                context,
                                Icons.mail_outline,
                                "FAQs & Report",
                                "",
                                onTap: () {
                                  Get.to(() => HelpScreen());
                                },
                              ),
                              buildTile(
                                context,
                                Icons.info_outline,
                                "About",
                                "",
                                onTap: () {
                                  Get.to(() => AboutScreen());
                                },
                              ),
                              buildTile(
                                context,
                                Icons.gavel_rounded,
                                "Terms of Service",
                                "",
                                onTap: () {
                                  Get.to(() => const LegalScreen(
                                        title: 'Terms of Service',
                                        content: LegalContent.termsOfService,
                                      ));
                                },
                              ),
                              buildTile(
                                context,
                                Icons.privacy_tip_outlined,
                                "Privacy Policy",
                                "",
                                onTap: () {
                                  Get.to(() => const LegalScreen(
                                        title: 'Privacy Policy',
                                        content: LegalContent.privacyPolicy,
                                      ));
                                },
                              ),

                              const SizedBox(height: 30),

                              GestureDetector(
                                onTap: () {
                                  if (controller.isOffline.value) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      AppSnackbars.warning(
                                        title: 'Offline',
                                        message: 'Cannot logout while offline. Please connect to internet to sync your data.',
                                      );
                                    });
                                    return;
                                  }
                                  authController.logout();
                                },
                                child: Opacity(
                                  opacity: controller.isOffline.value ? 0.5 : 1.0,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blueAccent.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: MyText(
                                        text: "Logout",
                                        color: Colors.blueAccent.shade400,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  if (controller.isOffline.value) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      AppSnackbars.warning(title: 'Offline', message: 'Cannot delete account while offline');
                                    });
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) => const DeleteAccountDialog(),
                                  );
                                },
                                child: Opacity(
                                  opacity: controller.isOffline.value ? 0.5 : 1.0,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: MyText(
                                        text: "Delete Account",
                                        color: Colors.red.shade400,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 70),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              if (controller.isGuest.value)
                Positioned.fill(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 60,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Login Required",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Please login to access your profile and premium features.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.offAllNamed('/');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Go to Login",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

/// List Tile Widget
Widget buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String trailing, {
      bool grey = false,
      VoidCallback? onTap,
    }) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  return Column(
    children: [
      ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Text(
          trailing,
          style: TextStyle(
            color: grey
                ? (isDarkMode ? Colors.grey[500] : Colors.grey)
                : Colors.blueAccent.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Divider(
        height: 1,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    ],
  );
}

Widget _buildProfileInfoRow(BuildContext context, IconData icon, String label, String value, bool isDarkMode) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blueAccent.withOpacity(0.1) : Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon, 
          size: 18, 
          color: Colors.blueAccent.shade400
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildInfoRow(BuildContext context, IconData icon, String value) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    ],
  );
}
