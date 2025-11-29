// lib/features/auth/widgets/forgot_password_modal.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordModal extends StatelessWidget {
  const ForgotPasswordModal({super.key});

  // Function to open WhatsApp or Email
  Future<void> _contactSupport() async {
    // Use the direct API link which is more reliable than wa.me
    final Uri whatsappUrl = Uri.parse("https://api.whatsapp.com/send?phone=254115332870&text=Hello%20Admin,%20I%20forgot%20my%20Kampus%20Koin%20password.");
    
    try {
      // Force external launch for WhatsApp
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // 2. Icon & Header
          const Center(
            child: Icon(Icons.lock_reset_rounded, size: 64, color: Colors.orange),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          const Text(
            'For security reasons, please contact our support team to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // 3. Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _contactSupport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Contact Admin via WhatsApp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 4. Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.grey[600],
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}