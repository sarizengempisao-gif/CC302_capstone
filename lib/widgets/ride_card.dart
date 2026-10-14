import 'package:flutter/material.dart';
import '../models/index.dart';
import '../utils/formatters.dart';

/// A compact card for a single booking shown in the passenger history and
/// the passenger home "recent rides" section.
typedef RideAction = void Function(Booking booking);

class RideCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewReceipt;
  final bool showCancel;
  final RideAction onRequestCancel;

  const RideCard({
    super.key,
    required this.booking,
    required this.onViewReceipt,
    this.showCancel = true,
    this.onRequestCancel = _noop,
  });

  static void _noop(Booking _) {}

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final canCancel = showCancel && (b.status == 'Pending' || b.status == 'Confirmed');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(b.id, style: const TextStyle(fontWeight: FontWeight.w800))),
                _StatusChip(label: b.status),
              ],
            ),
            Text('● ${b.pickup}', style: const TextStyle(height: 1.4)),
            const SizedBox(height: 7),
            Text('⌖ ${b.destination}', style: const TextStyle(height: 1.4)),
            const SizedBox(height: 4),
            Text(dateText(b.schedule), style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const Divider(height: 22),
            Row(
              children: [
                Expanded(child: Text(peso(b.fare), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                TextButton.icon(onPressed: onViewReceipt, icon: const Icon(Icons.receipt_long), label: const Text('Receipt')),
                if (canCancel)
                  TextButton(onPressed: () => onRequestCancel(b), child: const Text('Cancel booking')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small coloured chip that reflects a booking's status.
class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  Color _color(String s) => switch (s) {
        'Completed' => Colors.green.shade600,
        'Cancelled' => Colors.red.shade600,
        'In Progress' => Colors.blue.shade600,
        'Confirmed' => Colors.indigo.shade600,
        _ => Colors.orange.shade600,
      };

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: _color(label).withValues(alpha: 0.12),
      labelStyle: TextStyle(color: _color(label), fontWeight: FontWeight.w700),
    );
  }
}
