import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import 'package:flutter_unity_widget_example/ui/constants/libraries/app_libraries.dart';
import 'package:flutter_unity_widget_example/ui/controller/home_page_controller.dart';
import '../../../screens/show_house.dart';
import '../../models/project_model.dart';
import '../../controller/profile_controller.dart';
import '../../view/main_menu/pages/home_pages/community_gallery_screen.dart';
import '../../view/main_menu/pages/profile_pages/pricing_page.dart';
import '../../view/main_menu/pages/home_pages/content_screen.dart';

newproject_card({gradient = null, ontap, required bool isblackcolor, required title, required firstsubtitle, secondsubtitle, required Icon icon}) {
  return InkWell(
    onTap: ontap,
    child: Card(
      elevation: 5,
      color: ThemeHelper.cardColor, // Add this for dark mode support
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: isblackcolor
              ? const Color(0xFF28282B)
              : ThemeHelper.cardColor, // Changed from Colors.white
          borderRadius: BorderRadius.circular(15),
        ),
        height: 151,
        width: 140,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: MyText(
                text: title,
                color: isblackcolor
                    ? Colors.white
                    : ThemeHelper.textPrimaryColor, // Changed from Colors.black
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            MyText(
              text: firstsubtitle,
              color: isblackcolor
                  ? Colors.white38
                  : ThemeHelper.textSecondaryColor, // Changed from Colors.black45
              fontSize: 15,
            ),
            MyText(
              text: secondsubtitle ?? "",
              color: isblackcolor
                  ? Colors.white38
                  : ThemeHelper.textSecondaryColor, // Changed from Colors.black45
              fontSize: 15,
            ),
            const SizedBox(height: 30),
            Align(
              alignment: const Alignment(1, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: isblackcolor
                      ? Colors.white
                      : ThemeHelper.textPrimaryColor, // Changed from Colors.black
                  shape: BoxShape.circle,
                ),
                height: 35,
                width: 35,
                child: icon,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

project_card(Project p) {
  return InkWell(
    onTap: () {
      // Get.to(
      //       () => HouseSceneScreen(project: p,issnap: false,),
      // );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 5,
          color: ThemeHelper.cardColor, // Add this for dark mode support
          child: Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? Colors.grey.shade700
                  : Colors.grey.shade400, // Changed to support dark mode
              borderRadius: BorderRadius.circular(15),
            ),
            height: 151,
            width: 140,
            child: Stack(
              children: [
                Center(
                  child: p.projectImage != null && p.projectImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            p.projectImage!,
                            height: 151,
                            width: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox(width: 40, height: 40, child: Image.asset("assets/project.png")),
                          ),
                        )
                      : SizedBox(width: 70, height: 70, child: Image.asset("assets/project.png")),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // color: Get.isDarkMode ? Colors.black54 : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      // borderRadius: BorderRadius.circular(15),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.1),
                      //     blurRadius: 4,
                      //     offset: const Offset(-2, 2),
                      //   ),
                      // ],
                    ),
                    child: Icon(
                      p.visibility == "Public" ? Icons.public : Icons.lock_outline,
                      size: 22,
                      // color: Colors.blueAccent.shade400,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 140,
          child: MyText(
            text: "  ${p.name}" ??"Project Name",
            color: ThemeHelper.textPrimaryColor, // Added for dark mode support
          ),
        ),
      ],
    ),
  );
}

Widget designGeneratorBanner(double width, {VoidCallback? onTap}) {
  final isDarkMode = Get.isDarkMode;
  return Card(
    elevation: 8,
    shadowColor: Colors.blueAccent.withOpacity(0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    color: ThemeHelper.cardColor,
    child: MovingLightBorder(
      borderRadius: 24,
      borderWidth: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 160, // Increased to accommodate text wrapping on different screen sizes
          width: width,
          decoration: BoxDecoration(
            border: isDarkMode ? Border.all(color: Colors.white, width: 0.5) : null,
          ),
          child: Stack(
            children: [
              /// Background Image
              Positioned(
                right: -20,
                top: -10,
                bottom: -10,
                child: Transform.rotate(
                  angle: -0.05,
                  child: Image.asset(
                    "assets/bedroom.jpg",
                    fit: BoxFit.cover,
                    width: width * 0.6,
                  ),
                ),
              ),
  
              /// Modern Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ThemeHelper.cardColor,
                        ThemeHelper.cardColor.withOpacity(0.98),
                        ThemeHelper.cardColor.withOpacity(0.7),
                        ThemeHelper.cardColor.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.4, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
  
              /// Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                          SizedBox(width: 8),
                          Text(
                            "AI MAGIC",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
  
                    const SizedBox(height: 8),
                    SizedBox(
                      width: width * 0.55,
                      child: MyText(
                        text: "Generate Your Floor Plan Using AI",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: ThemeHelper.textPrimaryColor,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const SizedBox(height: 10),
                    
                    // Premium Button
                    InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade400,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const MyText(
                          text: "Start Now",
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
  );
}

Widget communityGalleryBanner(double width) {
  final isDarkMode = Get.isDarkMode;
  return InkWell(
    onTap: () {
      final profileController = Get.find<ProfileController>();
      
      // 1. Check Offline
      if (profileController.isOffline.value) {
        AppSnackbars.error(
          title: 'Offline', 
          message: 'Community Gallery is not available in offline mode',
        );
        return;
      }

      // 2. Check Pro Subscription
      if (profileController.subscription.value != 'pro') {
        AppSnackbars.show(
          title: 'Pro Feature', 
          message: 'Community Gallery is exclusive to Pro members. Upgrade to explore!',
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
        return;
      }

      Get.to(() => const CommunityGalleryScreen());
    },
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: ThemeHelper.cardColor,
      child: Container(
        height: 120,
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.blueAccent.shade700.withOpacity(0.8), Colors.indigo.shade900.withOpacity(0.8)]
                : [Colors.blueAccent.shade100, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Community Gallery",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Explore and share floor plans with others",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

content_block({required title, required firstsubtitle, String? content, String? imageUrl}) {
  return InkWell(
    onTap: () {
      Get.to(() => TutorialScreen(
            title: title,
            content: content ?? firstsubtitle,
            imageUrl: imageUrl,
          ));
    },
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        color: ThemeHelper.cardColor, // Add this for dark mode support
        child: Container(
          height: 266,
          width: 250,
          color: ThemeHelper.cardColor, // Changed from Colors.white
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  imageUrl ?? "assets/bedroom.jpg",
                  height: 130,
                  width: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Get.isDarkMode
                          ? Colors.grey.shade800
                          : const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Get.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: title,
                      maxLines: 2,
                      color: ThemeHelper.textPrimaryColor, // Changed from Colors.black
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 10),
                    MyText(
                      text: firstsubtitle,
                      maxLines: 3,
                      color: ThemeHelper.textSecondaryColor, // Changed from Colors.black45
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MovingLightBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;

  const MovingLightBorder({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.borderWidth = 2,
  });

  @override
  State<MovingLightBorder> createState() => _MovingLightBorderState();
}

class _MovingLightBorderState extends State<MovingLightBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _LightPainter(
            animationValue: _controller.value,
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _LightPainter extends CustomPainter {
  final double animationValue;
  final double borderRadius;
  final double borderWidth;

  _LightPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_LightPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
