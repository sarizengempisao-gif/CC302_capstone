/// A vehicle record managed by the admin.
class Vehicle {
  String id;
  String plate;
  String model;
  String type;
  int capacity;
  String status; // 'Available' or 'Maintenance'

  Vehicle({
    required this.id,
    required this.plate,
    required this.model,
    required this.type,
    required this.capacity,
    this.status = 'Available',
  });

  Map<String, dynamic> toJson() => {
          'id': id,
          'plate': plate,
          'model': model,
          'type': type,
          'capacity': capacity,
          'status': status,
        };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String? ?? '',
        plate: json['plate'] as String? ?? '',
        model: json['model'] as String? ?? '',
        type: json['type'] as String? ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'Available',
      );
}
