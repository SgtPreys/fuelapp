class Car {
  final int? id; // It has a question mark because it won't have an ID until the database assigns one
  final String carName;
  final String? manufacturer;
  final String? yearOfManufacture;
  final String? status;
  final String? licensePlate;
  final String? nextTuev;
  final String? fuelType;
  final String? tireType;
  final String? boughtDate;
  final double? boughtPrice;
  final String? soldDate;
  final double? soldPrice;
  final String? imagePath;
  final String? additionalInfo;

  Car({
    this.id,
    required this.carName,
    this.manufacturer,
    this.yearOfManufacture,
    this.status,
    this.licensePlate,
    this.nextTuev,
    this.fuelType,
    this.tireType,
    this.boughtDate,
    this.boughtPrice,
    this.soldDate,
    this.soldPrice,
    this.imagePath,
    this.additionalInfo,
  });

  // This function translates our Dart object into a Map (which the database understands)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carName': carName,
      'manufacturer': manufacturer,
      'yearOfManufacture': yearOfManufacture,
      'status': status,
      'licensePlate': licensePlate,
      'nextTuev': nextTuev,
      'fuelType': fuelType,
      'tireType': tireType,
      'boughtDate': boughtDate,
      'boughtPrice': boughtPrice,
      'soldDate': soldDate,
      'soldPrice': soldPrice,
      'imagePath': imagePath,
      'additionalInfo': additionalInfo,
    };
  }

  // This function translates the database Map back into a Dart object (for our UI)
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      carName: map['carName'],
      manufacturer: map['manufacturer'],
      yearOfManufacture: map['yearOfManufacture'],
      status: map['status'],
      licensePlate: map['licensePlate'],
      nextTuev: map['nextTuev'],
      fuelType: map['fuelType'],
      tireType: map['tireType'],
      boughtDate: map['boughtDate'],
      boughtPrice: map['boughtPrice'],
      soldDate: map['soldDate'],
      soldPrice: map['soldPrice'],
      imagePath: map['imagePath'],
      additionalInfo: map['additionalInfo']
    );
  }
}