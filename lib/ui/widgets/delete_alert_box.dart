
import 'package:flutter/material.dart';

void showDeleteProjectDialog({
  required BuildContext context,
  required String projectName,
  required VoidCallback onDelete,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2D3748)
                : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF501313)
                    : const Color(0xFFFCEBEB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: isDark
                    ? const Color(0xFFF09595)
                    : const Color(0xFFE24B4A),
                size: 22,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Delete project?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Body
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF666666),
                ),
                children: [
                  const TextSpan(text: 'This will permanently delete '),
                  TextSpan(
                    text: '"$projectName"',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : Colors.black87,
                    ),
                  ),
                  const TextSpan(
                    text:
                    ' and all its data. This action cannot be undone.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF444444),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF2D3748)
                            : const Color(0xFFD0D0D0),
                        width: 0.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFFE24B4A),
                      foregroundColor: isDark
                          ? const Color(0xFFFECACA)
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}