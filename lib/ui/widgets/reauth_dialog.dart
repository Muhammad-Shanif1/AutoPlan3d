import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class ReauthDialog extends StatefulWidget {
  final VoidCallback onVerified;

  const ReauthDialog({super.key, required this.onVerified});

  @override
  State<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<ReauthDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final ProfileController _controller = Get.find();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                color: Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Identity Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFF1F5F9) : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your current password to continue with the update.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Current password',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                errorText: _error,
                filled: true,
                fillColor: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerify() async {
    if (_controller.isOffline.value) {
      setState(() {
        _error = 'Connection lost. Please try again later.';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Password is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final isValid = await _controller.verifyPassword(_passwordController.text);
    
    if (mounted) {
      if (isValid) {
        Navigator.pop(context);
        widget.onVerified();
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Incorrect password';
        });
      }
    }
  }
}
