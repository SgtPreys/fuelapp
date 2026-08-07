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

  /// No description provided for @fuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @companies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// No description provided for @cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

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
  /// **'No maintenance recorded yet. Tap the + button to add one!'**
  String get nomaintenanceyet;

  /// No description provided for @photolibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photolibrary;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectcarfirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a Car and a Station!'**
  String get selectcarfirst;

  /// No description provided for @editfuelstop.
  ///
  /// In en, this message translates to:
  /// **'Edit Fuel Stop'**
  String get editfuelstop;

  /// No description provided for @selectcar.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle*'**
  String get selectcar;

  /// No description provided for @nocarsavailable.
  ///
  /// In en, this message translates to:
  /// **'No cars Available - Add one first!'**
  String get nocarsavailable;

  /// No description provided for @selectstation.
  ///
  /// In en, this message translates to:
  /// **'Select Gas Station'**
  String get selectstation;

  /// No description provided for @nostationsavailable.
  ///
  /// In en, this message translates to:
  /// **'No Stations Available - Add one first!'**
  String get nostationsavailable;

  /// No description provided for @drivendistance.
  ///
  /// In en, this message translates to:
  /// **'Driven Distance (km)'**
  String get drivendistance;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liters;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Total Price (€)'**
  String get price;

  /// No description provided for @dateandtime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time*'**
  String get dateandtime;

  /// No description provided for @additionalinfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Info'**
  String get additionalinfo;

  /// No description provided for @addphoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addphoto;

  /// No description provided for @changephoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changephoto;

  /// No description provided for @updatefuelstop.
  ///
  /// In en, this message translates to:
  /// **'Update Fuel Stop'**
  String get updatefuelstop;

  /// No description provided for @savefuelstop.
  ///
  /// In en, this message translates to:
  /// **'Save Fuel Stop'**
  String get savefuelstop;

  /// No description provided for @deletefuelstop.
  ///
  /// In en, this message translates to:
  /// **'Delete Fuel Stop'**
  String get deletefuelstop;

  /// No description provided for @pleasefillfields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all required fields.'**
  String get pleasefillfields;

  /// No description provided for @editmaintenancestop.
  ///
  /// In en, this message translates to:
  /// **'Edit Maintenance'**
  String get editmaintenancestop;

  /// No description provided for @selectcompany.
  ///
  /// In en, this message translates to:
  /// **'Select Shop/Company*'**
  String get selectcompany;

  /// No description provided for @nocompanyavailable.
  ///
  /// In en, this message translates to:
  /// **'No companies recorded yet. Tap the + button to add one!'**
  String get nocompanyavailable;

  /// No description provided for @occurrence.
  ///
  /// In en, this message translates to:
  /// **'Occurrence Type*'**
  String get occurrence;

  /// No description provided for @updatemaintenance.
  ///
  /// In en, this message translates to:
  /// **'Update Maintenance'**
  String get updatemaintenance;

  /// No description provided for @savemaintenance.
  ///
  /// In en, this message translates to:
  /// **'Save Maintenance'**
  String get savemaintenance;

  /// No description provided for @deletemaintenance.
  ///
  /// In en, this message translates to:
  /// **'Delete Maintenance'**
  String get deletemaintenance;

  /// No description provided for @pleaseentercompany.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Company Name!'**
  String get pleaseentercompany;

  /// No description provided for @editcompany.
  ///
  /// In en, this message translates to:
  /// **'Edit Company / Shop'**
  String get editcompany;

  /// No description provided for @addcompany.
  ///
  /// In en, this message translates to:
  /// **'Add Company / Shop'**
  String get addcompany;

  /// No description provided for @companyname.
  ///
  /// In en, this message translates to:
  /// **'Company Name*'**
  String get companyname;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location / Address'**
  String get location;

  /// No description provided for @contactperson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactperson;

  /// No description provided for @emailaddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailaddress;

  /// No description provided for @telephonenumber.
  ///
  /// In en, this message translates to:
  /// **'Telephone Number'**
  String get telephonenumber;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @updatecompany.
  ///
  /// In en, this message translates to:
  /// **'Update Company'**
  String get updatecompany;

  /// No description provided for @savecompany.
  ///
  /// In en, this message translates to:
  /// **'Save Company'**
  String get savecompany;

  /// No description provided for @deletecompany.
  ///
  /// In en, this message translates to:
  /// **'Delete Company'**
  String get deletecompany;

  /// No description provided for @deletecompanytext.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this company? This action cannot be undone. In doing so you also delete all related data!'**
  String get deletecompanytext;

  /// No description provided for @pleaseenterstation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Station Name!'**
  String get pleaseenterstation;

  /// No description provided for @nogasstations.
  ///
  /// In en, this message translates to:
  /// **'No Gas Stations recorded yet. Tap the + button to add one!'**
  String get nogasstations;

  /// No description provided for @editstation.
  ///
  /// In en, this message translates to:
  /// **'Edit Gas Station'**
  String get editstation;

  /// No description provided for @stationname.
  ///
  /// In en, this message translates to:
  /// **'Station Name*'**
  String get stationname;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @updatestation.
  ///
  /// In en, this message translates to:
  /// **'Update Gas Station'**
  String get updatestation;

  /// No description provided for @savestation.
  ///
  /// In en, this message translates to:
  /// **'Save Gas Station'**
  String get savestation;

  /// No description provided for @deletestation.
  ///
  /// In en, this message translates to:
  /// **'Delete Gas Station'**
  String get deletestation;

  /// No description provided for @deletestationtext.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this gas station? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!'**
  String get deletestationtext;

  /// No description provided for @pleaseentercarname.
  ///
  /// In en, this message translates to:
  /// **'Please enter a Car Name!'**
  String get pleaseentercarname;

  /// No description provided for @editcar.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editcar;

  /// No description provided for @basicinfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicinfo;

  /// No description provided for @carname.
  ///
  /// In en, this message translates to:
  /// **'Car Name*'**
  String get carname;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @yearofmanufacture.
  ///
  /// In en, this message translates to:
  /// **'Year of Manufacture (YYYY)'**
  String get yearofmanufacture;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications & Details'**
  String get specifications;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get plate;

  /// No description provided for @nexttuev.
  ///
  /// In en, this message translates to:
  /// **'Next TÜV (MM/YYYY)'**
  String get nexttuev;

  /// No description provided for @fueltype.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fueltype;

  /// No description provided for @tiretype.
  ///
  /// In en, this message translates to:
  /// **'Tire Type'**
  String get tiretype;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @boughtdate.
  ///
  /// In en, this message translates to:
  /// **'Bought Date'**
  String get boughtdate;

  /// No description provided for @boughtprice.
  ///
  /// In en, this message translates to:
  /// **'Bought Price'**
  String get boughtprice;

  /// No description provided for @solddate.
  ///
  /// In en, this message translates to:
  /// **'Sold Date'**
  String get solddate;

  /// No description provided for @soldprice.
  ///
  /// In en, this message translates to:
  /// **'Sold Price'**
  String get soldprice;

  /// No description provided for @updatecar.
  ///
  /// In en, this message translates to:
  /// **'Update Vehicle'**
  String get updatecar;

  /// No description provided for @savecar.
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle'**
  String get savecar;

  /// No description provided for @deletecar.
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deletecar;

  /// No description provided for @deletecartext.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vehicle? This action cannot be undone. In doing so you also delete all related data (fuel, maintenance, etc.)!'**
  String get deletecartext;

  /// No description provided for @noadditionalinfo.
  ///
  /// In en, this message translates to:
  /// **'No additional information available.'**
  String get noadditionalinfo;

  /// No description provided for @searcheverything.
  ///
  /// In en, this message translates to:
  /// **'Search everything...'**
  String get searcheverything;

  /// No description provided for @performancepervehicle.
  ///
  /// In en, this message translates to:
  /// **'Performance per Vehicle'**
  String get performancepervehicle;

  /// No description provided for @chartconsumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption (L/100km)'**
  String get chartconsumption;

  /// No description provided for @chartpriceperliter.
  ///
  /// In en, this message translates to:
  /// **'Price per Liter (€/L)'**
  String get chartpriceperliter;

  /// No description provided for @totalcosts.
  ///
  /// In en, this message translates to:
  /// **'Total Costs'**
  String get totalcosts;

  /// No description provided for @totalrunningcost.
  ///
  /// In en, this message translates to:
  /// **'Total Running Cost'**
  String get totalrunningcost;

  /// No description provided for @totaldistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totaldistance;

  /// No description provided for @fuelcosts.
  ///
  /// In en, this message translates to:
  /// **'Fuel Costs'**
  String get fuelcosts;

  /// No description provided for @efficiencyandaverages.
  ///
  /// In en, this message translates to:
  /// **'Efficiency & Averages'**
  String get efficiencyandaverages;

  /// No description provided for @avgconsumption.
  ///
  /// In en, this message translates to:
  /// **'Avg. Consumption'**
  String get avgconsumption;

  /// No description provided for @costperkm.
  ///
  /// In en, this message translates to:
  /// **'Cost per km'**
  String get costperkm;

  /// No description provided for @monthlyspend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spend'**
  String get monthlyspend;

  /// No description provided for @avgmonthlyfuel.
  ///
  /// In en, this message translates to:
  /// **'Avg. Monthly Fuel'**
  String get avgmonthlyfuel;

  /// No description provided for @avgmonthlymaint.
  ///
  /// In en, this message translates to:
  /// **'Avg. Monthly Maint.'**
  String get avgmonthlymaint;

  /// No description provided for @avgmonthlytotal.
  ///
  /// In en, this message translates to:
  /// **'Avg. Monthly Total'**
  String get avgmonthlytotal;

  /// No description provided for @yearlyspend.
  ///
  /// In en, this message translates to:
  /// **'Yearly Spend'**
  String get yearlyspend;

  /// No description provided for @avgyearlyfuel.
  ///
  /// In en, this message translates to:
  /// **'Avg. Yearly Fuel'**
  String get avgyearlyfuel;

  /// No description provided for @avgyearlymaint.
  ///
  /// In en, this message translates to:
  /// **'Avg. Yearly Maint.'**
  String get avgyearlymaint;

  /// No description provided for @avgyearlytotal.
  ///
  /// In en, this message translates to:
  /// **'Avg. Yearly Total'**
  String get avgyearlytotal;

  /// No description provided for @nodatayet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get nodatayet;

  /// No description provided for @expensecalender.
  ///
  /// In en, this message translates to:
  /// **'Expense Calender'**
  String get expensecalender;

  /// No description provided for @fuelstop.
  ///
  /// In en, this message translates to:
  /// **'Fuel Stop'**
  String get fuelstop;

  /// No description provided for @noexpensesonthisday.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded on this day.'**
  String get noexpensesonthisday;

  /// No description provided for @notenoughdatatodrawchart.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw chart yet. Log at least two stops!'**
  String get notenoughdatatodrawchart;

  /// No description provided for @unknownlocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownlocation;

  /// No description provided for @unknowncontact.
  ///
  /// In en, this message translates to:
  /// **'Unknown contact person'**
  String get unknowncontact;

  /// No description provided for @unknowntelephone.
  ///
  /// In en, this message translates to:
  /// **'Unknown telephone number'**
  String get unknowntelephone;

  /// No description provided for @unknownmanufacturer.
  ///
  /// In en, this message translates to:
  /// **'Unknown manufacturer'**
  String get unknownmanufacturer;

  /// No description provided for @unknownstation.
  ///
  /// In en, this message translates to:
  /// **'Unknown station'**
  String get unknownstation;

  /// No description provided for @unknowncompany.
  ///
  /// In en, this message translates to:
  /// **'Unknown company'**
  String get unknowncompany;

  /// No description provided for @unknowncar.
  ///
  /// In en, this message translates to:
  /// **'Unknown vehicle'**
  String get unknowncar;

  /// No description provided for @showindropdowns.
  ///
  /// In en, this message translates to:
  /// **'Show in Dropdowns'**
  String get showindropdowns;

  /// No description provided for @keepstationvisible.
  ///
  /// In en, this message translates to:
  /// **'Keep this station visible when adding a new fuel stop.'**
  String get keepstationvisible;

  /// No description provided for @hideinactivestations.
  ///
  /// In en, this message translates to:
  /// **'Hide hidden'**
  String get hideinactivestations;

  /// No description provided for @showhiddenstations.
  ///
  /// In en, this message translates to:
  /// **'Show hidden'**
  String get showhiddenstations;

  /// No description provided for @hideinactivecompanies.
  ///
  /// In en, this message translates to:
  /// **'Hide hidden'**
  String get hideinactivecompanies;

  /// No description provided for @showhiddencompanies.
  ///
  /// In en, this message translates to:
  /// **'Show hidden'**
  String get showhiddencompanies;

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

  /// No description provided for @howto.
  ///
  /// In en, this message translates to:
  /// **'Guide/FAQ'**
  String get howto;

  /// No description provided for @guidefaqtext.
  ///
  /// In en, this message translates to:
  /// **'The Guide will be available soon!'**
  String get guidefaqtext;

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

  /// No description provided for @senddonation.
  ///
  /// In en, this message translates to:
  /// **'Send Donation'**
  String get senddonation;

  /// No description provided for @senddonationtext.
  ///
  /// In en, this message translates to:
  /// **'Thank you for wanting to send a Donation. Unfortunetely I am not receiving Donations yet.'**
  String get senddonationtext;

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
