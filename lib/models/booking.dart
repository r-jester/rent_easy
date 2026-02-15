class Booking {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String renterId;
  final String ownerId;
  final String status;
  final double monthlyRent;
  final DateTime? moveInDate;
  final int leaseMonths;
  final String note;
  final String paymentId;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.renterId,
    required this.ownerId,
    required this.status,
    required this.monthlyRent,
    required this.moveInDate,
    required this.leaseMonths,
    required this.note,
    required this.paymentId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'renterId': renterId,
      'ownerId': ownerId,
      'status': status,
      'monthlyRent': monthlyRent,
      'moveInDate': moveInDate?.toIso8601String(),
      'leaseMonths': leaseMonths,
      'note': note,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    final monthlyRaw = map['monthlyRent'];
    final leaseRaw = map['leaseMonths'];

    return Booking(
      id: map['id'] as String,
      propertyId: map['propertyId'] as String,
      propertyTitle: map['propertyTitle'] as String,
      renterId: map['renterId'] as String,
      ownerId: map['ownerId'] as String,
      status: map['status'] as String,
      monthlyRent: monthlyRaw is num
          ? monthlyRaw.toDouble()
          : double.tryParse(monthlyRaw?.toString() ?? '') ?? 0,
      moveInDate: map['moveInDate'] == null
          ? null
          : DateTime.parse(map['moveInDate'] as String),
      leaseMonths: leaseRaw is num
          ? leaseRaw.toInt()
          : int.tryParse(leaseRaw?.toString() ?? '') ?? 12,
      note: map['note'] as String? ?? '',
      paymentId: map['paymentId'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Booking copyWith({String? status}) {
    return Booking(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      renterId: renterId,
      ownerId: ownerId,
      status: status ?? this.status,
      monthlyRent: monthlyRent,
      moveInDate: moveInDate,
      leaseMonths: leaseMonths,
      note: note,
      paymentId: paymentId,
      createdAt: createdAt,
    );
  }
}
