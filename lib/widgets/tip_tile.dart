import 'package:flutter/material.dart';
import '../models/index.dart';
import '../theme/app_theme.dart';

/// A card that displays a single tip/quote from the API.
class TipTile extends StatelessWidget {
  final Tip tip;
  final bool isOffline;

  const TipTile({super.key, required this.tip, this.isOffline = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOffline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.wifi_off_rounded, size: 14),
                  SizedBox(width: 4),
                  Text('Offline — showing cached sample tip', style: TextStyle(fontSize: 11)),
                ]),
              ),
            const SizedBox(height: 6),
            Text(tip.content, style: const TextStyle(fontSize: 16, height: 1.4)),
            const SizedBox(height: 8),
            Text('— ${tip.author}', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
