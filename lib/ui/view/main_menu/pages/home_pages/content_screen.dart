import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';

class TutorialScreen extends StatelessWidget {
  final String title;
  final String content;
  final String? imageUrl;

  const TutorialScreen({
    super.key,
    this.title = 'Home & Room Layout Ideas',
    this.content = 'Getting furniture placement wrong is frustrating...',
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
      body: Stack(
        children: [
          /// Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top image
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.asset(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/bedroom.jpg',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/bedroom.jpg',
                          fit: BoxFit.cover,
                        ),
                ),

                /// Content section
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 300,
                  ),
                  color: isDarkMode
                      ? const Color(0xFF1F2937)
                      : Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Content
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Top overlay buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Back button
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDarkMode ? Colors.white : Colors.grey,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),

                  /// Share button
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: isDarkMode ? Colors.white : Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}