import 'package:flutter/material.dart';

/// Centered placeholder shown when a list has no records yet.
///
/// Tappable [action] lets the user create the first record.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inventory_2_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitle!,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
              ),
            if (action != null) Padding(padding: const EdgeInsets.only(top: 14), child: action!),
          ],
        ),
      ),
    );
  }
}
