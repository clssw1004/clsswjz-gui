import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Clsswjz'**
  String get appName;

  /// No description provided for @tabAccountItems.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get tabAccountItems;

  /// No description provided for @tabMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get tabMine;

  /// No description provided for @tabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tabNotes;

  /// No description provided for @tabStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabStatistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get notLoggedIn;

  /// No description provided for @accountBook.
  ///
  /// In en, this message translates to:
  /// **'Account Book'**
  String get accountBook;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @backendSettings.
  ///
  /// In en, this message translates to:
  /// **'Backend Settings'**
  String get backendSettings;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @selectAccountBook.
  ///
  /// In en, this message translates to:
  /// **'Select Account Book'**
  String get selectAccountBook;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load Failed'**
  String get loadFailed;

  /// No description provided for @noAccountBooks.
  ///
  /// In en, this message translates to:
  /// **'No Account Books'**
  String get noAccountBooks;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// Text to show when account item list is empty
  ///
  /// In en, this message translates to:
  /// **'No account items'**
  String get noAccountItems;

  /// Text to show when there is no more data to load
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMore;

  /// Switch to detail view
  ///
  /// In en, this message translates to:
  /// **'Detail View'**
  String get detailView;

  /// Switch to simple view
  ///
  /// In en, this message translates to:
  /// **'Simple View'**
  String get simpleView;

  /// Traditional Chinese option
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditionalChinese;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Corner Radius'**
  String get radius;

  /// No description provided for @useMaterial3.
  ///
  /// In en, this message translates to:
  /// **'Use Material 3'**
  String get useMaterial3;

  /// No description provided for @fontSizeSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get fontSizeSmaller;

  /// No description provided for @fontSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get fontSizeLarger;

  /// No description provided for @fontSizeLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get fontSizeLargest;

  /// No description provided for @radiusNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get radiusNone;

  /// No description provided for @radiusSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get radiusSmall;

  /// No description provided for @radiusMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get radiusMedium;

  /// No description provided for @radiusLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get radiusLarge;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @accountBooks.
  ///
  /// In en, this message translates to:
  /// **'Account Books'**
  String get accountBooks;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @editUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit User Info'**
  String get editUserInfo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @accountItemCount.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get accountItemCount;

  /// Number of days with records
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get accountDayCount;

  /// Search text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Add new item text
  ///
  /// In en, this message translates to:
  /// **'Add {value}'**
  String addNew(Object value);

  /// Edit something
  ///
  /// In en, this message translates to:
  /// **'Edit {value}'**
  String editTo(Object value);

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Save failed message
  ///
  /// In en, this message translates to:
  /// **'Save failed: {message}'**
  String saveFailed(String message);

  /// More options button text
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @serverConfig.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get serverConfig;

  /// Server address label
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// Username label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @checkServer.
  ///
  /// In en, this message translates to:
  /// **'Check Server'**
  String get checkServer;

  /// No description provided for @pleaseInputServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Please input server address'**
  String get pleaseInputServerAddress;

  /// No description provided for @pleaseInputUsername.
  ///
  /// In en, this message translates to:
  /// **'Please input username'**
  String get pleaseInputUsername;

  /// No description provided for @pleaseInputPassword.
  ///
  /// In en, this message translates to:
  /// **'Please input password'**
  String get pleaseInputPassword;

  /// No description provided for @pleaseCheckServerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please check server connection first'**
  String get pleaseCheckServerFirst;

  /// No description provided for @serverConnectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Server connection successful'**
  String get serverConnectionSuccess;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Server connection failed'**
  String get serverConnectionFailed;

  /// No description provided for @serverConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error'**
  String get serverConnectionError;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// Initialization failed message
  ///
  /// In en, this message translates to:
  /// **'Initialization failed'**
  String get initializationFailed;

  /// Storage mode selection label
  ///
  /// In en, this message translates to:
  /// **'Storage Mode'**
  String get storageMode;

  /// Create local database button text
  ///
  /// In en, this message translates to:
  /// **'Create Local Database'**
  String get createLocalDatabase;

  /// Local storage mode
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get offlineStorage;

  /// Self-hosted server mode
  ///
  /// In en, this message translates to:
  /// **'Self-hosted Server'**
  String get selfHostStorage;

  /// Connect server button text
  ///
  /// In en, this message translates to:
  /// **'Login and Sync'**
  String get loginAndSync;

  /// Form field optional hint text
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Select icon dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// Currency selection label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Name input label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Material Design 3 theme switch description
  ///
  /// In en, this message translates to:
  /// **'Use Material Design 3 theme'**
  String get useMaterial3Description;

  /// Theme preview title
  ///
  /// In en, this message translates to:
  /// **'Theme Preview'**
  String get themePreview;

  /// Input hint text
  ///
  /// In en, this message translates to:
  /// **'Please input {value}'**
  String pleaseInput(String value);

  /// Delete something
  ///
  /// In en, this message translates to:
  /// **'Delete {value}'**
  String delete(String value);

  /// Delete failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {value}: {message}'**
  String deleteFailed(String value, String message);

  /// Modify something
  ///
  /// In en, this message translates to:
  /// **'Modify {value}'**
  String modify(String value);

  /// Modify success message
  ///
  /// In en, this message translates to:
  /// **'{value} modified successfully'**
  String modifySuccess(String value);

  /// Modify failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to modify {value}: {message}'**
  String modifyFailed(String value, String message);

  /// Select something
  ///
  /// In en, this message translates to:
  /// **'Select {value}'**
  String select(String value);

  /// Please select something
  ///
  /// In en, this message translates to:
  /// **'Please select {value}'**
  String pleaseSelect(String value);

  /// No description provided for @tabFunds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get tabFunds;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @defaultBook.
  ///
  /// In en, this message translates to:
  /// **'Default Book'**
  String get defaultBook;

  /// No description provided for @fundTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get fundTypeCash;

  /// No description provided for @fundTypeDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get fundTypeDebitCard;

  /// No description provided for @fundTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get fundTypeCreditCard;

  /// No description provided for @fundTypePrepaidCard.
  ///
  /// In en, this message translates to:
  /// **'Prepaid Card'**
  String get fundTypePrepaidCard;

  /// No description provided for @fundTypeAlipay.
  ///
  /// In en, this message translates to:
  /// **'Alipay'**
  String get fundTypeAlipay;

  /// No description provided for @fundTypeWechat.
  ///
  /// In en, this message translates to:
  /// **'WeChat'**
  String get fundTypeWechat;

  /// No description provided for @fundTypeDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get fundTypeDebt;

  /// No description provided for @fundTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get fundTypeInvestment;

  /// No description provided for @fundTypeEWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get fundTypeEWallet;

  /// No description provided for @fundTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get fundTypeOther;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// Book sharing source
  ///
  /// In en, this message translates to:
  /// **'Shared from {name}'**
  String sharedFrom(String name);

  /// Related books list title
  ///
  /// In en, this message translates to:
  /// **'Related Books'**
  String get relatedBooks;

  /// Basic information title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// Members title
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No members prompt
  ///
  /// In en, this message translates to:
  /// **'No Members'**
  String get noMembers;

  /// Unknown user name
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// View book permission
  ///
  /// In en, this message translates to:
  /// **'View Book'**
  String get canViewBook;

  /// Edit book permission
  ///
  /// In en, this message translates to:
  /// **'Edit Book'**
  String get canEditBook;

  /// Delete book permission
  ///
  /// In en, this message translates to:
  /// **'Delete Book'**
  String get canDeleteBook;

  /// View items permission
  ///
  /// In en, this message translates to:
  /// **'View Items'**
  String get canViewItem;

  /// Edit items permission
  ///
  /// In en, this message translates to:
  /// **'Edit Items'**
  String get canEditItem;

  /// Delete items permission
  ///
  /// In en, this message translates to:
  /// **'Delete Items'**
  String get canDeleteItem;

  /// Find user dialog title
  ///
  /// In en, this message translates to:
  /// **'Find User By Invite Code'**
  String get findUserByInviteCode;

  /// Invite code input label
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCode;

  /// Member exists prompt
  ///
  /// In en, this message translates to:
  /// **'Member already exists'**
  String get memberAlreadyExists;

  /// User not found prompt
  ///
  /// In en, this message translates to:
  /// **'User not found, please try again later'**
  String get userNotFound;

  /// Book creator prompt text
  ///
  /// In en, this message translates to:
  /// **'Book Creator'**
  String get bookCreator;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @featureMultiUser.
  ///
  /// In en, this message translates to:
  /// **'Multi-user support'**
  String get featureMultiUser;

  /// No description provided for @featureMultiBook.
  ///
  /// In en, this message translates to:
  /// **'Multiple account books'**
  String get featureMultiBook;

  /// No description provided for @featureMultiCurrency.
  ///
  /// In en, this message translates to:
  /// **'Multiple currency support'**
  String get featureMultiCurrency;

  /// No description provided for @featureDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data backup and restore'**
  String get featureDataBackup;

  /// No description provided for @featureDataSync.
  ///
  /// In en, this message translates to:
  /// **'Data synchronization'**
  String get featureDataSync;

  /// No description provided for @featureCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom theme'**
  String get featureCustomTheme;

  /// No description provided for @featureMultiLanguage.
  ///
  /// In en, this message translates to:
  /// **'Multiple language support'**
  String get featureMultiLanguage;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology Stack'**
  String get technology;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// No description provided for @frontendProject.
  ///
  /// In en, this message translates to:
  /// **'Current Project'**
  String get frontendProject;

  /// No description provided for @backendProject.
  ///
  /// In en, this message translates to:
  /// **'Backend Self-hosted sync Project'**
  String get backendProject;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// Error message when unable to open a link
  ///
  /// In en, this message translates to:
  /// **'Cannot open link: {message}'**
  String cannotOpenLink(String message);

  /// No description provided for @unsupportedLinkType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported link type'**
  String get unsupportedLinkType;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get noCategory;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @noShop.
  ///
  /// In en, this message translates to:
  /// **'No Merchant'**
  String get noShop;

  /// No description provided for @noGroup.
  ///
  /// In en, this message translates to:
  /// **'No Group'**
  String get noGroup;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments'**
  String get noAttachments;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get addAttachment;

  /// No description provided for @deleteAttachment.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment'**
  String get deleteAttachment;

  /// No description provided for @uploadAttachment.
  ///
  /// In en, this message translates to:
  /// **'Upload attachment'**
  String get uploadAttachment;

  /// Button text for adding another account item
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get addAnother;

  /// Attachment number
  ///
  /// In en, this message translates to:
  /// **'{num} items'**
  String attachNum(int num);

  /// Account item
  ///
  /// In en, this message translates to:
  /// **'Account Item'**
  String get accountItem;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync Successful'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get dataSource;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Sync start message
  ///
  /// In en, this message translates to:
  /// **'Start syncing, last sync time: {time}'**
  String syncStarting(String time);

  /// No description provided for @neverSync.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get neverSync;

  /// No description provided for @gettingLocalChanges.
  ///
  /// In en, this message translates to:
  /// **'Getting local changes'**
  String get gettingLocalChanges;

  /// Local changes count prompt
  ///
  /// In en, this message translates to:
  /// **'Local changes count: {count}'**
  String localChangeCount(int count);

  /// No description provided for @uploadingAttachments.
  ///
  /// In en, this message translates to:
  /// **'Uploading attachments: {count}'**
  String uploadingAttachments(int count);

  /// No description provided for @attachmentUploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Attachments upload complete'**
  String get attachmentUploadComplete;

  /// No description provided for @syncingLocalChanges.
  ///
  /// In en, this message translates to:
  /// **'Syncing local changes: {count}'**
  String syncingLocalChanges(int count);

  /// No description provided for @localChangeSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Local changes sync complete: {total}, success: {success}, failed: {failed}'**
  String localChangeSyncComplete(int total, int success, int failed);

  /// No description provided for @syncingLocalChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Syncing local change status: {count}'**
  String syncingLocalChangeStatus(int count);

  /// No description provided for @syncingLocalChangeStatusProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing local change status ({current}/{total})'**
  String syncingLocalChangeStatusProgress(int current, int total);

  /// No description provided for @localChangeStatusSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Local change status sync complete'**
  String get localChangeStatusSyncComplete;

  /// No description provided for @syncingServerChanges.
  ///
  /// In en, this message translates to:
  /// **'Syncing server changes: {count}'**
  String syncingServerChanges(int count);

  /// No description provided for @syncingServerChangesProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing server changes ({current}/{total})'**
  String syncingServerChangesProgress(int current, int total);

  /// No description provided for @downloadingAttachments.
  ///
  /// In en, this message translates to:
  /// **'Downloading attachments: {count}'**
  String downloadingAttachments(int count);

  /// No description provided for @downloadingAttachmentsProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading attachments ({current}/{total})'**
  String downloadingAttachmentsProgress(int current, int total);

  /// No description provided for @attachmentDownloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Attachments download complete'**
  String get attachmentDownloadComplete;

  /// No description provided for @serverChangeSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Server changes sync complete'**
  String get serverChangeSyncComplete;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// No description provided for @checkingServerStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking server status'**
  String get checkingServerStatus;

  /// No description provided for @serverConnectionOk.
  ///
  /// In en, this message translates to:
  /// **'Server connection OK'**
  String get serverConnectionOk;

  /// No description provided for @serverConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Server connection timeout'**
  String get serverConnectionTimeout;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Copy success message
  ///
  /// In en, this message translates to:
  /// **'Copy successful'**
  String get copySuccess;

  /// Last sync time
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String lastSyncTime(String time);

  /// Not synced status
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get notSynced;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Register and Sync button text
  ///
  /// In en, this message translates to:
  /// **'Register and Sync'**
  String get registerAndSync;

  /// Registration failed message
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// Registration error message
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registerError;

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import Complete'**
  String get importComplete;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete [{name}]?'**
  String deleteConfirmMessage(Object name);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Title label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Content label
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Access token label
  ///
  /// In en, this message translates to:
  /// **'Access Token'**
  String get accessToken;

  /// Confirmation prompt when resetting authentication
  ///
  /// In en, this message translates to:
  /// **'This operation will clear local data and re-sync. Are you sure to continue?'**
  String get resetAuthConfirmation;

  /// Warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Warning message when deleting an account book
  ///
  /// In en, this message translates to:
  /// **'Warning: Deleting this account book will permanently delete all associated data, including account records, categories, tags, projects, merchants, and notes. This operation cannot be undone, please proceed with caution!'**
  String get deleteBookWarning;

  /// Permission settings title
  ///
  /// In en, this message translates to:
  /// **'Permission Settings'**
  String get permissionSettings;

  /// No description provided for @advanceMode.
  ///
  /// In en, this message translates to:
  /// **'Advance Mode'**
  String get advanceMode;

  /// No description provided for @timelineMode.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineMode;

  /// No description provided for @calendarMode.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarMode;

  /// Note type
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Todo type
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get todo;

  /// Debt type
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @lend.
  ///
  /// In en, this message translates to:
  /// **'Lend'**
  String get lend;

  /// No description provided for @borrow.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get borrow;

  /// No description provided for @debtor.
  ///
  /// In en, this message translates to:
  /// **'Debtor'**
  String get debtor;

  /// No description provided for @debtorHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the debtor\'s name'**
  String get debtorHint;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get amountHint;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @debtStatus.
  ///
  /// In en, this message translates to:
  /// **'Debt Status'**
  String get debtStatus;

  /// No description provided for @debtStatusUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get debtStatusUncleared;

  /// No description provided for @debtStatusCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get debtStatusCleared;

  /// No description provided for @debtStatusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get debtStatusVoided;

  /// No description provided for @expectedClearDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Clear Date'**
  String get expectedClearDate;

  /// No description provided for @actualClearDate.
  ///
  /// In en, this message translates to:
  /// **'Actual Clear Date'**
  String get actualClearDate;

  /// No description provided for @clearDebt.
  ///
  /// In en, this message translates to:
  /// **'Clear Debt'**
  String get clearDebt;

  /// No description provided for @voidDebt.
  ///
  /// In en, this message translates to:
  /// **'Void Debt'**
  String get voidDebt;

  /// Label for debt date
  ///
  /// In en, this message translates to:
  /// **'Debt Date'**
  String get debtDate;

  /// Collection button text
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// Repayment button text
  ///
  /// In en, this message translates to:
  /// **'Repayment'**
  String get repayment;

  /// Collection date label
  ///
  /// In en, this message translates to:
  /// **'Collection Date'**
  String get collectionDate;

  /// Repayment date label
  ///
  /// In en, this message translates to:
  /// **'Repayment Date'**
  String get repaymentDate;

  /// Remaining receivable amount label
  ///
  /// In en, this message translates to:
  /// **'Remaining Receivable'**
  String get remainingReceivable;

  /// Remaining payable amount label
  ///
  /// In en, this message translates to:
  /// **'Remaining Payable'**
  String get remainingPayable;

  /// Title for income and expense trend chart
  ///
  /// In en, this message translates to:
  /// **'Income & Expense Trend'**
  String get incomeTrend;

  /// Title for category distribution chart
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// Title for monthly comparison chart
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get monthlyComparison;

  /// Default fund account label
  ///
  /// In en, this message translates to:
  /// **'Default Fund Account'**
  String get defaultFund;

  /// Label for current month statistics
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// Label for last day statistics
  ///
  /// In en, this message translates to:
  /// **'Last Day'**
  String get lastDay;

  /// Statistics label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Show more button text
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// Show less button text
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// Refund operation label
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refund;

  /// Original record label
  ///
  /// In en, this message translates to:
  /// **'Original Record'**
  String get originalRecord;

  /// Gallery option text
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// File option text
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// Tooltip text for the save to gallery button
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// Tooltip text for the open with external app button
  ///
  /// In en, this message translates to:
  /// **'Open with External App'**
  String get openWithExternalApp;

  /// Text shown when save is successful
  ///
  /// In en, this message translates to:
  /// **'Save successful'**
  String get saveSuccess;

  /// No description provided for @selectTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Select Time Range'**
  String get selectTimeRange;

  /// No description provided for @timeRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get timeRangeAll;

  /// No description provided for @timeRangeYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get timeRangeYear;

  /// No description provided for @timeRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get timeRangeMonth;

  /// No description provided for @timeRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get timeRangeWeek;

  /// No description provided for @timeRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get timeRangeCustom;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
