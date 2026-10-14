import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/index.dart';

/// The single source of truth for all locally-persisted TaxiGo data.
///
/// Data lives in memory for the session and is mirrored to
/// [SharedPreferences] as JSON so it survives app restarts. Demo seed
/// records are inserted on the first run.
class Store {
  Store._();
  static final Store instance = Store._();

  late final SharedPreferences prefs;

  final List<User> users = [];
  final List<Driver> drivers = [];
  final List<Vehicle> vehicles = [];
  final List<Booking> bookings = [];

  User? current;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    List<dynamic> read(String key) {
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      try {
        return jsonDecode(raw) as List<dynamic>;
      } catch (_) {
        return [];
      }
    }

    users.addAll(read('users').map((e) => User.fromJson(Map<String, dynamic>.from(e))));
    drivers.addAll(read('drivers').map((e) => Driver.fromJson(Map<String, dynamic>.from(e))));
    vehicles.addAll(read('vehicles').map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e))));
    bookings.addAll(read('bookings').map((e) => Booking.fromJson(Map<String, dynamic>.from(e))));

    seedDefaults();
    await save();
  }

  /// Seed the demo accounts / records when storage is empty. Pulled out of
  /// [init] so tests can reset in-memory state to a known baseline.
  void seedDefaults() {
    if (users.isEmpty) {
      users.addAll([
        User(id: 'admin1', name: 'TaxiGo Administrator', email: 'admin@taxigo.local', password: 'Admin123!', role: Role.admin),
        User(id: 'pass1', name: 'Alex Passenger', email: 'passenger@taxigo.local', password: 'Passenger123!', role: Role.passenger),
      ]);
    }
    if (drivers.isEmpty) {
      drivers.addAll([
        Driver(id: 'd1', name: 'Marco Santos', phone: '0917 123 4567', license: 'DL-1001'),
        Driver(id: 'd2', name: 'Jessa Cruz', phone: '0928 234 5678', license: 'DL-1002'),
        Driver(id: 'd3', name: 'Paolo Reyes', phone: '0995 345 6789', license: 'DL-1003', active: false),
      ]);
    }
    if (vehicles.isEmpty) {
      vehicles.addAll([
        Vehicle(id: 'v1', plate: 'ABC 1234', model: 'Toyota Vios', type: 'Sedan', capacity: 4),
        Vehicle(id: 'v2', plate: 'XYZ 5678', model: 'Mitsubishi Xpander', type: 'MPV', capacity: 6),
        Vehicle(id: 'v3', plate: 'DEF 9012', model: 'Toyota Avanza', type: 'MPV', capacity: 6, status: 'Maintenance'),
      ]);
    }
    if (bookings.isEmpty) {
      final now = DateTime.now();
      bookings.addAll([
        Booking(
          id: 'TG-1001',
          passengerId: 'pass1',
          passengerName: 'Alex Passenger',
          pickup: 'Mactan Newtown',
          destination: 'Cebu IT Park',
          schedule: now.add(const Duration(days: 1)).toIso8601String(),
          passengers: 2,
          km: 12,
          fare: fare(12),
          createdAt: now.toIso8601String(),
          status: 'Confirmed',
          driverId: 'd1',
          vehicleId: 'v1',
        ),
        Booking(
          id: 'TG-1002',
          passengerId: 'pass1',
          passengerName: 'Alex Passenger',
          pickup: 'Lapu-Lapu City Hall',
          destination: 'Mactan-Cebu Airport',
          schedule: now.subtract(const Duration(days: 1)).toIso8601String(),
          passengers: 1,
          km: 5,
          fare: fare(5),
          createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          status: 'Completed',
          driverId: 'd1',
          vehicleId: 'v1',
          paymentMethod: 'E-wallet',
          paymentStatus: 'Paid',
        ),
      ]);
    }
  }

  /// TaxiGo fare rule: ₱60 base (₱50 base + ₱10 service fee) + ₱15 per km.
  static double fare(double km) => 60 + 15 * km;

  /// Generate a unique, human-readable id with the given [prefix].
  String id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  /// Persist every collection to [SharedPreferences].
  Future<void> save() async {
    await prefs.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
    await prefs.setString('drivers', jsonEncode(drivers.map((e) => e.toJson()).toList()));
    await prefs.setString('vehicles', jsonEncode(vehicles.map((e) => e.toJson()).toList()));
    await prefs.setString('bookings', jsonEncode(bookings.map((e) => e.toJson()).toList()));
  }

  User? login(String email, String password) {
    for (final u in users) {
      if (u.email.toLowerCase() == email.trim().toLowerCase() && u.password == password) {
        current = u;
        return u;
      }
    }
    return null;
  }

  /// Register a new passenger. Returns an error string, or `null` on success.
  Future<String?> register(String name, String email, String password) async {
    if (users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      return 'Email is already registered.';
    }
    final u = User(id: id('user'), name: name.trim(), email: email.trim().toLowerCase(), password: password, role: Role.passenger);
    users.add(u);
    current = u;
    await save();
    return null;
  }

  Future<void> logout() async {
    current = null;
  }

  /// Convenience accessor: a passenger's bookings, newest first.
  List<Booking> bookingsFor(String userId) {
    return bookings.where((b) => b.passengerId == userId).toList().reversed.toList();
  }
}
