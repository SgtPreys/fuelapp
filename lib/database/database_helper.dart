import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "FuelAppDatabase.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // --- THE COMPLETE DATABASE SCHEMA ---
  Future _onCreate(Database db, int version) async {
    // 1. Vehicles Table
    await db.execute('''
      CREATE TABLE cars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carName TEXT NOT NULL,
        manufacturer TEXT,
        yearOfManufacture TEXT,
        status TEXT,
        licensePlate TEXT,
        nextTuev TEXT,
        fuelType TEXT,
        tireType TEXT,
        boughtDate TEXT,
        boughtPrice REAL,
        soldDate TEXT,
        soldPrice REAL
      )
    ''');

    // 2. Gas Stations Table
    await db.execute('''
      CREATE TABLE stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT,
        type TEXT,
        additionalInfo TEXT
      )
    ''');

    // 3. Companies / Shops Table
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT,
        contactPerson TEXT,
        email TEXT,
        telephone TEXT,
        website TEXT,
        additionalInfo TEXT
      )
    ''');

    // 4. Fuel Stops Table
    await db.execute('''
      CREATE TABLE fuel_stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER NOT NULL,
        stationId INTEGER NOT NULL,
        distance REAL,
        liters REAL,
        totalPrice REAL,
        date TEXT NOT NULL,
        FOREIGN KEY (carId) REFERENCES cars (id),
        FOREIGN KEY (stationId) REFERENCES stations (id)
      )
    ''');

    // 5. Maintenance Stops Table
    await db.execute('''
      CREATE TABLE maintenance_stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER NOT NULL,
        companyId INTEGER NOT NULL,
        occurrence TEXT NOT NULL,
        totalPrice REAL,
        additionalInfo TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (carId) REFERENCES cars (id),
        FOREIGN KEY (companyId) REFERENCES companies (id)
      )
    ''');
  }
  // --- CAR OPERATIONS ---

  // 1. Insert a new Car
  Future<int> insertCar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // We tell it to insert into the 'cars' table
    return await db.insert('cars', row);
  }

  // 2. Get a list of all Cars
  Future<List<Map<String, dynamic>>> getAllCars() async {
    Database db = await instance.database;
    // We ask it to query everything from the 'cars' table
    return await db.query('cars');
  }
  // --- STATION OPERATIONS ---

  Future<int> insertStation(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('stations', row);
  }

  Future<List<Map<String, dynamic>>> getAllStations() async {
    Database db = await instance.database;
    return await db.query('stations');
  }

  // --- COMPANY OPERATIONS ---

  Future<int> insertCompany(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('companies', row);
  }

  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    Database db = await instance.database;
    return await db.query('companies');
  }
}