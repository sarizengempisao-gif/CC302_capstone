/// Domain models for the TaxiGo app.
///
/// Each model is a small plain-data class with `toJson`/`fromJson` so the
/// [Store] can persist them to [SharedPreferences] as JSON.
library models;

export 'booking.dart';
export 'driver.dart';
export 'tip.dart';
export 'user.dart';
export 'vehicle.dart';
