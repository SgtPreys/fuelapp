class FuelStop {
  final int? id;
  final int carId;
  final int stationId;
  final double? distance;
  final double? liters;
  final double? totalPrice;
  final String date;

  FuelStop({
    this.id,
    required this.carId,
    required this.stationId,
    this.distance,
    this.liters,
    this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'stationId': stationId,
      'distance': distance,
      'liters': liters,
      'totalPrice': totalPrice,
      'date': date,
    };
  }

  factory FuelStop.fromMap(Map<String, dynamic> map) {
    return FuelStop(
      id: map['id'],
      carId: map['carId'],
      stationId: map['stationId'],
      distance: map['distance'],
      liters: map['liters'],
      totalPrice: map['totalPrice'],
      date: map['date'],
    );
  }

  // --- NEW: DYNAMIC CALCULATIONS ---

  // Calculates Liters per 100km
  double? get consumption {
    if (liters != null && distance != null && distance! > 0) {
      return (liters! / distance!) * 100;
    }
    return null; // Returns null if data is missing or distance is 0
  }

  // Calculates Price per Liter
  double? get pricePerLiter {
    if (totalPrice != null && liters != null && liters! > 0) {
      return totalPrice! / liters!;
    }
    return null;
  }
}