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
      badgeIcon = Icons.workspace_premium;
    } else if (koinScore >= 5000) {
      badgeName = "Silver Saver";
      badgeColor = const Color(0xFFC0C0C0); // Silver
      badgeIcon = Icons.verified;
    } else if (koinScore >= 1000) {
      badgeName = "Bronze Saver";
      badgeColor = const Color(0xFFCD7F32); // Bronze
      badgeIcon = Icons.shield;
    } else {
      badgeName = "Rising Star";
      badgeColor = Colors.blueAccent;
      badgeIcon = Icons.star_border;
    }

    // --- 2. Build the Sleek Badge UI ---
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeName,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}