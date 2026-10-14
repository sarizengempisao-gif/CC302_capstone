import 'package:flutter/material.dart';

/// Centered spinner shown while data is being fetched.
class LoadingState extends StatelessWidget {
  final String? label;

  const LoadingState({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (label != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(label!)),
          ],
        ),
      ),
    );
  }
}
