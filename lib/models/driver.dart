/// A driver record managed by the admin.
class Driver {
  String id;
  String name;
  String phone;
  String license;
  bool active;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.license,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
          'id': id,
          'name': name,
          'phone': phone,
          'license': license,
          'active': active,
        };

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        license: json['license'] as String? ?? '',
        active: json['active'] as bool? ?? true,
      );
}
