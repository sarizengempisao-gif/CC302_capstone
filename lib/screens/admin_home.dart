import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';
import 'tips_screen.dart';

/// Home screen for the admin role. Hosts six tabs through a
/// [NavigationRail] (wide) / [NavigationBar] (narrow): Overview, Bookings,
/// Drivers, Vehicles, Reports and Tips.
class AdminHome extends StatefulWidget {
  final User user;
  final VoidCallback onDone;

  const AdminHome({super.key, required this.user, required this.onDone});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int tab = 0;
  String _searchDrivers = '';
  String _searchVehicles = '';
  String _searchBookings = '';

  Store get s => Store.instance;

  Future<void> _logout() async {
    await s.logout();
    widget.onDone();
  }

  static const _tabs = ['Overview', 'Bookings', 'Drivers', 'Vehicles', 'Reports', 'Tips'];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 850;
    final pages = [
      _dashboard(),
      _bookingPage(),
      _driverPage(),
      _vehiclePage(),
      _reportPage(),
      TipsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚕 TaxiGo Admin', style: TextStyle(fontWeight: FontWeight.w800)),
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
          if (wide)
            _rail(tabs: _tabs, index: tab, onSelect: (i) => setState(() => tab = i), wide: true),
          Expanded(child: IndexedStack(index: tab, children: pages)),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : _rail(tabs: _tabs, index: tab, onSelect: (i) => setState(() => tab = i), wide: false),
    );
  }

  /// Builds either a [NavigationRail] (wide) or a [NavigationBar] (narrow).
  Widget _rail({required List<String> tabs, required int index, required ValueChanged<int> onSelect, required bool wide}) {
    const icons = [
      Icons.dashboard_outlined,
      Icons.receipt_long,
      Icons.people,
      Icons.directions_car,
      Icons.bar_chart,
      Icons.lightbulb_outlined,
    ];
    if (wide) {
      return NavigationRail(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        destinations: [
          for (int i = 0; i < tabs.length; i++) NavigationRailDestination(icon: Icon(icons[i]), label: Text(tabs[i])),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onSelect,
      destinations: [
        for (int i = 0; i < tabs.length; i++) NavigationDestination(icon: Icon(icons[i]), label: tabs[i]),
      ],
    );
  }

  /// Shared scroll wrapper that caps content width on wide screens.
  Widget _wrap(Widget child) => SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: child)),
      );

  /// Same width cap but lets a [ListView.builder] provide the scroll.
  Widget _centeredList(ListView builder) => Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: builder),
      );

  Widget _heading(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.subheading),
          const SizedBox(height: 18),
        ],
      );

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
            'Distance: ${b.km} km\n'
            'Base fare: ₱50.00\n'
            'Distance charge: ${peso(b.km * 15)}\n'
            'Service fee: ₱10.00\n'
            'TOTAL: ${peso(b.fare)}\n'
            'Payment: ${b.paymentMethod} / ${b.paymentStatus}\n'
            'Status: ${b.status}\n\n'
            'Classroom demo receipt, not a tax invoice.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
        ),
      );

  // ---------------------------------------------------------------------------
  // Overview / dashboard
  // ---------------------------------------------------------------------------
  Widget _dashboard() {
    final paid = s.bookings.where((b) => b.status == 'Completed' && b.paymentStatus == 'Paid').fold<double>(0, (n, b) => n + b.fare);
    return _wrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Good day, Admin', 'Here is the current TaxiGo activity overview.'),
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                StatCard(icon: Icons.receipt_long, value: '${s.bookings.length}', title: 'Bookings'),
                StatCard(icon: Icons.schedule, value: '${s.bookings.where((b) => b.status == 'Pending').length}', title: 'Pending'),
                StatCard(icon: Icons.check_circle, value: '${s.bookings.where((b) => b.status == 'Completed').length}', title: 'Completed'),
                StatCard(icon: Icons.payments, value: peso(paid), title: 'Paid revenue'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 260,
                    child: s.bookings.isEmpty
                        ? const EmptyState(title: 'No bookings yet')
                        : ListView.builder(
                            itemCount: s.bookings.length,
                            itemBuilder: (context, index) {
                              final b = s.bookings.reversed.elementAt(index);
                              return ListTile(
                                leading: const Icon(Icons.local_taxi, color: AppColors.primary),
                                title: Text('${b.pickup} → ${b.destination}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${b.id} · ${b.passengerName} · ${b.status}'),
                                trailing: Text(peso(b.fare), style: const TextStyle(fontWeight: FontWeight.w700)),
                                onTap: () => _receipt(b),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------------
  Widget _bookingPage() {
    final filtered = _filteredBookings();
    return _centeredList(
      ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: filtered.isEmpty ? 1 : filtered.length + 1,
        itemBuilder: (context, index) {
          if (filtered.isEmpty) {
            return Column(
              children: [
                _heading('Bookings', 'Search and update ride statuses.'),
                const EmptyState(title: 'No bookings match', subtitle: 'Clear the search to see all bookings.'),
              ],
            );
          }
          if (index == 0) return _bookingHeader();
          final b = filtered[index - 1];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${b.id} · ${b.passengerName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text('${b.pickup} → ${b.destination}'),
                  Text('${dateText(b.schedule)} · ${b.passengers} passenger(s)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(peso(b.fare), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      DropdownButton<String>(
                        value: b.status,
                        items: ['Pending', 'Confirmed', 'In Progress', 'Completed', 'Cancelled']
                            .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                            .toList(),
                        onChanged: (v) async {
                          if (v != null) {
                            b.status = v;
                            await s.save();
                            setState(() {});
                          }
                        },
                      ),
                      IconButton(tooltip: 'Receipt', onPressed: () => _receipt(b), icon: const Icon(Icons.receipt_long)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Booking> _filteredBookings() {
    final q = _searchBookings.trim().toLowerCase();
    if (q.isEmpty) return s.bookings.reversed.toList();
    return s.bookings.reversed.where((b) => '${b.id} ${b.passengerName} ${b.pickup} ${b.destination} ${b.status}'.toLowerCase().contains(q)).toList();
  }

  Widget _bookingHeader() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _heading('Bookings', 'Search and update ride statuses.'),
        TextField(
          decoration: const InputDecoration(labelText: 'Search bookings', prefixIcon: Icon(Icons.search, color: AppColors.primary)),
          onChanged: (v) => setState(() => _searchBookings = v),
        ),
        const SizedBox(height: 10),
      ]);

  // ---------------------------------------------------------------------------
  // Drivers
  // ---------------------------------------------------------------------------
  Widget _driverPage() {
    final filtered = _filteredDrivers();
    return _centeredList(
      ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: filtered.isEmpty ? 1 : filtered.length + 1,
        itemBuilder: (context, index) {
          if (filtered.isEmpty) {
            return Column(children: [
              _driverHeader(),
              const SizedBox(height: 8),
              const EmptyState(title: 'No drivers match', subtitle: 'Clear the search to see all drivers.'),
            ]);
          }
          if (index == 0) return _driverHeader();
          return _driverItem(filtered[index - 1]);
        },
      ),
    );
  }

  List<Driver> _filteredDrivers() {
    final q = _searchDrivers.trim().toLowerCase();
    if (q.isEmpty) return List<Driver>.of(s.drivers);
    return s.drivers.where((d) => '${d.name} ${d.phone} ${d.license}'.toLowerCase().contains(q)).toList();
  }

  Widget _driverHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: _heading('Drivers', 'Manage driver details and availability.')), FilledButton.icon(onPressed: () => _editDriver(), icon: const Icon(Icons.add), label: const Text('Add'))]),
          TextField(
            decoration: const InputDecoration(labelText: 'Search drivers', prefixIcon: Icon(Icons.search, color: AppColors.primary)),
            onChanged: (v) => setState(() => _searchDrivers = v),
          ),
          const SizedBox(height: 6),
        ],
      );

  Widget _driverItem(Driver d) {
    return Dismissible(
      key: ValueKey('driver-${d.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.red, size: 28),
      ),
      confirmDismiss: (_) async => _confirmDelete('Remove driver "${d.name}"?'),
      onDismissed: (_) => _removeDriver(d),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.person, color: AppColors.primary),
          title: Text(d.name),
          subtitle: Text('${d.phone} · License ${d.license} · ${d.active ? 'Active' : 'Inactive'}'),
          trailing: Wrap(spacing: 4, children: [
            IconButton(tooltip: 'Edit', onPressed: () => _editDriver(d), icon: const Icon(Icons.edit_outlined)),
            IconButton(
              tooltip: d.active ? 'Deactivate' : 'Activate',
              onPressed: () async {
                d.active = !d.active;
                await s.save();
                setState(() {});
              },
              icon: Icon(d.active ? Icons.pause_circle_outline : Icons.play_circle_outline),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _removeDriver(Driver d) async {
    final index = s.drivers.indexOf(d);
    s.drivers.remove(d);
    await s.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${d.name} removed from drivers.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            s.drivers.insert(index, d);
            s.save();
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _editDriver([Driver? d]) async {
    final name = TextEditingController(text: d?.name ?? '');
    final phone = TextEditingController(text: d?.phone ?? '');
    final license = TextEditingController(text: d?.license ?? '');
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(d == null ? 'Add driver' : 'Edit driver'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              TextFormField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              TextFormField(controller: license, decoration: const InputDecoration(labelText: 'License'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (key.currentState!.validate()) Navigator.pop(c, true);
          }, child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    if (d == null) {
      s.drivers.add(Driver(id: s.id('d'), name: name.text, phone: phone.text, license: license.text));
    } else {
      d.name = name.text;
      d.phone = phone.text;
      d.license = license.text;
    }
    await s.save();
    if (!mounted) return;
    showMessage(context, d == null ? 'Driver added.' : 'Driver updated.');
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Vehicles
  // ---------------------------------------------------------------------------
  Widget _vehiclePage() {
    final filtered = _filteredVehicles();
    return _centeredList(
      ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: filtered.isEmpty ? 1 : filtered.length + 1,
        itemBuilder: (context, index) {
          if (filtered.isEmpty) {
            return Column(children: [
              _vehicleHeader(),
              const SizedBox(height: 8),
              const EmptyState(title: 'No vehicles match', subtitle: 'Clear the search to see all vehicles.'),
            ]);
          }
          if (index == 0) return _vehicleHeader();
          return _vehicleItem(filtered[index - 1]);
        },
      ),
    );
  }

  List<Vehicle> _filteredVehicles() {
    final q = _searchVehicles.trim().toLowerCase();
    if (q.isEmpty) return List<Vehicle>.of(s.vehicles);
    return s.vehicles.where((v) => '${v.plate} ${v.model} ${v.type} ${v.status}'.toLowerCase().contains(q)).toList();
  }

  Widget _vehicleHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: _heading('Vehicles', 'Manage fleet records, capacity, and status.')), FilledButton.icon(onPressed: () => _editVehicle(), icon: const Icon(Icons.add), label: const Text('Add'))]),
          TextField(
            decoration: const InputDecoration(labelText: 'Search vehicles', prefixIcon: Icon(Icons.search, color: AppColors.primary)),
            onChanged: (v) => setState(() => _searchVehicles = v),
          ),
          const SizedBox(height: 6),
        ],
      );

  Widget _vehicleItem(Vehicle v) {
    return Dismissible(
      key: ValueKey('vehicle-${v.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.red, size: 28),
      ),
      confirmDismiss: (_) async => _confirmDelete('Remove vehicle "${v.plate}"?'),
      onDismissed: (_) => _removeVehicle(v),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.directions_car, color: AppColors.primary),
          title: Text('${v.plate} · ${v.model}'),
          subtitle: Text('${v.type} · Capacity ${v.capacity} · ${v.status}'),
          trailing: Wrap(spacing: 4, children: [
            IconButton(tooltip: 'Edit', onPressed: () => _editVehicle(v), icon: const Icon(Icons.edit_outlined)),
            IconButton(
              tooltip: 'Toggle status',
              onPressed: () async {
                v.status = v.status == 'Available' ? 'Maintenance' : 'Available';
                await s.save();
                setState(() {});
              },
              icon: const Icon(Icons.build_outlined),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _removeVehicle(Vehicle v) async {
    final index = s.vehicles.indexOf(v);
    s.vehicles.remove(v);
    await s.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${v.plate} ${v.model} removed from fleet.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            s.vehicles.insert(index, v);
            s.save();
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _editVehicle([Vehicle? v]) async {
    final plate = TextEditingController(text: v?.plate ?? '');
    final model = TextEditingController(text: v?.model ?? '');
    final type = TextEditingController(text: v?.type ?? 'Sedan');
    final cap = TextEditingController(text: '${v?.capacity ?? 4}');
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(v == null ? 'Add vehicle' : 'Edit vehicle'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: plate, decoration: const InputDecoration(labelText: 'Plate number'), validator: (x) => x == null || x.trim().isEmpty ? 'Required' : null),
              TextFormField(controller: model, decoration: const InputDecoration(labelText: 'Model'), validator: (x) => x == null || x.trim().isEmpty ? 'Required' : null),
              TextFormField(controller: type, decoration: const InputDecoration(labelText: 'Type')),
              TextFormField(
                controller: cap,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Capacity'),
                validator: (x) => int.tryParse(x ?? '') == null || int.parse(x!) < 1 ? 'Enter a valid number' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (key.currentState!.validate()) Navigator.pop(c, true);
          }, child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    if (v == null) {
      s.vehicles.add(Vehicle(id: s.id('v'), plate: plate.text, model: model.text, type: type.text, capacity: int.parse(cap.text)));
    } else {
      v.plate = plate.text;
      v.model = model.text;
      v.type = type.text;
      v.capacity = int.parse(cap.text);
    }
    await s.save();
    if (!mounted) return;
    showMessage(context, v == null ? 'Vehicle added.' : 'Vehicle updated.');
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------
  Widget _reportPage() => _wrap(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading('Payments & reports', 'Update payment records and review totals.'),
            ...s.bookings.map(
              (b) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${b.id} · ${b.passengerName}'),
                  subtitle: Text('${b.status} · ${peso(b.fare)}'),
                  trailing: SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<String>(
                      initialValue: b.paymentStatus,
                      decoration: const InputDecoration(labelText: 'Payment'),
                      items: ['Unpaid', 'Paid', 'Refunded'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          b.paymentStatus = v;
                          await s.save();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Total bookings: ${s.bookings.length}'),
                    Text('Completed: ${s.bookings.where((b) => b.status == 'Completed').length}'),
                    Text('Cancelled: ${s.bookings.where((b) => b.status == 'Cancelled').length}'),
                    Text('Paid revenue: ${peso(s.bookings.where((b) => b.status == 'Completed' && b.paymentStatus == 'Paid').fold<double>(0, (n, b) => n + b.fare))}'),
                    Text('Active drivers: ${s.drivers.where((d) => d.active).length}'),
                    Text('Available vehicles: ${s.vehicles.where((v) => v.status == 'Available').length}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ---------------------------------------------------------------------------
  // Shared confirm dialog
  // ---------------------------------------------------------------------------
  Future<bool> _confirmDelete(String title) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    return result == true;
  }
}
