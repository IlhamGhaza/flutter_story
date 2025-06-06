import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

 static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  
  
  
  
  String get appTitle;

  
  
  
  
  String get login;

  
  
  
  
  String get register;

  
  
  
  
  String get email;

  
  
  
  
  String get password;

  
  
  
  
  String get name;

  
  
  
  
  String get loginButton;

  
  
  
  
  String get registerButton;

  
  
  
  
  String get logout;

  
  
  
  
  String get stories;

  
  
  
  
  String get addStory;

  
  
  
  
  String get description;

  
  
  
  
  String get selectImage;

  
  
  
  
  String get uploadStory;

  
  
  
  
  String get loading;

  
  
  
  
  String get error;

  
  
  
  
  String get success;

  
  
  
  
  String get noStoriesFound;

  
  
  
  
  String get loginRequired;

  
  
  
  
  String get invalidCredentials;

  
  
  
  
  String get registrationSuccess;

  
  
  
  
  String get storyUploadSuccess;

  
  
  
  
  String get networkError;

  
  
  
  
  String get tryAgain;

  
  
  
  
  String get cancel;

  
  
  
  
  String get ok;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
