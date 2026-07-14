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
  String get dashboard => 'Dashboard';

  @override
  String get recentfuelstop => 'Recent Fuel Stops';

  @override
  String get nofuelstopsyet =>
      'No fuel stops recorded yet. Tap the + button to add one!';

  @override
  String get recentmaintenancestop => 'Recent Maintenance';

  @override
  String get nomaintenanceyet => 'No maintenance recorded yet.';

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
