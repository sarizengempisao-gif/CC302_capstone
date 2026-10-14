import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small summary card used on the admin dashboard, e.g. "12 Completed".
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.icon, required this.value, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.statSurface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 12),
              Text(value, style: AppTextStyles.statValue),
              Text(title, style: AppTextStyles.statLabel),
            ],
          ),
        ),
      ),
    );
  }
}
