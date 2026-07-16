import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class DatabaseHelper {
  static const _databaseName = "FuelAppDatabase.db";
  static const _databaseVersion = 3;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<bool> importDatabaseFromJson() async {
  try {
    // 1. Let user pick a file
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return false; // User canceled the picker

    // Read the file once
    File file = File(result.files.single.path!);
    String jsonString = await file.readAsString();

    // 2. Decode the JSON (Catches format errors automatically)
    dynamic decodedData = jsonDecode(jsonString);

    // 3. VALIDATION: Check the overarching structure
    if (decodedData is! Map<String, dynamic>) {
      throw Exception("Invalid backup file: Root is not an object.");
    }

    // Validate that ALL your specific tables exist in the backup file
    final expectedTables = [
      'cars', 
      'fuel_stops', 
      'maintenance_stops', 
      'stations', 
      'companies'
    ];
    
    for (String table in expectedTables) {
      if (!decodedData.containsKey(table) || decodedData[table] is! List) {
         throw Exception("Invalid backup file: Missing '$table' data.");
      }
    }

    // If it passes validation, we proceed
    Map<String, dynamic> jsonData = decodedData;

    // 4. Clear current data before importing (Crucial to avoid conflicts)
    await clearAllData(); 

    // 5. Insert the data safely using a transaction
    final db = await instance.database;
    await db.transaction((txn) async {
      
      for (var car in jsonData['cars']) {
        await txn.insert('cars', car);
      }
      for (var fuelStop in jsonData['fuel_stops']) {
        await txn.insert('fuel_stops', fuelStop);
      }
      for (var maintenanceStop in jsonData['maintenance_stops']) {
        await txn.insert('maintenance_stops', maintenanceStop);
      }
      for (var station in jsonData['stations']) {
        await txn.insert('stations', station);
      }
      for (var company in jsonData['companies']) {
        await txn.insert('companies', company);
      }
      
    });

    print("Import successful!");
    return true; // Success!

  } catch (e) {
    // Catches any file reading errors, JSON decoding errors, or validation errors
    print("Import Error: $e");
    return false; // Failed!
  }
}

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> clearAllData() async {
  final db = await instance.database;
  
  // Use a transaction to ensure all tables are cleared successfully
  await db.transaction((txn) async {
    await txn.delete('cars');      // Replace with your table name
    await txn.delete('stations');
    await txn.delete('companies');
    await txn.delete('fuel_stops');
    await txn.delete('maintenance_stops');
  });
  
  print("All data records have been deleted, but the database file remains.");
  }

  Future<void> clearAllDataFuelstops() async {
  final db = await instance.database;
  // Use a transaction to ensure all tables are cleared successfully
  await db.transaction((txn) async {
    await txn.delete('fuel_stops');
  });
  print("All data records in fuel_stops have been deleted, but the database file remains.");
  }

  Future<void> clearAllDataMaintenanceStops() async {
  final db = await instance.database;
  // Use a transaction to ensure all tables are cleared successfully
  await db.transaction((txn) async {
    await txn.delete('maintenance_stops');
  });
  print("All data records in maintenance_stops have been deleted, but the database file remains.");
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
        soldPrice REAL,
        imagePath TEXT,
        additionalInfo TEXT
      )
    ''');

    // 2. Gas Stations Table
    await db.execute('''
      CREATE TABLE stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT,
        type TEXT,
        imagePath TEXT,
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
        imagePath TEXT,
        additionalInfo TEXT
      )
    ''');

    // 4. Fuel Stops Table
    await db.execute('''
      CREATE TABLE fuel_stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId INTEGER NOT NULL,
        stationId INTEGER,
        distance REAL,
        liters REAL,
        totalPrice REAL,
        imagePath TEXT,
        additionalInfo TEXT,
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
        imagePath TEXT,
        additionalInfo TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY (carId) REFERENCES cars (id),
        FOREIGN KEY (companyId) REFERENCES companies (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // 1. Update Cars Table
    await db.execute("ALTER TABLE cars ADD COLUMN imagePath TEXT;");
    await db.execute("ALTER TABLE cars ADD COLUMN additionalInfo TEXT;");

    // 2. Update Fuel Stops Table
    await db.execute("ALTER TABLE fuel_stops ADD COLUMN imagePath TEXT;");
    await db.execute("ALTER TABLE fuel_stops ADD COLUMN additionalInfo TEXT;");

    // 3. Update Maintenance Stops Table (if you have one)
    await db.execute("ALTER TABLE maintenance_stops ADD COLUMN imagePath TEXT;");

    // 4. Update Stations Table
    await db.execute("ALTER TABLE stations ADD COLUMN imagePath TEXT;");
    // (Note: If your stations table already had 'additionalInfo', skip adding it again here to avoid a crash!)

    // 5. Update Companies Table (if you have one)
    await db.execute("ALTER TABLE companies ADD COLUMN imagePath TEXT;");
  }
  if (oldVersion < 3) {
  // 1. Create a temporary table that allows stationId to be NULL
  await db.execute('''
    CREATE TABLE fuel_stops_new (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      carId INTEGER NOT NULL,
      stationId INTEGER, -- <-- Look! No "NOT NULL" here!
      distance REAL,
      liters REAL,
      totalPrice REAL,
      date TEXT,
      imagePath TEXT,
      additionalInfo TEXT
      -- (If you added 'isBusinessTrip' or anything else, add it here too!)
    )
  ''');

  // 2. Copy ALL the existing data from the old table into the new one
  await db.execute('''
    INSERT INTO fuel_stops_new (id, carId, stationId, distance, liters, totalPrice, date, imagePath, additionalInfo)
    SELECT id, carId, stationId, distance, liters, totalPrice, date, imagePath, additionalInfo 
    FROM fuel_stops;
  ''');

  // 3. Destroy the old, stubborn table
  await db.execute('DROP TABLE fuel_stops;');

  // 4. Rename the new table to match the old one
  await db.execute('ALTER TABLE fuel_stops_new RENAME TO fuel_stops;');
}
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
      LIMIT 3
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
      LIMIT 3
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
      SELECT  c.id,
              c.carName, 
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