// lib/features/profile/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kampus_koin_app/features/auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/core/constants/legal_content.dart';
import 'package:kampus_koin_app/core/widgets/legal_page.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _contactSupport() async {
    // Use the direct API link which is more reliable than wa.me
    final Uri whatsappUrl = Uri.parse("https://api.whatsapp.com/send?phone=254115332870&text=Hello%20Kampus%20Koin%20support");
    
    try {
      // Force external launch for WhatsApp
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Could not launch WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader('Account'),
          _buildTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () => context.push('/edit-profile'),
          ),
          _buildTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Login',
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: true, 
                onChanged: (v) {}, 
                activeColor: colorScheme.primary,
              ),
            ),
          ),

          _buildSectionHeader('Support'),
          _buildTile(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Contact Support',
            subtitle: 'Chat with us on WhatsApp',
            onTap: _contactSupport,
          ),

          _buildSectionHeader('Legal'),
          _buildTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalPage(title: 'Terms', content: LegalContent.termsOfService)),
            ),
          ),
          _buildTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalPage(title: 'Privacy', content: LegalContent.privacyPolicy)),
            ),
          ),

          const SizedBox(height: 40),
          
          // Log Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                 ref.read(authNotifierProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.shade100),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}