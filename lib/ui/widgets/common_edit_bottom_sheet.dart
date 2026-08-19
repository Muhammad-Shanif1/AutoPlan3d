import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/ui/widgets/profile_bottom_sheet.dart';

void showEditBottomSheet({
  required BuildContext context,
  required String title,
  required String hint,
  required String currentValue,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool obscureText = false,
  required Function(String?) onSave,
}) {
  final TextEditingController controller = TextEditingController(text: currentValue);
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditProfileBottomSheet(
      title: title,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      isDarkMode: isDarkMode,
      onSave: () {
        onSave(controller.text.trim());
        Navigator.pop(context);
      },
    ),
  );
}