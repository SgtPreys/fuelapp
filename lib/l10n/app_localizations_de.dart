// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fuel Tracker';

  @override
  String get addFuelStop => 'Tankstopp Hinzufügen';

  @override
  String get addMaintenanceStop => 'Wartung Hinzufügen';

  @override
  String get addGasStation => 'Tankstelle Hinzufügen';

  @override
  String get addCompany => 'Unternehmen Hinzufügen';

  @override
  String get addNewCar => 'Auto Hinzufügen';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get recentfuelstop => 'Kürzliche Tankstopps';

  @override
  String get nofuelstopsyet =>
      'Noch keine Tankstopps erfasst. Tippe auf die +-Taste, um einen hinzuzufügen!';

  @override
  String get recentmaintenancestop => 'Kürzliche Wartungen';

  @override
  String get nomaintenanceyet => 'Noch keine Wartung erfasst.';

  @override
  String get photolibrary => 'Bilder Bibliothek';

  @override
  String get camera => 'Kamera';

  @override
  String get selectcarfirst =>
      'Bitte wählen Sie ein Auto und eine Station aus!';

  @override
  String get editfuelstop => 'Tankstopp bearbeiten';

  @override
  String get selectcar => 'Fahrzeug Auswählen*';

  @override
  String get nocarsavailable =>
      'Keine Autos verfügbar – fügen Sie zuerst eines hinzu!';

  @override
  String get selectstation => 'Tankstelle auswählen*';

  @override
  String get nostationsavailable =>
      'Keine Tankstelle verfügbar – fügen Sie zuerst einen hinzu!';

  @override
  String get drivendistance => 'Gefahrene Strecke (km)';

  @override
  String get liters => 'Liter';

  @override
  String get price => 'Gesamtpreis (€)';

  @override
  String get dateandtime => 'Datum & Uhrzeit*';

  @override
  String get additionalinfo => 'Zusätzliche Informationen';

  @override
  String get addphoto => 'Foto hinzufügen';

  @override
  String get changephoto => 'Foto ändern';

  @override
  String get updatefuelstop => 'Tankstopp Aktualisieren';

  @override
  String get savefuelstop => 'Tankstopp Speichern';

  @override
  String get deletefuelstop => 'Tankstopp Löschen';

  @override
  String get pleasefillfields => 'Bitte füllen Sie alle Pflichtfelder aus.';

  @override
  String get editmaintenancestop => 'Wartung Bearbeiten';

  @override
  String get selectcompany => 'Geschäft/Unternehmen auswählen*';

  @override
  String get nocompanyavailable =>
      'Keine Geschäfte verfügbar – fügen Sie zuerst eines hinzu!';

  @override
  String get occurrence => 'Art des Ereignisses*';

  @override
  String get updatemaintenance => 'Wartung Updaten';

  @override
  String get savemaintenance => 'Wartung Speichern';

  @override
  String get deletemaintenance => 'Wartung Löschen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appinfo => 'App Info';

  @override
  String get createdby => 'Erstellt von:';

  @override
  String get testedby => 'Getestet von:';

  @override
  String get databasemanagement => 'Datenbank Management';

  @override
  String get importdatabase => 'Datenbank Importieren';

  @override
  String get confirmimport => '⚠️Dem Import Zustimmen';

  @override
  String get confirmimporttext =>
      'Sind Sie sicher, dass Sie die Datenbank importieren möchten? Dadurch werden vorhandene Daten überschrieben.\n\nStellen Sie sicher, dass Sie ein Backup erstellt haben, bevor Sie fortfahren.\n\nImportieren Sie nur JSON-Dateien, die aus dieser App exportiert wurden!';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get importcomplete => 'Import abgeschlossen! Wird neu geladen...';

  @override
  String get importincomplete =>
      'Import fehlgeschlagen. Ungültiges Dateiformat.';

  @override
  String get import => 'Import';

  @override
  String get exportdatabase => 'Datenbank Exportieren';

  @override
  String databaseexported(String filePath) {
    return 'Datenbank exportiert nach: $filePath';
  }

  @override
  String get deletedata => 'Daten Löschen';

  @override
  String get deletealldata => 'Alle Daten Löschen';

  @override
  String get confirmdeletion => '⚠️Der Löschung Zustimmen';

  @override
  String get confirmdeletiontext =>
      'Sind Sie sicher, dass Sie alle Daten löschen möchten? Dieser Vorgang kann nicht rückgängig gemacht werden.';

  @override
  String get databasecleared => 'Datenbank geräumt!';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteallfueldata => 'Alle Kraftstoffdaten löschen';

  @override
  String get deleteallmaintenancedata => 'Alle Wartungsdaten löschen';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get enabledarkmode => 'Dunkelmodus aktivieren';

  @override
  String get languagesettings => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';

  @override
  String get system => 'System';

  @override
  String get sendfeedback => 'Feedback senden';

  @override
  String get sendfeedbacktitel => 'Feedback zum Kraftstoffkosten-Tracker';

  @override
  String get sendfeedbacktext =>
      'Hallo, ich habe folgendes Feedback zu Ihrer App:';

  @override
  String get homeTitle => 'Startseite';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get dataTitle => 'Daten verwalten';

  @override
  String get settingsTitle => 'Einstellungen & Mehr';

  @override
  String get homenavitem => 'Start';

  @override
  String get statsnavitem => 'Statistik';

  @override
  String get datanavitem => 'Daten';

  @override
  String get settingsnavitem => 'Einstellungen';
}
