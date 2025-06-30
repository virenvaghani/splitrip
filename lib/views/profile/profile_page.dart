import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/profile_controller.dart';
import 'package:splitrip/views/profile/profie_detail_page.dart';
import 'package:splitrip/views/profile/sign_up_page.dart';
import 'package:splitrip/widgets/myappbar.dart';

class ProfilePage extends StatelessWidget {
   ProfilePage({super.key});


  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar:_appar(context: context),
      body: _body(context:context)
    );
  }

  _appar({required BuildContext context}) {
    return  CustomAppBar(
      title: "Profile",
      CenterTitle: false,
      actions: [
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final isSignedIn = snapshot.data != null;
            return isSignedIn
                ? IconButton(
              onPressed: profileController.signOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 24,
              ),
              tooltip: 'Sign Out',
            )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  _body({required BuildContext context}) {
    return profileController.isloading.value
        ? Center(child: CircularProgressIndicator())
        : SafeArea(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          final isSignedIn = user != null;

          return isSignedIn
              ? ProfileDetailsPage(user: user)
              : const SignUpPage();
        },
      ),
    );
  }
}
