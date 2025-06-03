import 'package:flutter/Material.dart';

class colortheme{

 static  final themecolor = Colors.blue;

 static final gradient =LinearGradient(
  colors: [
   colortheme.themecolor.shade400,
   colortheme.themecolor.shade700,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
 );


}