import 'package:get/get.dart';
import 'package:splitrip/model/Category/category_model.dart';
import 'package:splitrip/model/friend/friend_model.dart';

import '../model/currency/currency_model.dart';

class Kconstant {
  static const String themeModeKey = 'theme_mode';
  static const String userNameKey = 'user_name';
  static const String userEmail = 'user_email';
  static const String photoURL = 'Image';
  static  List<CurrencyModel> currencyModelList = [];
  static RxList<FriendModel> friendModelList = RxList();
  static RxList<Map<String, dynamic>> participantsRx = RxList();
  static RxList<CategoryModel> categoryModelList = RxList();
  static void setParticipantsRx(List<Map<String, dynamic>> participantsList) {
    participantsRx.value = List<Map<String, dynamic>>.from(participantsList);
  }
  static RxList<Map<String, dynamic>> transactionsRx = <Map<String, dynamic>>[].obs;

  static void setTransactions(List<Map<String, dynamic>> transactions) {
    transactionsRx.value = transactions;
  }
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
