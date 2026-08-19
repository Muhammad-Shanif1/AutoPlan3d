import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import '../../../controller/profile_controller.dart';
import '../../../widgets/common_edit_bottom_sheet.dart';
import '../../../widgets/reauth_dialog.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = Colors.blueAccent.shade400;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Obx(() => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                
                // Section Title
                _buildSectionHeader('PERSONAL INFORMATION', isDarkMode),
                const SizedBox(height: 12),
                
                // Information Card
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.25) 
                            : const Color(0xFFE2E8F0).withOpacity(0.6),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildModernField(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: profileController.name.value,
                        isDarkMode: isDarkMode,
                        onTap: () => _verifyPasswordAndAction(
                          context,
                          () => showEditBottomSheet(
                            context: context,
                            title: 'Edit Name',
                            hint: 'Enter your full name',
                            currentValue: profileController.name.value,
                            onSave: (value) {
                              if (value != null && value.isNotEmpty) {
                                profileController.name.value = value;
                              }
                            },
                          ),
                        ),
                      ),
                      _buildDivider(isDarkMode),
                      _buildModernField(
                        context: context,
                        icon: Icons.alternate_email_rounded,
                        label: 'Email Address',
                        value: profileController.email.value,
                        isDarkMode: isDarkMode,
                        onTap: () => _verifyPasswordAndAction(
                          context,
                          () => showEditBottomSheet(
                            context: context,
                            title: 'Edit Email',
                            hint: 'Enter your email',
                            currentValue: profileController.email.value,
                            keyboardType: TextInputType.emailAddress,
                            onSave: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (GetUtils.isEmail(value)) {
                                  profileController.email.value = value;
                                } else {
                                  AppSnackbars.warning(title: 'Invalid Email', message: 'Please enter a valid email address');
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      _buildDivider(isDarkMode),
                      _buildModernField(
                        context: context,
                        icon: Icons.phone_android_rounded,
                        label: 'Phone Number',
                        value: profileController.phone.value,
                        isDarkMode: isDarkMode,
                        onTap: () => _verifyPasswordAndAction(
                          context,
                          () => showEditBottomSheet(
                            context: context,
                            title: 'Edit Phone',
                            hint: 'Enter your phone number',
                            currentValue: profileController.phone.value,
                            keyboardType: TextInputType.phone,
                            onSave: (value) {
                              if (value != null && value.isNotEmpty) {
                                profileController.phone.value = value;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Security Section
                _buildSectionHeader('SECURITY', isDarkMode),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.2)
                            : const Color(0xFFE2E8F0).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _buildModernField(
                    context: context,
                    icon: Icons.lock_outline_rounded,
                    label: 'Password',
                    value: '••••••••••••',
                    isDarkMode: isDarkMode,
                    onTap: () => _verifyPasswordAndAction(
                      context,
                      () => showEditBottomSheet(
                        context: context,
                        title: 'Update Password',
                        hint: 'Enter new password',
                        currentValue: '',
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        onSave: (value) {
                          if (value != null && value.length >= 8) {
                            profileController.updatePassword(value);
                          } else {
                            AppSnackbars.error(title: 'Error', message: 'Password must be at least 8 characters');
                          }
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Save Button
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: profileController.isSaving.value 
                        ? null 
                        : () => profileController.saveProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: profileController.isSaving.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )),
          
          // Blur/Loading overlay when saving
          Obx(() => profileController.isSaving.value
              ? Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.blueAccent,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isEmpty ? 'Not set' : value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_note_rounded,
                size: 22,
                color: isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDarkMode ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
      ),
    );
  }

  void _verifyPasswordAndAction(BuildContext context, VoidCallback onVerified) {
    showDialog(
      context: context,
      builder: (context) => ReauthDialog(onVerified: onVerified),
    );
  }
}
