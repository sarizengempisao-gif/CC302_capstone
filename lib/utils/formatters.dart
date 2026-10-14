import 'package:flutter/material.dart';

/// Format a number as Philippine pesos (₱), two decimals.
String peso(num n) => '₱${n.toStringAsFixed(2)}';

/// Format an ISO-8601 timestamp into a short, readable local string.
String dateText(String s) {
  try {
    final d = DateTime.parse(s).toLocal();
    return '${d.month}/${d.day}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return s;
  }
}

/// Show a [SnackBar] with the given [message] using the nearest
/// [ScaffoldMessenger], so callers do not need their own messenger lookup.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
