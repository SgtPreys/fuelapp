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
  // --- UPDATE OPERATIONS ---

  // Update a Car
  Future<int> updateCar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('cars', row, where: 'id = ?', whereArgs: [id]);
  }

  // Update a Station
  Future<int> updateStation(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('stations', row, where: 'id = ?', whereArgs: [id]);
  }

  // Update a Company
  Future<int> updateCompany(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('companies', row, where: 'id = ?', whereArgs: [id]);
  }
  // --- DELETE OPERATIONS ---

  Future<int> deleteCar(int id) async {
    Database db = await instance.database;
    return await db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStation(int id) async {
    Database db = await instance.database;
    return await db.delete('stations', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCompany(int id) async {
    Database db = await instance.database;
    return await db.delete('companies', where: 'id = ?', whereArgs: [id]);
  }
  // ==========================================
  // --- FUEL OPERATIONS ---
  // ==========================================

  Future<int> insertFuelStop(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('fuel_stops', row);
  }

  Future<List<Map<String, dynamic>>> getAllFuelStops() async {
    Database db = await instance.database;
    // We order by date DESC so the newest fuel stops appear at the top!
    return await db.query('fuel_stops', orderBy: 'date DESC');
  }

  Future<int> updateFuelStop(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('fuel_stops', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFuelStop(int id) async {
    Database db = await instance.database;
    return await db.delete('fuel_stops', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // --- MAINTENANCE OPERATIONS ---
  // ==========================================

  Future<int> insertMaintenanceStop(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('maintenance_stops', row);
  }

  Future<List<Map<String, dynamic>>> getAllMaintenanceStops() async {
    Database db = await instance.database;
    return await db.query('maintenance_stops', orderBy: 'date DESC');
  }

  Future<int> updateMaintenanceStop(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('maintenance_stops', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMaintenanceStop(int id) async {
    Database db = await instance.database;
    return await db.delete('maintenance_stops', where: 'id = ?', whereArgs: [id]);
  }
  // ==========================================
  // --- DASHBOARD / JOIN OPERATIONS ---
  // ==========================================

  // Gets the 5 most recent fuel stops with the actual Car and Station names
  Future<List<Map<String, dynamic>>> getRecentFuelStops() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT f.*, c.carName, s.name as stationName 
      FROM fuel_stops f
      JOIN cars c ON f.carId = c.id
      JOIN stations s ON f.stationId = s.id
      ORDER BY f.date DESC
      LIMIT 5
    ''');
  }

  // Gets the 5 most recent maintenance stops with the actual Car and Company names
  Future<List<Map<String, dynamic>>> getRecentMaintenanceStops() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT m.*, c.carName, comp.name as companyName 
      FROM maintenance_stops m
      JOIN cars c ON m.carId = c.id
      JOIN companies comp ON m.companyId = comp.id
      ORDER BY m.date DESC
      LIMIT 5
    ''');
  }

  
  // Gets ALL fuel stops with names for the Manage Data screen
  Future<List<Map<String, dynamic>>> getAllFuelStopsWithDetails() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT f.*, c.carName, s.name as stationName 
      FROM fuel_stops f
      JOIN cars c ON f.carId = c.id
      JOIN stations s ON f.stationId = s.id
      ORDER BY f.date DESC
    ''');
  }

  // Gets ALL maintenance stops with names for the Manage Data screen
  Future<List<Map<String, dynamic>>> getAllMaintenanceStopsWithDetails() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT m.*, c.carName, comp.name as companyName 
      FROM maintenance_stops m
      JOIN cars c ON m.carId = c.id
      JOIN companies comp ON m.companyId = comp.id
      ORDER BY m.date DESC
    ''');
  }
  // ==========================================
  // --- STATISTICS & AGGREGATION ---
  // ==========================================

  // Calculates total fuel costs, total distance, and total liters
  Future<Map<String, dynamic>> getFuelAggregates() async {
    Database db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(totalPrice) as totalFuelCost,
        SUM(distance) as totalDistance,
        SUM(liters) as totalLiters
      FROM fuel_stops
    ''');
    return result.isNotEmpty ? result.first : {};
  }

  // Calculates the total cost of all maintenance
  Future<double> getTotalMaintenanceCost() async {
    Database db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(totalPrice) as totalCost FROM maintenance_stops
    ''');
    if (result.isNotEmpty && result.first['totalCost'] != null) {
      return (result.first['totalCost'] as num).toDouble();
    }
    return 0.0;
  }
    // Fetches fuel stops from oldest to newest for the line chart
  Future<List<Map<String, dynamic>>> getFuelStopsForChart() async {
    Database db = await instance.database;
    return await db.query('fuel_stops', orderBy: 'date ASC');
  }
  // ==========================================
  // --- SPENDING TRACKING FOR MANAGE DATA ---
  // ==========================================

  // Gets all stations and calculates the total money spent at each
  Future<List<Map<String, dynamic>>> getAllStationsWithSpend() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT s.*, SUM(f.totalPrice) as totalSpent
      FROM stations s
      LEFT JOIN fuel_stops f ON s.id = f.stationId
      GROUP BY s.id
    ''');
  }

  // Gets all companies and calculates the total money spent at each
  Future<List<Map<String, dynamic>>> getAllCompaniesWithSpend() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT c.*, SUM(m.totalPrice) as totalSpent
      FROM companies c
      LEFT JOIN maintenance_stops m ON c.id = m.companyId
      GROUP BY c.id
    ''');
  }

  //Gets all cars and calculates the total money spent on fuel and maintenance for each
  Future<List<Map<String, dynamic>>> getAllCarsWithSpend() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT c.*, 
        (SELECT SUM(f.distance) FROM fuel_stops f WHERE f.carId = c.id) as totalDistance,
        (SELECT SUM(f.totalPrice) FROM fuel_stops f WHERE f.carId = c .id) as totalFuelSpent,
        (SELECT SUM(m.totalPrice) FROM maintenance_stops m WHERE m.carId = c.id) as totalMaintenanceSpent,
        ((SELECT SUM(f.totalPrice) FROM fuel_stops f WHERE f.carId = c.id) + (SELECT SUM(m.totalPrice) FROM maintenance_stops m WHERE m.carId = c.id)) as totalSpent
      FROM cars c
    ''');
  }

  //Gets all stats per car, including total liters, total distance, total fuel cost, average price per liter, average cost per stop, average liters per stop, average distance per stop, and average consumption (L/100km)
  // Gets all stats per car, safely using subqueries to prevent duplication
  Future<List<Map<String, dynamic>>> getStatsPerCar() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT c.carName, 
             (SELECT SUM(liters) FROM fuel_stops WHERE carId = c.id) as totalLiters, 
             (SELECT SUM(distance) FROM fuel_stops WHERE carId = c.id) as totalDistance, 
             (SELECT SUM(totalPrice) FROM fuel_stops WHERE carId = c.id) as totalFuelCost,
             (SELECT SUM(totalPrice) FROM maintenance_stops WHERE carId = c.id) as totalMaintenanceCost,
             (SELECT AVG(totalPrice / liters) FROM fuel_stops WHERE carId = c.id) as avgPricePerLiter,
             (SELECT AVG(totalPrice) FROM fuel_stops WHERE carId = c.id) as avgCostPerStop,
             (SELECT AVG(liters) FROM fuel_stops WHERE carId = c.id) as avgLitersPerStop,
             (SELECT AVG(distance) FROM fuel_stops WHERE carId = c.id) as avgDistancePerStop,
             (SELECT AVG((liters / distance) * 100) FROM fuel_stops WHERE carId = c.id) as avgConsumption
      FROM cars c
    ''');
  }
  // Gets the combined total spend per month from both fuel and maintenance
 // Gets the monthly spend, split into Fuel, Maintenance, and Total
  Future<List<Map<String, dynamic>>> getMonthlySpend() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT 
        monthYear, 
        SUM(fuelSpend) as fuelSpend, 
        SUM(maintSpend) as maintSpend, 
        SUM(fuelSpend) + SUM(maintSpend) as totalSpend
      FROM (
        SELECT substr(date, 1, 7) as monthYear, totalPrice as fuelSpend, 0 as maintSpend 
        FROM fuel_stops 
        WHERE date IS NOT NULL AND date != ''
        
        UNION ALL
        
        SELECT substr(date, 1, 7) as monthYear, 0 as fuelSpend, totalPrice as maintSpend 
        FROM maintenance_stops 
        WHERE date IS NOT NULL AND date != ''
      )
      GROUP BY monthYear
      ORDER BY monthYear DESC
    ''');
  }
}