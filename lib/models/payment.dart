class Payment {
  final String id;
  final String propertyId;
  final String userId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      propertyId: map['propertyId'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      method: map['method'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
