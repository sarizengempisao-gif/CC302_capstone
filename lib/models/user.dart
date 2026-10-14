/// The two roles available in the demo: an administrator and a passenger.
enum Role { admin, passenger }

/// A registered user of TaxiGo. Passwords are stored locally in plain text
/// on purpose — this is a classroom demo, not a production login system.
class User {
  String id;
  String name;
  String email;
  String password;
  Role role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
          'id': id,
          'name': name,
          'email': email,
          'password': password,
          'role': role.name,
        };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        role: Role.values.firstWhere(
          (r) => r.name == (json['role'] as String? ?? 'passenger'),
          orElse: () => Role.passenger,
        ),
      );
}
