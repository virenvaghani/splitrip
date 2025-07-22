class Kconstant {
  static const String themeModeKey = 'theme_mode';
  static const String userNameKey = 'user_name';
  static const String userEmail = 'user_email';
  static const String photoURL = 'Image';
}

class PageConstant {
  static const String maintainTripPage = "/MaintainTripScreen";
  static const String profilePage = "/ProfilePage";
  static const String tripScreen = "/TripScreen";
  static const String addTransactionScreen = "/AddTransactionScreen";
  static const String archiveScreen = "/ArchiveScreen";
  static const String tripDetailScreen = "/TripDetailscreen";
  static const String selectionPage = "/trip";
  static const String dashboard = "/Dashboard";
  static const String splashScreen = "/SplashScreen";
}

class ApiConstants {
  static const String baseUrl = 'https://expense.jayamsoft.net';
  static const String tripMaintainEndpoint = '/trip/maintain/';
  static const String participantCreateEndpoint = '/participants/create/';
}

class TransactionConstants {
  static const List<String> categories = [
    'Food',
    'Transport',
    'Accommodation',
    'Entertainment',
    'Other',
  ];
  static const List<String> splitTypes = ['Equally', 'Custom', 'Percentage'];
}
