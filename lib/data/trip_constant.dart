import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';



class AppStrings {
  static const String newTripTitle = 'New Trip';
  static const String createTrip = 'Create Trip';
  static const String updateTrip = "Update Trip";
  static const String selectEmojiLabel = 'Select trip emoji';
  static const String defaultEmoji = '😊';
  static const String titleLabel = 'Title';
  static const String enterTripName = 'Enter trip name';
  static const String currencyLabel = 'Currency';
  static const String selectCurrency = 'Select currency';
  static const String currencyValidation = 'Please select a currency';
  static const String addParticipant = 'Add Participant';
  static const String selectParticipants = 'Select Participants';
  static const String noFriendsSelected = 'No friends selected';
  static const String nameLabel = 'Name';
  static const String memberLabel = 'Member';
  static const String addLabel = 'Add';
  static const String addFriend = 'Add Friend';
  static const String clickHere = 'Click here';
  static const String  memberInvalid = "member is invalid";
  static const String  nameValidation = "Name is invalid";
  static const String  tripNameValidation = "Trip Name  is invalid";



}


class AppPaddings {
  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets tinyPadding = EdgeInsets.all(4);
  static const EdgeInsets smallBottom = EdgeInsets.only(bottom: 2);
  static const EdgeInsets tableCellPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 12);
}

class AppSpacers {
  static const SizedBox tiny = SizedBox(height: 4);
  static const SizedBox small = SizedBox(height: 8);
  static const SizedBox medium = SizedBox(height: 16);
  static const double smallSpacing = 8;
  static const SizedBox horizontalSmall = SizedBox(width: 10); // Changed to SizedBox
  static const SizedBox BigSpacing = SizedBox(height: 36);

}

class AppSizes {
  static const double avatarRadius = 25;
  static const double smallAvatarRadius = 8;
  static const double smallIcon = 10;
  static const double mediumIcon = 20;
  static const double handleWidth = 50;
  static const double handleHeight = 5;
  static const double splashRadius = 20;
}

class AppBorders {
  static const BorderRadius defaultRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(30));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(12.5));
  static const BorderRadius handleRadius = BorderRadius.all(Radius.circular(100));
  static const BorderRadius tableTopRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );
  static const BorderRadius tableBottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(15),
    bottomRight: Radius.circular(15),
  );
}

class AppShadows {
  static BoxShadow defaultShadow(ThemeData theme) => BoxShadow(
    color: theme.colorScheme.onSurface.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}

class AppStyles {
  static const TextStyle emojiStyle = TextStyle(fontSize: 24);
  static InputDecoration dropdownDecoration(ThemeData theme) => InputDecoration(
    border: OutlineInputBorder(
      borderSide: const BorderSide(width: 2),
      borderRadius: AppBorders.defaultRadius,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 15),
  );
  static TextStyle hintStyle(ThemeData theme) => theme.textTheme.bodyLarge!.copyWith(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
  );
  static const IconStyleData dropdownIconStyle = IconStyleData(
    icon: Padding(
      padding: EdgeInsets.only(right: 10),
      child: Icon(Icons.keyboard_arrow_down),
    ),
  );
  static ButtonStyle elevatedButtonStyle(ThemeData theme) => ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: AppBorders.defaultRadius),
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    elevation: 0,
  );
  static TextStyle chipLabelStyle(ThemeData theme, bool isSelected) => theme.textTheme.labelSmall!.copyWith(
    color: isSelected ? AppColors.darkBackground : theme.primaryColorDark,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  );
  static BoxDecoration kBoxDecoration = BoxDecoration(
  gradient: LinearGradient(
  colors: [
    AppColors.primary.withValues(alpha: 0.05),
    AppColors.secondary.withValues(alpha: 0.05),
  ],// Example gradient colors
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  ),
  borderRadius: const BorderRadius.all(Radius.circular(50)),
  );

}

class AppConstants {
  static const List<String> currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];
  static const Map<int, TableColumnWidth> tableColumnWidths = {
    0: FractionColumnWidth(0.50),
    1: FractionColumnWidth(0.20),
    2: FractionColumnWidth(0.15),
    3: FractionColumnWidth(0.15),
  };
}