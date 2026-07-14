import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuel Tracker'**
  String get appTitle;

  /// No description provided for @addFuelStop.
  ///
  /// In en, this message translates to:
  /// **'Add Fuel Stop'**
  String get addFuelStop;

  /// No description provided for @addMaintenanceStop.
  ///
  /// In en, this message translates to:
  /// **'Add Maintenance'**
  String get addMaintenanceStop;

  /// No description provided for @addGasStation.
  ///
  /// In en, this message translates to:
  /// **'Add Gas Station'**
  String get addGasStation;

  /// No description provided for @addCompany.
  ///
  /// In en, this message translates to:
  /// **'Add Company'**
  String get addCompany;

  /// No description provided for @addNewCar.
  ///
  /// In en, this message translates to:
  /// **'Add New Car'**
  String get addNewCar;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @recentfuelstop.
  ///
  /// In en, this message translates to:
  /// **'Recent Fuel Stops'**
  String get recentfuelstop;

  /// No description provided for @nofuelstopsyet.
  ///
  /// In en, this message translates to:
  /// **'No fuel stops recorded yet. Tap the + button to add one!'**
  String get nofuelstopsyet;

  /// No description provided for @recentmaintenancestop.
  ///
  /// In en, this message translates to:
  /// **'Recent Maintenance'**
  String get recentmaintenancestop;

  /// No description provided for @nomaintenanceyet.
  ///
  /// In en, this message translates to:
  /// **'No maintenance recorded yet.'**
  String get nomaintenanceyet;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appinfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appinfo;

  /// No description provided for @createdby.
  ///
  /// In en, this message translates to:
  /// **'Created by:'**
  String get createdby;

  /// No description provided for @testedby.
  ///
  /// In en, this message translates to:
  /// **'Tested by:'**
  String get testedby;

  /// No description provided for @databasemanagement.
  ///
  /// In en, this message translates to:
  /// **'Database Management'**
  String get databasemanagement;

  /// No description provided for @importdatabase.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importdatabase;

  /// No description provided for @confirmimport.
  ///
  /// In en, this message translates to:
  /// **'⚠️Confirm Import'**
  String get confirmimport;

  /// No description provided for @confirmimporttext.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to import the database? This will overwrite existing data.\n\nMake sure you have a backup before proceeding. \n\nOnly import JSON files that were exported from this app!'**
  String get confirmimporttext;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @importcomplete.
  ///
  /// In en, this message translates to:
  /// **'Import complete! Refreshing...'**
  String get importcomplete;

  /// No description provided for @importincomplete.
  ///
  /// In en, this message translates to:
  /// **'Failed to import. Invalid file format.'**
  String get importincomplete;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @exportdatabase.
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportdatabase;

  /// The path where the file is exported to
  ///
  /// In en, this message translates to:
  /// **'Database exported to: {filePath}'**
  String databaseexported(String filePath);

  /// No description provided for @deletedata.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deletedata;

  /// No description provided for @deletealldata.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deletealldata;

  /// No description provided for @confirmdeletion.
  ///
  /// In en, this message translates to:
  /// **'⚠️Confirm Deletion'**
  String get confirmdeletion;

  /// No description provided for @confirmdeletiontext.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This action cannot be undone.'**
  String get confirmdeletiontext;

  /// No description provided for @databasecleared.
  ///
  /// In en, this message translates to:
  /// **'Database cleared!'**
  String get databasecleared;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteallfueldata.
  ///
  /// In en, this message translates to:
  /// **'Delete All Fuel Data'**
  String get deleteallfueldata;

  /// No description provided for @deleteallmaintenancedata.
  ///
  /// In en, this message translates to:
  /// **'Delete All Maintenance Data'**
  String get deleteallmaintenancedata;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @enabledarkmode.
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enabledarkmode;

  /// No description provided for @languagesettings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagesettings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @sendfeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendfeedback;

  /// No description provided for @sendfeedbacktitel.
  ///
  /// In en, this message translates to:
  /// **'Feedback Fuel Expense Tracker'**
  String get sendfeedbacktitel;

  /// No description provided for @sendfeedbacktext.
  ///
  /// In en, this message translates to:
  /// **'Hi, I have the following feedback for your app:\n\n'**
  String get sendfeedbacktext;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Data'**
  String get dataTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & More'**
  String get settingsTitle;

  /// No description provided for @homenavitem.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homenavitem;

  /// No description provided for @statsnavitem.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsnavitem;

  /// No description provided for @datanavitem.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get datanavitem;

  /// No description provided for @settingsnavitem.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsnavitem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
