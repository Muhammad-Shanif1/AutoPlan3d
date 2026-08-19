import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../controller/auth/authcontroller.dart';
import '../../widgets/common_textfield.dart';
import 'legal_screen.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Button
              IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark?Colors.white12:Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [

                            Colors.blueAccent.shade400,Colors.blueAccent.shade100,
                            // Theme.of(context).primaryColor,
                            // Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Signup Form
              Form(
                key: authController.signupFormKey,
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    // Full Name Field
                    CustomFormField(
                      controller: authController.fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    CustomFormField(
                      controller: authController.emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    Obx(() => CustomFormField(
                      controller: authController.phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      prefixIcon: GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            onSelect: (Country country) {
                              authController.selectedCountryCode.value = "+${country.phoneCode}";
                            },
                          );
                        },
                        child: Container(
                          // padding: const EdgeInsets.symmetric(horizontal: 10),
                          // alignment: Alignment.center,
                          width: 100,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_android_outlined),
                              const SizedBox(width: 10
                              ),
                              Text("${authController.selectedCountryCode.value}"),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,

                    )),
                    const SizedBox(height: 20),

                    // Password Field
                    Obx(() => CustomFormField(
                      controller: authController.passwordController,
                      label: 'Password',
                      hint: 'Create a strong password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                      obscureText: !authController.isPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },

                    )),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    Obx(() => CustomFormField(
                      controller: authController.confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      onchanged: (value) {
                        // authController.passwordText.value=value;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: authController.toggleConfirmPasswordVisibility,
                      ),
                      obscureText: !authController.isConfirmPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != authController.passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    )),
                    const SizedBox(height: 16),

                    // Password Strength Indicator
                    Obx(() =>  authController.passwordText.value.isNotEmpty
                        ? Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                authController.isPasswordStrong(authController.passwordController.text)
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 16,
                                color: authController.isPasswordStrong(authController.passwordController.text)
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authController.isPasswordStrong(authController.passwordController.text)
                                      ? 'Strong password!'
                                      : 'Use 8+ chars with uppercase, lowercase, numbers, and symbols',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: authController.isPasswordStrong(authController.passwordController.text)
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : const SizedBox(),),
                    const SizedBox(height: 24),

                    // Terms and Conditions
                    Row(
                      children: [
                        Obx(
                          ()=> Checkbox(
                            value: authController.iagree.value,
                            onChanged: (value) {
                              authController.iagree.value=value!;
                            },
                            activeColor: Colors.blueAccent.shade400,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Colors.blueAccent.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => const LegalScreen(
                                            title: 'Terms of Service',
                                            content: LegalContent.termsOfService,
                                          ));
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.blueAccent.shade400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => const LegalScreen(
                                            title: 'Privacy Policy',
                                            content: LegalContent.privacyPolicy,
                                          ));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sign Up Button
                    // Obx(() => ElevatedButton(
                    //   onPressed: authController.isLoading.value ? null : authController.signup,
                    //   style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blueAccent.shade400,)),
                    //
                    //   child: authController.isLoading.value
                    //       ? const SizedBox(
                    //     height: 20,
                    //     width: 20,
                    //     child: CircularProgressIndicator(
                    //       strokeWidth: 2,
                    //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    //     ),
                    //   )
                    //       : const Text('Create Account'),
                    // )),
                    Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value ? null : authController.signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade400,
                        disabledBackgroundColor: Colors.blueAccent.shade200, // Add disabled color
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        // Explicitly define text style for all states
                        textStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            );
                          }
                          return const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          );
                        }),
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Create Account'),
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed:() {
                      Get.back();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.blueAccent.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}