import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:flutter_unity_widget_example/ui/services/api_service.dart';

class SupportBottomSheet extends StatefulWidget {
  const SupportBottomSheet({super.key});

  @override
  State<SupportBottomSheet> createState() => _SupportBottomSheetState();
}

class _SupportBottomSheetState extends State<SupportBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'App Crash',
    'Login Issue',
    'Payment Problem',
    'Feature Request',
    'Account Settings',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final ProfileController profileController = Get.find();
    if (profileController.email.value.isNotEmpty && 
        profileController.email.value != 'Loading...' &&
        profileController.email.value != 'guest@autoplan.com') {
      _emailController.text = profileController.email.value;
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final ProfileController profileController = Get.find();

    if (profileController.isOffline.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.show(
          title: "Connection Error",
          message: "You are currently offline. Please check your internet connection to submit a report.",
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        );
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final ApiService api = ApiService.instance;
        final response = await api.post(
          '/user/submit-support',
          requireAuth: false,
          body: {
            'email': _emailController.text.trim(),
            'category': _selectedCategory,
            'details': _problemController.text.trim(),
          },
        );

        if (mounted) {
          setState(() => _isSubmitting = false);
          
          if (response.statusCode == 200) {
            Get.back(); // Close bottom sheet
            AppSnackbars.success(title: "Success", message: 'Report submitted successfully! We\'ll get back to you soon.');
            
            _formKey.currentState!.reset();
            _problemController.clear();
            _emailController.clear();
            setState(() => _selectedCategory = null);
          } else {
            AppSnackbars.error(title: "Error", message: "Failed to submit report. Please try again later.");
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          AppSnackbars.error(title: "Error", message: "Connection error. Please check your internet and try again.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;

    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.support_agent_rounded,
                                  color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Support Request",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "How can we help you today? Please fill out the form below.",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: isDarkMode
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87),
                            decoration: _inputDecoration(
                              isDarkMode: isDarkMode,
                              label: "Issue Category",
                              icon: Icons.category_outlined,
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value),
                            validator: (value) => value == null
                                ? 'Please select a category'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              isDarkMode: isDarkMode,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              hint: "your@email.com",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _problemController,
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87),
                            maxLines: 4,
                            decoration: _inputDecoration(
                              isDarkMode: isDarkMode,
                              label: "Describe the issue",
                              icon: Icons.description_outlined,
                              hint: "Provide details about your problem...",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please describe the problem';
                              }
                              if (value.length < 10) {
                                return 'Please provide more details (min 10 chars)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      "Submit Request",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required bool isDarkMode,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
      hintStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.blueAccent.shade400, size: 20),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
