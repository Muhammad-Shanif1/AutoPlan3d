import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/profile_controller.dart';

import '../../../../services/stripe_service.dart';

class PricingScreen extends StatefulWidget {
  PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final ProfileController controller = Get.find();

  Widget featureRow({
    required String title,
    String? free,
    String? pro,
    bool premiumCheck = false,
    bool proCheck = false,
    bool freeCross = false,
  }) {
    final isDarkMode = Get.isDarkMode;
    final screenWidth = Get.width;
    final isSmallPhone = screenWidth < 360;
    final isNormalPhone = screenWidth >= 360 && screenWidth < 480;

    double fontSize = isSmallPhone ? 13 : (isNormalPhone ? 14 : 15);
    double iconSize = isSmallPhone ? 18 : 20;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallPhone ? 10 : 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Center(
              child: free != null
                  ? Text(
                free,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize - 1,
                ),
              )
                  : premiumCheck
                  ? Icon(Icons.check,
                color: Colors.blueAccent,
                size: iconSize,
              )
                  : freeCross
                  ? Icon(Icons.close,
                color: Colors.red,
                size: iconSize,
              )
                  : const SizedBox(),
            ),
          ),
          Expanded(
            child: Center(
              child: pro != null
                  ? Text(
                pro,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize - 1,
                ),
              )
                  : proCheck
                  ? Icon(Icons.check,
                color: Colors.blueAccent,
                size: iconSize,
              )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Lock to portrait when entering this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Reset to system default orientation when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Android device categories
    final isSmallPhone = screenWidth < 360;  // Small Android phones
    final isNormalPhone = screenWidth >= 360 && screenWidth < 480; // Normal Android phones
    final isTablet = screenWidth >= 600 && screenWidth < 800; // Android tablets
    final isLargeTablet = screenWidth >= 800; // Large Android tablets

    // Responsive padding based on device
    double horizontalPadding = 16;
    if (isTablet) horizontalPadding = 32;
    if (isLargeTablet) horizontalPadding = 48;

    // Responsive font sizes
    double titleFontSize = 22;
    double subtitleFontSize = 14;
    double headerFontSize = 14;
    double buttonFontSize = 14;
    double buttonHeight = 55;

    if (isSmallPhone) {
      titleFontSize = 20;
      subtitleFontSize = 12;
      headerFontSize = 13;
      buttonFontSize = 13;
      buttonHeight = 50;
    } else if (isNormalPhone) {
      titleFontSize = 22;
      subtitleFontSize = 14;
      headerFontSize = 14;
      buttonFontSize = 14;
      buttonHeight = 55;
    } else if (isTablet) {
      titleFontSize = 26;
      subtitleFontSize = 16;
      headerFontSize = 16;
      buttonFontSize = 16;
      buttonHeight = 60;
    } else if (isLargeTablet) {
      titleFontSize = 30;
      subtitleFontSize = 18;
      headerFontSize = 18;
      buttonFontSize = 18;
      buttonHeight = 65;
    }

    // Responsive spacing
    double mainSpacing = 20;
    if (isSmallPhone) mainSpacing = 16;
    if (isTablet) mainSpacing = 24;
    if (isLargeTablet) mainSpacing = 28;

    double buttonSpacing = 12;
    if (isTablet) buttonSpacing = 16;
    if (isLargeTablet) buttonSpacing = 20;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              /// Close Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    size: isSmallPhone ? 24 : 28,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              SizedBox(height: isSmallPhone ? 8 : 12),

              /// Title
              Text(
                "Remove all limits and\ndesign your dream home",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
              ),

              SizedBox(height: isSmallPhone ? 6 : 8),

              // Text(
              //   "See which plan is right for you",
              //   style: TextStyle(
              //     fontSize: subtitleFontSize,
              //     color: isDarkMode ? Colors.grey[400] : Colors.grey,
              //   ),
              // ),
              //
              SizedBox(height: mainSpacing),

              /// Header Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "What You Get",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: headerFontSize,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "FREE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: headerFontSize,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "GO PRO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: headerFontSize,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Divider(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                thickness: 0.8,
                height: mainSpacing,
              ),

              /// Features List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  // showsVerticalScrollIndicator: false,
                  children: [
                    featureRow(
                      title: "Credits",
                      free: "Limited",
                      pro: "Unlimited",
                    ),
                    featureRow(
                      title: "Project's Limit",
                      free: "3",
                      pro: "Unlimited",
                    ),
                    featureRow(
                      title: "Catalog items",
                      free: "Limited",
                      pro: "Unlimited",
                    ),
                    featureRow(
                      title: "Team Support",
                      free: "Limited",
                      pro: "Unlimited",
                    ),
                    featureRow(
                      title: "AR Mode",
                      freeCross: true,
                      proCheck: true,
                    ),
                    featureRow(
                      title: "Export Project",
                      freeCross: true,
                      proCheck: true,
                    ),
                    featureRow(
                      title: "Community Gallery",
                      freeCross: true,
                      proCheck: true,
                    ),
                  ],
                ),
              ),

              /// Buttons
              Padding(
                padding: EdgeInsets.only(top: mainSpacing, bottom: isSmallPhone ? 16 : 20),
                child: Column(
                  children: [
                    /// Professional Button
                    GestureDetector(
                      onTap: () {
                        controller.showPlansBottomSheet(ispremium: false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: buttonHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.blueAccent.shade100,
                              Colors.blueAccent.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: buttonFontSize,
                            ),
                          ),
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
    );
  }
}