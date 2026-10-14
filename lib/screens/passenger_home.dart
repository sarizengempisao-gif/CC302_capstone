import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/ride_card.dart';
import 'tips_screen.dart';

/// Home screen for the passenger role. Hosts four tabs through a
/// [NavigationRail] (wide) / [NavigationBar] (narrow): Book, My rides, Profile
/// and Tips.
class PassengerHome extends StatefulWidget {
  final User user;
  final VoidCallback onDone;

  const PassengerHome({super.key, required this.user, required this.onDone});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  int tab = 0;
  Store get s => Store.instance;
  List<Booking> get mine => s.bookingsFor(widget.user.id);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    await s.logout();
    widget.onDone();
  }

  static const _icons = [Icons.home_outlined, Icons.history, Icons.person_outline, Icons.lightbulb_outlined];
  static const _labels = ['Book', 'My rides', 'Profile', 'Tips'];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 800;
    final pages = [_home(), _history(), _profile(), TipsScreen()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚕 TaxiGo', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text(widget.user.name, style: const TextStyle(fontSize: 13))),
          ),
          IconButton(tooltip: 'Log out', onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Row(
        children: [
          if (wide) _rail(index: tab, onSelect: (i) => setState(() => tab = i)),
          Expanded(child: IndexedStack(index: tab, children: pages)),
        ],
      ),
      bottomNavigationBar: wide ? null : _rail(index: tab, onSelect: (i) => setState(() => tab = i)),
    );
  }

  Widget _rail({required int index, required ValueChanged<int> onSelect}) {
    final wide = MediaQuery.sizeOf(context).width > 800;
    if (wide) {
      return NavigationRail(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (int i = 0; i < _icons.length; i++) NavigationRailDestination(icon: Icon(_icons[i]), label: Text(_labels[i])),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      destinations: [
        for (int i = 0; i < _icons.length; i++) NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
      ],
    );
  }

  Widget _wrap(Widget child) => SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 950), child: child)),
      );

  // ---------------------------------------------------------------------------
  // Book ride
  // ---------------------------------------------------------------------------
  Widget _home() => _wrap(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: AppColors.headerGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your next ride starts here.', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Book a ride, estimate the fare, and keep your trips organized.', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
                    onPressed: _book,
                    icon: const Icon(Icons.add),
                    label: const Text('Book a taxi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Recent rides (${mine.length})', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (mine.isEmpty)
              EmptyState(title: 'No rides yet', subtitle: 'Book your first taxi to get started.', action: FilledButton.icon(onPressed: _book, icon: const Icon(Icons.add), label: const Text('Book a taxi')))
            else
              SizedBox(
                height: 48.0 * (mine.take(4).length).toDouble() + 16,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mine.take(4).length,
                  itemBuilder: (context, index) => RideCard(booking: mine[index], onViewReceipt: () => _receipt(mine[index]), showCancel: false),
                ),
              ),
          ],
        ),
      );

  // ---------------------------------------------------------------------------
  // My rides
  // ---------------------------------------------------------------------------
  Widget _history() => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: mine.isEmpty
              ? _wrap(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _headingSmall('My rides', 'Review bookings, status, fare, and receipts.'),
                  const EmptyState(title: 'No rides yet', subtitle: 'Book your first taxi to get started.'),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: mine.length,
                  itemBuilder: (context, index) => Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: RideCard(
                        booking: mine[index],
                        onViewReceipt: () => _receipt(mine[index]),
                        onRequestCancel: (b) => _cancel(mine[index]),
                      ),
                    ),
                  ),
                ),
        ),
      );

  Widget _headingSmall(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.subheading),
          const SizedBox(height: 18),
        ],
      );

  Future<void> _cancel(Booking b) async {
    final confirmed = await _confirm('Cancel booking ${b.id}?');
    if (!mounted || !confirmed) return;
    b.status = 'Cancelled';
    await s.save();
    if (!mounted) return;
    setState(() {});
    showMessage(context, 'Booking cancelled.');
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------
  Widget _profile() => _wrap(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(radius: 35, child: Icon(Icons.person, size: 38)),
                const SizedBox(height: 12),
                Text(widget.user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text(widget.user.email),
                const Divider(height: 28),
                ListTile(title: const Text('Total rides'), trailing: Text('${mine.length}')),
                ListTile(title: const Text('Completed rides'), trailing: Text('${mine.where((b) => b.status == 'Completed').length}')),
                const SizedBox(height: 8),
                const Text(
                  'This student demo saves data locally on this device. Data is not synchronized across devices.',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

  // ---------------------------------------------------------------------------
  // Receipt + booking form
  // ---------------------------------------------------------------------------
  Future<void> _receipt(Booking b) => showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('TaxiGo ride receipt'),
          content: SelectableText(
            'TAXIGO — RIDE RECEIPT\n'
            'Booking: ${b.id}\n'
            'Passenger: ${b.passengerName}\n'
            'Pickup: ${b.pickup}\n'
            'Destination: ${b.destination}\n'
            'Schedule: ${dateText(b.schedule)}\n'
            'Passengers: ${b.passengers}\n'
            'Estimated distance: ${b.km} km\n'
            'Base fare: ₱50.00\n'
            'Distance charge: ${peso(b.km * 15)}\n'
            'Service fee: ₱10.00\n'
            'TOTAL: ${peso(b.fare)}\n'
            'Payment: ${b.paymentMethod} / ${b.paymentStatus}\n'
            'Status: ${b.status}\n\n'
            'Student demo receipt — not a tax invoice.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
        ),
      );

  Future<void> _book() async {
    final key = GlobalKey<FormState>();
    final pickup = TextEditingController();
    final destination = TextEditingController();
    final km = TextEditingController(text: '5');
    final passengers = TextEditingController(text: '1');
    String method = 'Cash';
    DateTime schedule = DateTime.now().add(const Duration(hours: 2));

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: const Text('Book a taxi'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(controller: pickup, decoration: const InputDecoration(labelText: 'Pickup location'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                    TextFormField(controller: destination, decoration: const InputDecoration(labelText: 'Destination'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : v.trim().toLowerCase() == pickup.text.trim().toLowerCase() ? 'Must differ from pickup' : null),
                    TextFormField(controller: km, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Estimated distance (km)'), validator: (v) => double.tryParse(v ?? '') == null || double.parse(v!) <= 0 || double.parse(v) > 500 ? 'Enter 0.1–500 km' : null),
                    TextFormField(controller: passengers, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Passengers (1–6)'), validator: (v) => int.tryParse(v ?? '') == null || int.parse(v!) < 1 || int.parse(v) > 6 ? 'Enter 1–6' : null),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Expanded(child: Text('Schedule')),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(context: c, initialDate: schedule.isBefore(DateTime.now()) ? DateTime.now() : schedule, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (date == null || !mounted) return;
                          // The picker dialog is still open, so the dialog context
                          // is valid even though we are in an async gap.
                          // ignore: use_build_context_synchronously
                          final time = await showTimePicker(context: c, initialTime: TimeOfDay.fromDateTime(schedule));
                          if (time == null) return;
                          setState(() => schedule = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                        },
                        child: Text(dateText(schedule.toIso8601String())),
                      ),
                    ]),
                    DropdownButtonFormField<String>(
                      initialValue: method,
                      decoration: const InputDecoration(labelText: 'Payment method'),
                      items: ['Cash', 'E-wallet'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                      onChanged: (v) => setState(() => method = v ?? 'Cash'),
                    ),
                    const SizedBox(height: 10),
                    Text('Estimated fare: ${peso(Store.fare(double.tryParse(km.text) ?? 0))}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (key.currentState!.validate() && schedule.isAfter(DateTime.now())) {
                  Navigator.pop(c, true);
                } else if (!mounted) {
                  // no-op
                } else {
                  showMessage(c, 'Choose a future schedule.');
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;
    final dist = double.parse(km.text);
    s.bookings.add(Booking(
      id: 'TG-${DateTime.now().millisecondsSinceEpoch}',
      passengerId: widget.user.id,
      passengerName: widget.user.name,
      pickup: pickup.text.trim(),
      destination: destination.text.trim(),
      schedule: schedule.toIso8601String(),
      passengers: int.parse(passengers.text),
      km: dist,
      fare: Store.fare(dist),
      paymentMethod: method,
      createdAt: DateTime.now().toIso8601String(),
    ));
    await s.save();
    if (!mounted) return;
    setState(() {});
    showMessage(context, 'Booking created successfully.');
  }

  Future<bool> _confirm(String title) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(title: Text(title), content: const Text('Are you sure?'), actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
      ]),
    );
    return result == true;
  }
}
