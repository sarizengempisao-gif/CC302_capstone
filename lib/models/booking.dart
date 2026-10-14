/// A ride booking created by a passenger and managed by the admin.
class Booking {
  String id;
  String passengerId;
  String passengerName;
  String pickup;
  String destination;
  String schedule;
  String createdAt;
  int passengers;
  double km;
  double fare;
  String status; // 'Pending' | 'Confirmed' | 'In Progress' | 'Completed' | 'Cancelled'
  String? driverId;
  String? vehicleId;
  String paymentMethod;
  String paymentStatus; // 'Unpaid' | 'Paid' | 'Refunded'

  Booking({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.pickup,
    required this.destination,
    required this.schedule,
    required this.passengers,
    required this.km,
    required this.fare,
    required this.createdAt,
    this.status = 'Pending',
    this.driverId,
    this.vehicleId,
    this.paymentMethod = 'Cash',
    this.paymentStatus = 'Unpaid',
  });

  Map<String, dynamic> toJson() => {
          'id': id,
          'passengerId': passengerId,
          'passengerName': passengerName,
          'pickup': pickup,
          'destination': destination,
          'schedule': schedule,
          'passengers': passengers,
          'km': km,
          'fare': fare,
          'createdAt': createdAt,
          'status': status,
          'driverId': driverId,
          'vehicleId': vehicleId,
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentStatus,
        };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String? ?? '',
        passengerId: json['passengerId'] as String? ?? '',
        passengerName: json['passengerName'] as String? ?? '',
        pickup: json['pickup'] as String? ?? '',
        destination: json['destination'] as String? ?? '',
        schedule: json['schedule'] as String? ?? '',
        passengers: (json['passengers'] as num?)?.toInt() ?? 0,
        km: (json['km'] as num?)?.toDouble() ?? 0.0,
        fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
        driverId: json['driverId'] as String?,
        vehicleId: json['vehicleId'] as String?,
        paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
        paymentStatus: json['paymentStatus'] as String? ?? 'Unpaid',
      );
}
