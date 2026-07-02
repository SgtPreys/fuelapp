class MaintenanceStop {
  final int? id;
  final int carId; // Links to the Car table
  final int companyId; // Links to the Company table
  final String occurrence;
  final double? totalPrice;
  final String? additionalInfo;
  final String date;

  MaintenanceStop({
    this.id,
    required this.carId,
    required this.companyId,
    required this.occurrence,
    this.totalPrice,
    this.additionalInfo,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'companyId': companyId,
      'occurrence': occurrence,
      'totalPrice': totalPrice,
      'additionalInfo': additionalInfo,
      'date': date,
    };
  }

  factory MaintenanceStop.fromMap(Map<String, dynamic> map) {
    return MaintenanceStop(
      id: map['id'],
      carId: map['carId'],
      companyId: map['companyId'],
      occurrence: map['occurrence'],
      totalPrice: map['totalPrice'],
      additionalInfo: map['additionalInfo'],
      date: map['date'],
    );
  }
}