import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/profile_controller.dart';
import 'package:splitrip/controller/theme_controller.dart';
import 'package:splitrip/widgets/my_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Provider.of<ThemeController>(
      context,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        return Scaffold(
          body:
              isLandscape
                  ? SingleChildScrollView(
                    child: _buildLandscape(
                      context,
                      profileController,
                      themeController,
                    ),
                  )
                  : _buildPortrait(context, profileController, themeController),
        );
      },
    );
  }

  Widget _buildPortrait(
    BuildContext context,
    ProfileController profileController,
    ThemeController themeController,
  ) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 60,
                                  color: theme.colorScheme.primary,
                                  semanticLabel: 'User profile icon',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  Text(
                                    "Sign In to Splitrip",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  Text(
                                    "Sign In to Splitrip",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary
                                                .withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Connect with Google or Facebook",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        color: theme.cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: CustomAnimatedButton(
                          key: const ValueKey('google_button'),
                          buttonId: 'google',
                          onTap: () async {
                           await profileController.signInWithGoogle();
                          },
                          icon: Brand(Brands.google, size: 20),
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onSurface,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          useGradient: true,
                          gradientColors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                          borderColor: Colors.transparent,
                          semanticsLabel: 'Sign in with Google',
                          showLoadingIndicator:
                              true, // Show loading indicator for Google button
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: theme.cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: CustomAnimatedButton(
                          key: const ValueKey('facebook_button'),
                          buttonId: 'facebook',
                          onTap: () async {
                            await profileController.signInWithFacebook();
                          },
                          icon: Icon(
                            Icons.facebook,
                            size: 20,
                            color: theme.colorScheme.primary,
                            semanticLabel: 'Facebook icon',
                          ),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Color(0xFF1877F2),
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          useGradient: true,
                          gradientColors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                          borderColor: Colors.transparent,
                          semanticsLabel: 'Sign in with Facebook',
                          showLoadingIndicator:
                              false, // Hide loading indicator for Facebook button
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: theme.scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  "Preferences",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              SwitchListTile.adaptive(
                                value: themeController.isDarkMode,
                                title: Text(
                                  "Dark Mode",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                onChanged: (value) {
                                  themeController.setThemeMode(value);
                                },
                                activeColor: theme.colorScheme.primary,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLandscape(
      BuildContext context,
      ProfileController profileController,
      ThemeController themeController,
      ) {
    final borderColor =
    themeController.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 60,
                                  color: theme.colorScheme.primary,
                                  semanticLabel: 'User profile icon',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                children: [
                                  Text(
                                    "Sign In to Splitrip",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  Text(
                                    "Sign In to Splitrip",
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary
                                                .withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Connect with Google or Facebook",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 0,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                            child: CustomAnimatedButton(
                              key: const ValueKey('google_button'),
                              buttonId: 'google',
                              onTap: () async {
                                try {
                                  await profileController.signInWithGoogle();
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Google sign-in failed: $e',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              icon: Brand(Brands.google, size: 18),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4285F4),
                              borderRadius: 12,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              minimumSize: const Size(double.infinity, 44),
                              useGradient: true,
                              borderColor: borderColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 0,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                            child: CustomAnimatedButton(
                              key: const ValueKey('facebook_button'),
                              buttonId: 'facebook',
                              onTap: () async {
                                try {
                                  await profileController.signInWithFacebook();
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Facebook sign-in failed: $e',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.facebook,
                                size: 18,
                                color: Color(0xFF1877F2),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1877F2),
                              borderRadius: 12,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              minimumSize: const Size(double.infinity, 44),
                              useGradient: true,
                              borderColor: borderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            "Preferences",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ) ??
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        SwitchListTile.adaptive(
                          value: themeController.isDarkMode,
                          title: Text(
                            "Dark Mode",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ) ??
                                const TextStyle(fontSize: 14),
                          ),
                          onChanged: (value) {
                            themeController.setThemeMode(value);
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Add padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );


  }
}
