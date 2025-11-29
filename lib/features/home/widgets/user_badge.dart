// lib/features/home/widgets/user_badge.dart

import 'package:flutter/material.dart';

class UserBadge extends StatelessWidget {
  final int koinScore;

  const UserBadge({super.key, required this.koinScore});

  @override
  Widget build(BuildContext context) {
    // --- 1. Define Logic for Badges ---
    String badgeName;
    Color badgeColor;
    IconData badgeIcon;

    if (koinScore >= 10000) {
      badgeName = "Gold Financier";
      badgeColor = const Color(0xFFFFD700); // Gold
      badgeIcon = Icons.workspace_premium_rounded;
    } else if (koinScore >= 5000) {
      badgeName = "Silver Saver";
      badgeColor = const Color(0xFFE0E0E0); // Lighter Silver
      badgeIcon = Icons.verified_rounded;
    } else if (koinScore >= 1000) {
      badgeName = "Bronze Saver";
      badgeColor = const Color(0xFFFFCC80); // Lighter Bronze
      badgeIcon = Icons.shield_rounded;
    } else {
      badgeName = "Rising Star";
      badgeColor = const Color(0xFF69F0AE); // Bright Green/Cyan accent
      badgeIcon = Icons.star_rounded;
    }

    // --- 2. Build the Sleek Badge UI ---
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Glassy effect for gradient backgrounds
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.6), 
          width: 1
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeName.toUpperCase(),
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}