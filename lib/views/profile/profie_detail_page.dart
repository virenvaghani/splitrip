import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/user_controller.dart';
import 'package:splitrip/controller/theme_controller.dart';
import 'package:splitrip/data/trip_constant.dart';

class ProfileDetailsPage extends StatelessWidget {
  final User user;

  const ProfileDetailsPage({super.key, required this.user});

  void _showProfileImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);

    final photoUrl = userController.photoUrl.isNotEmpty
        ? userController.photoUrl
        : user.photoURL ?? '';

    final displayName = userController.userName.isNotEmpty
        ? userController.userName
        : user.displayName ?? 'No name available';

    final email = userController.userEmail.isNotEmpty
        ? userController.userEmail
        : user.email ?? 'No email available';

    final isDarkMode = themeController.isDarkMode;
    final borderColor = isDarkMode
        ? theme.colorScheme.onSurface.withOpacity(0.2)
        : theme.colorScheme.primary.withOpacity(0.2);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          return isLandscape
              ? _buildLandscapeView(context, theme, themeController, displayName, email, photoUrl, borderColor)
              : _buildPortraitView(context, theme, themeController, displayName, email, photoUrl, borderColor);
        },
      ),
    );
  }

  Widget _buildPortraitView(BuildContext context, ThemeData theme, ThemeController themeController,
      String displayName, String email, String photoUrl, Color borderColor) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (photoUrl.isNotEmpty) _showProfileImage(context, photoUrl);
              },
              child: CircleAvatar(
                radius: 48,
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: photoUrl.isEmpty
                    ? Text(
                  displayName[0].toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
            AppSpacers.medium,
            Text(
              displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            AppSpacers.tiny,
            Text(
              email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
           AppSpacers.BigSpacing,
            _preferenceCard(theme, themeController, borderColor, context),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeView(BuildContext context, ThemeData theme, ThemeController themeController,
      String displayName, String email, String photoUrl, Color borderColor) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (photoUrl.isNotEmpty) _showProfileImage(context, photoUrl);
                    },
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: photoUrl.isEmpty
                          ? Text(
                        displayName[0].toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _preferenceCard(theme, themeController, borderColor, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preferenceCard(ThemeData theme, ThemeController controller, Color borderColor, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.95),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: false,
            title: Text(
              'Notifications',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifications ${value ? 'enabled' : 'disabled'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            indent: 16,
            endIndent: 16,
          ),
          SwitchListTile.adaptive(
            value: controller.isDarkMode,
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onChanged: controller.setThemeMode,
            activeColor: theme.colorScheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
    );
  }
}