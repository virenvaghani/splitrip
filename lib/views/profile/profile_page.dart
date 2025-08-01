import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/profile/profile_controller.dart';
import 'package:splitrip/views/profile/profie_detail_page.dart';
import 'package:splitrip/views/profile/sign_up_page.dart';
import 'package:splitrip/widgets/myappbar.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});


  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return GetX<ProfileController>(
      initState: (state) {
        profileController.loadToken();
      },
      builder: (_) {
        return Scaffold(
            backgroundColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            appBar: profileController.isloading.value ? null : _appbar(context: context),
            body:profileController.isloading.value? Center(child: CircularProgressIndicator()):  _body(context: context)
        );
      }
    );
  }

  CustomAppBar _appbar({required BuildContext context}) {
    return CustomAppBar(
      title: "Profile",
      centerTitle: false,
      actions: [
       profileController.authToken.value != null? IconButton(
         onPressed: profileController.signOut,
         icon: const Icon(
           Icons.logout,
           color: Colors.redAccent,
           size: 24,
         ),
         tooltip: 'Sign Out',
       )
           :  SizedBox.shrink()
      ],
    );
  }

  SafeArea _body({required BuildContext context}) {
    return SafeArea(
      child: profileController.authToken.value != null ? ProfileDetailsPage()
          :  SignUpPage()
    );
  }
}
