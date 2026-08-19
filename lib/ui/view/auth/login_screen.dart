import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:get/get.dart';

import '../../controller/auth/authcontroller.dart';
import '../../widgets/common_textfield.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

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
              // const SizedBox(height: 40),
              // Header Section
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 230,
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      // decoration: BoxDecoration(
                      //
                      //   gradient: LinearGradient(
                      //     colors: [
                      //       // Theme.of(context).primaryColor.withOpacity(0.7),
                      //       Colors.blueAccent.shade400,
                      //       // Theme.of(context).primaryColor.withOpacity(0.7),
                      //       Colors.blueAccent.shade100,
                      //     ],
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //   ),
                      //   shape: BoxShape.circle,
                      // ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(54),
                        child: Image.asset(
                          'assets/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 24),
                    // Text(
                    //   'AutoPlan 3d',
                    //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Login Form
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: authController.loginFormKey,
                child: Column(
                  children: [
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

                    // Password Field
                    Obx(() => CustomFormField(
                      controller: authController.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
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
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),
                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Row(
                          children: [
                            Checkbox(
                              value: authController.rememberMe.value,
                              onChanged: (_) => authController.toggleRememberMe(),
                              activeColor: Colors.blueAccent.shade400,
                            ),
                            const Text('Remember me'),
                          ],
                        )),
                        TextButton(
                          onPressed: authController.forgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blueAccent.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 27),
                    Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value ? null : authController.login,
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
                          : const Text('Sign In'),
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // const SizedBox(height: 32),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: authController.goToSignup,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.blueAccent.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
              onTap: () {
                Get.offAll(() => MenuScreen1());
              },
                child: Center(
                  child: Text(
                    "Don't have an account ? Continue ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}