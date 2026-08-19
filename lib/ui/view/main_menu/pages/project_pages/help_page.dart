import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:flutter_unity_widget_example/ui/services/api_service.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.blue.shade700,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.blue.shade900.withOpacity(0.5)
                        : Colors.blue.shade200,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How can we help you?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find answers to common questions or report an issue',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable FAQ Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 2,
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.quiz, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                    ..._buildExpandableTiles(context),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Divider(
                height: 32,
                thickness: 0.5,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
            ),
          ),

          // Report a Problem Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.red.shade900.withOpacity(0.3)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.report_problem,
                          color: isDarkMode ? Colors.red.shade400 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Report a Problem',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us improve by reporting any issues you encounter',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Issue Category',
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.category_outlined,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                              ),
                              dropdownColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                              },
                              validator: (value) =>
                              value == null ? 'Please select a category' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                hintText: 'your@email.com',
                                hintStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _problemController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Describe the problem',
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                prefixIcon: Icon(
                                  Icons.description_outlined,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                ),
                                hintText: 'Please provide details about the issue...',
                                hintStyle: TextStyle(
                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please describe the problem';
                                }
                                if (value.length < 10) {
                                  return 'Please provide more details (min 10 characters)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitReport,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(Icons.send),
                                label: Text(
                                  _isSubmitting ? 'Submitting...' : 'Submit Report',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.red.shade800
                                      : Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 24),
            sliver: SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpandableTiles(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {
        'question': 'How do I reset my password?',
        'answer':
        'Go to Login Screen and tap "Forgot Password". Enter your registered email address and we\'ll send you a reset link. Follow the instructions in the email to create a new password.',
        'icon': Icons.lock_reset,
      },
      {
        'question': 'How can I update my profile information?',
        'answer':
        'Navigate to Profile section from the bottom navigation bar. Tap on the edit icon next to your name or profile picture. Make your changes and tap Save to update your information.',
        'icon': Icons.person,
      },
      {
        'question': 'Is my data secure?',
        'answer':
        'Yes, we take security seriously. All your data is encrypted using industry-standard protocols (AES-256). We never share your personal information with third parties without your explicit consent.',
        'icon': Icons.security,
      },
      {
        'question': 'How do I contact support?',
        'answer':
            'You can reach our support team by email at autoplan3d@outlook.com or through the Report Problem section below. Our team typically responds within 24 hours on business days.',
        'icon': Icons.support_agent,
      },
      {
        'question': 'Can I use the app offline?',
        'answer':
        'Some features work offline, including viewing cached content and drafts. However, features requiring internet connection (like syncing, real-time updates) need an active connection.',
        'icon': Icons.offline_bolt,
      },
    ];

    return faqs.map((faq) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            faq['icon'] as IconData,
            color: Colors.blue.shade600,
            size: 24,
          ),
          title: Text(
            faq['question'] as String,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(56, 0, 20, 16),
          children: [
            Text(
              faq['answer'] as String,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}