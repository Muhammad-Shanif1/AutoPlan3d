import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget_example/ui/widgets/support_bottom_sheet.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern AppBar with gradient
          SliverAppBar(
            pinned: true,
            floating: true,
            bottom: const PreferredSize(preferredSize: Size(12, 0), child: SizedBox()),
            elevation: 2,
            shadowColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                // borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              "About",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Hero section with app icon and description
                  _buildHeroSection(isDarkMode),

                  const SizedBox(height: 24),

                  // Features sections with cards
                  _buildInfoSection(
                    isDarkMode: isDarkMode,
                    title: "FEATURES",
                    icon: Icons.star_rounded,
                    items: const [
                      "Editor - design in 2D, 3D",
                      "AI model for floor plans generation",
                      "Comprehensive catalog with various items",
                      "Community gallery of user designs",
                      "Online & offline functionality",
                      "Multi-platform synchronization",
                      "AR mode",
                    ],
                  ),

                  // const SizedBox(height: 16),

                  // _buildInfoSection(
                  //   isDarkMode: isDarkMode,
                  //   title: "FREE VERSION",
                  //   icon: Icons.workspace_premium_rounded,
                  //   items: const [
                  //     "Limited projects",
                  //     "Limited few credits"
                  //     "Limited catalog items",
                  //     "Multi-platform synchronization",
                  //     "Full 2D and 3D editor",
                  //     "AR mode",
                  //   ],
                  // ),
                  //


                  const SizedBox(height: 16),

                  _buildInfoSection(
                    isDarkMode: isDarkMode,
                    title: "CREATION TOOLS",
                    icon: Icons.design_services_rounded,
                    items: const [
                      "Generate floor plans",
                      "Design and customize floor plans",
                      "Choose and import furniture",
                      "Apply textures and colors",
                      "Drag & drop functionality",
                      "Resize items freely",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    isDarkMode: isDarkMode,
                    title: "CATALOG ACCESS",
                    icon: Icons.shopping_bag_rounded,
                    items: const [
                      "Purchase full access to unlock all items",
                      "Available in Guest mode",
                    ],
                  ),

                  // const SizedBox(height: 16),
                  //
                  // _buildInfoSection(
                  //   isDarkMode: isDarkMode,
                  //   title: "VIEWING & SNAPSHOTS",
                  //   icon: Icons.camera_alt_rounded,
                  //   items: const [
                  //     "Unity snapshots",
                  //     "Works online and offline",
                  //   ],
                  // ),

                  const SizedBox(height: 16),

                  // Statistics cards
                  // _buildStatsSection(isDarkMode),
                  //
                  // const SizedBox(height: 16),

                  // Support section
                  _buildSupportSection(isDarkMode),

                  const SizedBox(height: 16),

                  // Social media section
                  // _buildSocialSection(isDarkMode),
                  //
                  // const SizedBox(height: 16),

                  // Installation info card
                  _buildInstallationCard(isDarkMode),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDarkMode) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            Colors.blue.shade900.withOpacity(0.3),
            Colors.purple.shade900.withOpacity(0.3),
          ]
              : [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.design_services_rounded,
              size: 48,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "AutoPlan 3D",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Create beautiful and realistic interior and exterior designs in 2D and 3D modes",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required bool isDarkMode,
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFF2563EB)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) => _buildBulletPoint(isDarkMode, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(bool isDarkMode, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStatsSection(bool isDarkMode) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.insights_rounded, size: 22, color: Color(0xFF2563EB)),
  //             const SizedBox(width: 12),
  //             Text(
  //               "IMPACT",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w700,
  //                 color: isDarkMode ? Colors.white : Colors.black87,
  //                 letterSpacing: -0.3,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         GridView.count(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           crossAxisCount: 2,
  //           mainAxisSpacing: 16,
  //           crossAxisSpacing: 16,
  //           childAspectRatio: 1.4,
  //           children: [
  //             _StatCard(isDarkMode: isDarkMode, value: "20M+", label: "Downloads", icon: Icons.download_rounded),
  //             _StatCard(isDarkMode: isDarkMode, value: "40M+", label: "Designs Created", icon: Icons.create_rounded),
  //             _StatCard(isDarkMode: isDarkMode, value: "50M+", label: "Users Worldwide", icon: Icons.public_rounded),
  //             _StatCard(isDarkMode: isDarkMode, value: "2.5M+", label: "Snapshots Made", icon: Icons.camera_alt_rounded),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSupportSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent_rounded, size: 22, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(
                "SUPPORT",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email_rounded, color: Color(0xFF2563EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email Support",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "support@autoplan3d.com",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: "autoplan3d@gmail.com"));
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      AppSnackbars.show(
                        title: "Copied", 
                        message: "Email address copied to clipboard",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                const SupportBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Use support form in app",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSocialSection(bool isDarkMode) {
  //   final socialMedia = [
  //     {"icon": Icons.facebook, "name": "Facebook", "color": 0xFF1877F2},
  //     {"icon": Icons.chat_bubble_outline, "name": "Twitter", "color": 0xFF1DA1F2},
  //     {"icon": Icons.camera_alt, "name": "Instagram", "color": 0xFFE4405F},
  //     {"icon": Icons.language, "name": "Website", "color": 0xFF2563EB},
  //   ];
  //
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.share_rounded, size: 22, color: Color(0xFF2563EB)),
  //             const SizedBox(width: 12),
  //             Text(
  //               "FOLLOW US",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w700,
  //                 color: isDarkMode ? Colors.white : Colors.black87,
  //                 letterSpacing: -0.3,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         Wrap(
  //           spacing: 12,
  //           runSpacing: 12,
  //           children: socialMedia.map((social) {
  //             return Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //               decoration: BoxDecoration(
  //                 color: Color(social["color"] as int).withOpacity(isDarkMode ? 0.2 : 0.1),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     social["icon"] as IconData,
  //                     size: 18,
  //                     color: Color(social["color"] as int),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Text(
  //                     social["name"] as String,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w500,
  //                       color: Color(social["color"] as int),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInstallationCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 22, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(
                "SOFTWARE INFORMATION",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(isDarkMode, "Release Date", "June 2026"),
          Divider(height: 12, thickness: 0.5, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          _buildInfoRow(isDarkMode, "Version", "v1.0"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDarkMode, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isDarkMode;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}