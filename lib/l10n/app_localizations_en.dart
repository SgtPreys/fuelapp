// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fuel Tracker';

  @override
  String get addFuelStop => 'Add Fuel Stop';

  @override
  String get addMaintenanceStop => 'Add Maintenance';

  @override
  String get addGasStation => 'Add Gas Station';

  @override
  String get addCompany => 'Add Company';

  @override
  String get addNewCar => 'Add New Car';

  @override
  String get fuel => 'Fuel';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get stations => 'Stations';

  @override
  String get companies => 'Companies';

  @override
  String get cars => 'Cars';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get recentfuelstop => 'Recent Fuel Stops';

  @override
  String get nofuelstopsyet =>
      'No fuel stops recorded yet. Tap the + button to add one!';

  @override
  String get recentmaintenancestop => 'Recent Maintenance';

  @override
  String get nomaintenanceyet =>
      'No maintenance recorded yet. Tap the + button to add one!';

  @override
  String get photolibrary => 'Photo Library';

  @override
  String get camera => 'Camera';

  @override
  String get selectcarfirst => 'Please select a Car and a Station!';

  @override
  String get editfuelstop => 'Edit Fuel Stop';

  @override
  String get selectcar => 'Select Vehicle*';

  @override
  String get nocarsavailable =>
      'No cars recorded yet. Tap the + button to add one!';

  @override
  String get selectstation => 'Select Gas Station*';

  @override
  String get nostationsavailable => 'No Stations Available - Add one first!';

  @override
  String get drivendistance => 'Driven Distance (km)';

  @override
  String get liters => 'Liters';

  @override
  String get price => 'Total Price (€)';

  @override
  String get dateandtime => 'Date & Time*';

  @override
  String get additionalinfo => 'Additional Info';

  @override
  String get addphoto => 'Add Photo';

  @override
  String get changephoto => 'Change Photo';

  @override
  String get updatefuelstop => 'Update Fuel Stop';

  @override
  String get savefuelstop => 'Save Fuel Stop';

  @override
  String get deletefuelstop => 'Delete Fuel Stop';

  @override
  String get pleasefillfields => 'Please fill out all required fields.';

  @override
  String get editmaintenancestop => 'Edit Maintenance';

  @override
  String get selectcompany => 'Select Shop/Company*';

  @override
  String get nocompanyavailable =>
      'No companies recorded yet. Tap the + button to add one!';

  @override
  String get occurrence => 'Occurrence Type*';

  @override
  String get updatemaintenance => 'Update Maintenance';

  @override
  String get savemaintenance => 'Save Maintenance';

  @override
  String get deletemaintenance => 'Delete Maintenance';

  @override
  String get pleaseentercompany => 'Please enter a Company Name!';

  @override
  String get editcompany => 'Edit Company / Shop';

  @override
  String get addcompany => 'Add Company / Shop';

  @override
  String get companyname => 'Company Name*';

  @override
  String get location => 'Location / Address';

  @override
  String get contactperson => 'Contact Person';

  @override
  String get emailaddress => 'Email Address';

  @override
  String get telephonenumber => 'Telephone Number';

  @override
  String get website => 'Website';

  @override
  String get updatecompany => 'Update Company';

  @override
  String get savecompany => 'Save Company';

  @override
  String get deletecompany => 'Delete Company';

  @override
  String get deletecompanytext =>
      'Are you sure you want to delete this company? This action cannot be undone. In doing so you also delete all related data!';

  @override
  String get pleaseenterstation => 'Please enter a Station Name!';

  @override
  String get nogasstations =>
      'No Gas Stations recorded yet. Tap the + button to add one!';

  @override
  String get editstation => 'Edit Gas Station';

  @override
  String get stationname => 'Station Name*';

  @override
  String get type => 'Type';

  @override
  String get updatestation => 'Update Gas Station';

  @override
  String get savestation => 'Save Gas Station';

  @override
  String get deletestation => 'Delete Gas Station';

  @override
  String get deletestationtext =>
      'Are you sure you want to delete this gas station? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!';

  @override
  String get pleaseentercarname => 'Please enter a Car Name!';

  @override
  String get editcar => 'Edit Vehicle';

  @override
  String get basicinfo => 'Basic Information';

  @override
  String get carname => 'Car Name*';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get yearofmanufacture => 'Year of Manufacture';

  @override
  String get status => 'Status';

  @override
  String get specifications => 'Specifications & Details';

  @override
  String get plate => 'License Plate';

  @override
  String get nexttuev => 'Next TÜV (MM/YYYY)';

  @override
  String get fueltype => 'Fuel Type';

  @override
  String get tiretype => 'Tire Type';

  @override
  String get financials => 'Financials';

  @override
  String get boughtdate => 'Bought Date';

  @override
  String get boughtprice => 'Bought Price';

  @override
  String get solddate => 'Sold Date';

  @override
  String get soldprice => 'Sold Price';

  @override
  String get updatecar => 'Update Vehicle';

  @override
  String get savecar => 'Save Vehicle';

  @override
  String get deletecar => 'Delete Vehicle';

  @override
  String get deletecartext =>
      'Are you sure you want to delete this vehicle? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!';

  @override
  String get performancepervehicle => 'Performance per Vehicle';

  @override
  String get settings => 'Settings';

  @override
  String get appinfo => 'App Info';

  @override
  String get createdby => 'Created by:';

  @override
  String get testedby => 'Tested by:';

  @override
  String get databasemanagement => 'Database Management';

  @override
  String get importdatabase => 'Import Database';

  @override
  String get confirmimport => '⚠️Confirm Import';

  @override
  String get confirmimporttext =>
      'Are you sure you want to import the database? This will overwrite existing data.\n\nMake sure you have a backup before proceeding. \n\nOnly import JSON files that were exported from this app!';

  @override
  String get cancel => 'Cancel';

  @override
  String get importcomplete => 'Import complete! Refreshing...';

  @override
  String get importincomplete => 'Failed to import. Invalid file format.';

  @override
  String get import => 'Import';

  @override
  String get exportdatabase => 'Export Database';

  @override
  String databaseexported(String filePath) {
    return 'Database exported to: $filePath';
  }

  @override
  String get deletedata => 'Delete Data';

  @override
  String get deletealldata => 'Delete All Data';

  @override
  String get confirmdeletion => '⚠️Confirm Deletion';

  @override
  String get confirmdeletiontext =>
      'Are you sure you want to delete all data? This action cannot be undone.';

  @override
  String get databasecleared => 'Database cleared!';

  @override
  String get delete => 'Delete';

  @override
  String get deleteallfueldata => 'Delete All Fuel Data';

  @override
  String get deleteallmaintenancedata => 'Delete All Maintenance Data';

  @override
  String get preferences => 'Preferences';

  @override
  String get enabledarkmode => 'Enable Dark Mode';

  @override
  String get languagesettings => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get system => 'System';

  @override
  String get sendfeedback => 'Send Feedback';

  @override
  String get sendfeedbacktitel => 'Feedback Fuel Expense Tracker';

  @override
  String get sendfeedbacktext =>
      'Hi, I have the following feedback for your app:\n\n';

  @override
  String get homeTitle => 'Home';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get dataTitle => 'Manage Data';

  @override
  String get settingsTitle => 'Settings & More';

  @override
  String get homenavitem => 'Home';

  @override
  String get statsnavitem => 'Stats';

  @override
  String get datanavitem => 'Data';

  @override
  String get settingsnavitem => 'Settings';
}
