class Kconstant {
  static const String ThemeModeKey = 'theme_mode';
  static const String UserNameKey = 'user_name';
  static const String UserEmail = 'user_email';
  static const String photoURL ='Image';
}

class PageConstant{
  static const String MaintainTripPage = "/MaintainTripScreen";
  static const String ProfilePage = "/ProfilePage";
  static const String TripScreen = "/TripScreen";
  static const String AddTransactionScreen = "/AddTransactionScreen";
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
    'Other'
  ];
  static const List<String> splitTypes = ['Equally', 'Custom', 'Percentage'];
}