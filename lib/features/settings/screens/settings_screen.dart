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
    
    Uri.parse("https://flutter.dev"); // Test URL

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          _buildSectionHeader('Account'),
          _buildTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push('/edit-profile'),
          ),
          _buildTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: colorScheme.primary), // Dummy switch
          ),

          _buildSectionHeader('Support'),
          _buildTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            subtitle: 'Chat with us on WhatsApp',
            onTap: _contactSupport,
          ),

          _buildSectionHeader('Legal'),
          _buildTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalPage(title: 'Terms', content: LegalContent.termsOfService)),
            ),
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalPage(title: 'Privacy', content: LegalContent.privacyPolicy)),
            ),
          ),

          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                 ref.read(authNotifierProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}