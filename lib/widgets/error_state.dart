import 'package:flutter/material.dart';

/// Centered message shown when a data load (e.g. the API tips) fails, with an
/// optional [onRetry] action so the user can try again.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_outlined, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ),
          ],
        ),
      ),
    );
  }
}
