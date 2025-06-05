// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Story';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get stories => 'Stories';

  @override
  String get addStory => 'Add Story';

  @override
  String get description => 'Description';

  @override
  String get selectImage => 'Select Image';

  @override
  String get uploadStory => 'Upload Story';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noStoriesFound => 'No stories found';

  @override
  String get loginRequired => 'Please login to continue';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get storyUploadSuccess => 'Story uploaded successfully';

  @override
  String get networkError => 'Network error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';
}
