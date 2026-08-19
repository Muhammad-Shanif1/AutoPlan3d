import 'dart:convert';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/view/auth/signup_screen.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_unity_widget_example/ui/services/project_services.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import '../../services/api_service.dart';
import '../profile_controller.dart';

class AuthController extends GetxController {
  final storage = GetStorage();
  
  // Base URL is now handled in ApiService
  final api = ApiService.instance;

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  
  // OTP and Reset Password Controllers
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final FocusNode confirmNewPasswordFocusNode = FocusNode();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool iagree = false.obs;
  final RxString selectedCountryCode = '+1'.obs;
  final passwordText = ''.obs;
  
  // Forgot Password Steps: 0 = Email, 1 = OTP, 2 = New Password
  final RxInt forgotPasswordStep = 0.obs;
  int? forgotUserId;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(() {
      passwordText.value = passwordController.value.text;
    });
    
    // Auto-fill email if remember me was used
    emailController.text = storage.read('saved_email') ?? '';
    rememberMe.value = storage.read('remember_me') ?? false;

    // Handle OTP backspace logic
    for (int i = 0; i < 6; i++) {
      otpFocusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
          if (otpControllers[i].text.isEmpty && i > 0) {
            otpFocusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    forgotEmailController.dispose();
    newPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmNewPasswordController.dispose();
    confirmNewPasswordFocusNode.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  // Login method
  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final response = await api.post(
          '/user/login',
          requireAuth: false,
          body: {
            'email': emailController.text.trim(),
            'password': passwordController.text,
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          // Save token and user info
          storage.write('token', data['token']);
          storage.write('user', data['user']);

          // Refresh ProfileController state
          Get.find<ProfileController>().refreshUserStatus();
          
          // Re-initialize projects for the logged-in user
          await ProjectService.instance.reInitialize();

          if (rememberMe.value) {
            storage.write('saved_email', emailController.text.trim());
            storage.write('remember_me', true);
          } else {
            storage.remove('saved_email');
            storage.write('remember_me', false);
          }

          AppSnackbars.success(title: 'Success', message: 'Welcome back!');
          Get.offAll(() => MenuScreen1());
        } else {
          String message = 'Invalid credentials';
          try {
            final error = jsonDecode(response.body);
            message = error['detail'] ?? message;
          } catch (e) {
            if (response.statusCode == 401) {
              message = 'Account not found. Please create an account first.';
            }
          }
          
          AppSnackbars.error(title: 'Login Failed', message: message);
        }
      } catch (e) {
        AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Signup method
  Future<void> signup() async {
    if (signupFormKey.currentState!.validate()) {
      if (!iagree.value) {
        AppSnackbars.warning(title: 'Agreements', message: 'Please agree to the Terms and Conditions');
        return;
      }

      isLoading.value = true;
      try {
        final response = await api.post(
          '/user/register',
          requireAuth: false,
          body: {
            'name': fullNameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': '${selectedCountryCode.value}${phoneController.text.trim()}',
            'password': passwordController.text,
          },
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          
          storage.write('token', data['token']);
          storage.write('user', data['user']);

          // Refresh ProfileController state
          Get.find<ProfileController>().refreshUserStatus();

          // Re-initialize projects for the new user
          await ProjectService.instance.reInitialize();

          AppSnackbars.success(title: 'Success', message: 'Account created! Welcome.');
          Get.offAll(() => MenuScreen1());
        } else {
          final error = jsonDecode(response.body);
          AppSnackbars.error(title: 'Signup Failed', message: error['detail'] ?? 'Check your details');
        }
      } catch (e) {
        AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Forgot password - Step 1: Send OTP
  Future<void> forgotPasswordSubmit() async {
    if (forgotEmailController.text.isEmpty || !GetUtils.isEmail(forgotEmailController.text)) {
      AppSnackbars.warning(title: 'Invalid Email', message: 'Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      final response = await api.post(
        '/user/forget-password?email=${forgotEmailController.text.trim()}',
        requireAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        forgotUserId = data['user_id'];
        forgotPasswordStep.value = 1;
        
        Future.delayed(const Duration(milliseconds: 100), () {
          otpFocusNodes[0].requestFocus();
        });
        AppSnackbars.info(title: 'Success', message: 'OTP sent to your email');
      } else {
        final error = jsonDecode(response.body);
        AppSnackbars.error(title: 'Error', message: error['detail'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password - Step 2: Verify OTP
  Future<void> verifyOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      AppSnackbars.warning(title: 'Invalid OTP', message: 'Please enter the 6-digit code');
      return;
    }

    isLoading.value = true;
    try {
      final response = await api.post(
        '/user/verify-otp',
        requireAuth: false,
        body: {
          'email': forgotEmailController.text.trim(),
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        forgotUserId = data['user_id'];
        forgotPasswordStep.value = 2;
        
        Future.delayed(const Duration(milliseconds: 100), () {
          newPasswordFocusNode.requestFocus();
        });
        AppSnackbars.success(title: 'Verified', message: 'Please set your new password');
      } else {
        final error = jsonDecode(response.body);
        AppSnackbars.error(title: 'Invalid OTP', message: error['detail'] ?? 'Verification failed');
      }
    } catch (e) {
      AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password - Step 3: Update Password
  Future<void> updatePassword() async {
    if (newPasswordController.text.isEmpty || newPasswordController.text.length < 8) {
      AppSnackbars.error(title: 'Error', message: 'Password must be at least 8 characters');
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      AppSnackbars.error(title: 'Error', message: 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      if (forgotUserId == null) {
        AppSnackbars.error(title: 'Error', message: 'Session expired. Please start over.');
        forgotPasswordStep.value = 0;
        return;
      }

      final response = await api.put(
        '/user/update-password?user_id=$forgotUserId',
        requireAuth: false,
        body: {
          'new_password': newPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        Get.back(); // Close bottom sheet
        AppSnackbars.success(title: 'Success', message: 'Password updated successfully!');
        clearForgotPasswordFlow();
      } else {
        AppSnackbars.error(title: 'Error', message: 'Failed to update password');
      }
    } catch (e) {
      AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Password strength checker
  bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  void clearForgotPasswordFlow() {
    forgotPasswordStep.value = 0;
    forgotUserId = null;
    forgotEmailController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    for (var c in otpControllers) {
      c.clear();
    }
  }

  void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  void clearForm() {
    emailController.clear();
    fullNameController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    iagree.value = false;
  }

  void goToSignup() { clearForm(); Get.to(() => SignupView()); }
  void goToLogin() { clearForm(); Get.back(); }

  Future<void> logout({bool showSnackbar = true}) async {
    storage.remove('token');
    storage.remove('user');

    // Refresh ProfileController state
    Get.find<ProfileController>().refreshUserStatus();
    
    // Re-initialize projects for guest mode
    await ProjectService.instance.reInitialize();

    Get.offAllNamed('/');
    if (showSnackbar) {
      AppSnackbars.info(title: 'Logged Out', message: 'Successfully logged out');
    }
  }

  Future<void> deleteAccount(String password) async {
    final userData = storage.read('user');
    if (userData == null || userData['id'] == null) return;

    isLoading.value = true;
    try {
      final response = await api.delete(
        '/user/remove_user/${userData['id']}',
        body: {'password': password},
      );

      if (response.statusCode == 200) {
        Get.back();
        logout();
        AppSnackbars.success(title: 'Success', message: 'Account deleted successfully');
      } else {
        final error = jsonDecode(response.body);
        AppSnackbars.error(title: 'Error', message: error['detail'] ?? 'Failed to delete account');
      }
    } catch (e) {
      AppSnackbars.error(title: 'Error', message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    clearForgotPasswordFlow();
    forgotEmailController.text = emailController.text;
    Get.bottomSheet(
      Obx(() => _buildForgotPasswordSheet()),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildForgotPasswordSheet() {
    final isDarkMode = Get.isDarkMode;
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24),
      decoration: BoxDecoration(color: ThemeHelper.getSurfaceColor(Get.context!), borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(forgotPasswordStep.value == 0 ? 'Forgot Password?' : forgotPasswordStep.value == 1 ? 'Verify OTP' : 'Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 32),
            if (forgotPasswordStep.value == 0) ...[
              TextFormField(controller: forgotEmailController, decoration: const InputDecoration(hintText: 'Enter your email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: isLoading.value ? null : forgotPasswordSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send OTP'))),
            ] else if (forgotPasswordStep.value == 1) ...[
              Text('Enter the 6-digit code sent to your email', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (index) => SizedBox(width: 45, child: TextFormField(controller: otpControllers[index], focusNode: otpFocusNodes[index], textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1, decoration: InputDecoration(counterText: "", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (value) { if (value.isNotEmpty) { if (index < 5) { otpFocusNodes[index + 1].requestFocus(); } else { verifyOtp(); } } else if (value.isEmpty && index > 0) { otpFocusNodes[index - 1].requestFocus(); } }, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold))))),
              const SizedBox(height: 48),
              if (isLoading.value) const CircularProgressIndicator(color: Colors.blueAccent),
            ] else ...[
              Obx(() => TextFormField(
                controller: newPasswordController, 
                focusNode: newPasswordFocusNode, 
                obscureText: !isPasswordVisible.value, 
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), 
                decoration: InputDecoration(
                  hintText: 'New Password', 
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                controller: confirmNewPasswordController, 
                focusNode: confirmNewPasswordFocusNode, 
                obscureText: !isConfirmPasswordVisible.value, 
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), 
                decoration: InputDecoration(
                  hintText: 'Confirm Password', 
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: toggleConfirmPasswordVisibility,
                  ),
                ),
              )),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: isLoading.value ? null : updatePassword, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: isLoading.value ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update Password'))),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
