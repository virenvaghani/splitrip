import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/user_controller.dart';
import 'package:splitrip/controller/theme_controller.dart';

class ProfileDetailsPage extends StatelessWidget {
  final User user;

  const ProfileDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final ThemeController themeController = Provider.of<ThemeController>(
      context,
    );
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          return isLandscape
              ? _buildLandscape(context, userController, themeController)
              : _buildPortrait(context, userController, themeController);
        },
      ),
    );
  }

  Widget _buildPortrait(
    BuildContext context,
    UserController userController,
    ThemeController themeController,
  ) {
    final theme = Theme.of(context);
    final borderColor =
        themeController.isDarkMode
            ? theme.colorScheme.onSurface.withOpacity(0.2)
            : theme.colorScheme.primary.withOpacity(0.2);

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide.none,
                      ),
                      color: theme.colorScheme.surface,
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
                          borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Obx(
                              () => CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    userController.photoUrl.isNotEmpty
                                        ? NetworkImage(userController.photoUrl)
                                        : (user.photoURL != null
                                            ? NetworkImage(user.photoURL!)
                                            : null),
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child:
                                    userController.photoUrl.isEmpty &&
                                            user.photoURL == null
                                        ? Text(
                                          userController.userName.isNotEmpty
                                              ? userController.userName[0]
                                                  .toUpperCase()
                                              : (user.displayName?.isNotEmpty ==
                                                      true
                                                  ? user.displayName![0]
                                                      .toUpperCase()
                                                  : '?'),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        )
                                        : null,
                                onBackgroundImageError: (error, stackTrace) {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      userController.userName.isNotEmpty
                                          ? userController.userName
                                          : (user.displayName ??
                                              'No name available'),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(
                                    () => Text(
                                      userController.userEmail.isNotEmpty
                                          ? userController.userEmail
                                          : (user.email ??
                                              'No email available'),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preferences',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor),
                      ),
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onInverseSurface,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Divider(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.1,
                                ),
                              ),
                            ),
                            SwitchListTile.adaptive(
                              value: themeController.isDarkMode,
                              title: Text(
                                'Dark Mode',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              onChanged: (value) {
                                themeController.setThemeMode(value);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Dark mode ${value ? 'enabled' : 'disabled'}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onInverseSurface,
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(
    BuildContext context,
    UserController userController,
    ThemeController themeController,
  ) {
    final theme = Theme.of(context);
    final borderColor =
        themeController.isDarkMode
            ? theme.colorScheme.onSurface.withOpacity(0.2)
            : theme.colorScheme.primary.withOpacity(0.2);

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor),
                        ),
                        color: theme.colorScheme.surface,
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
                            borderRadius: BorderRadius.circular(12),
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
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Obx(
                                () => CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      userController.photoUrl.isNotEmpty
                                          ? NetworkImage(
                                            userController.photoUrl,
                                          )
                                          : (user.photoURL != null
                                              ? NetworkImage(user.photoURL!)
                                              : null),
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child:
                                      userController.photoUrl.isEmpty &&
                                              user.photoURL == null
                                          ? Text(
                                            userController.userName.isNotEmpty
                                                ? userController.userName[0]
                                                    .toUpperCase()
                                                : (user
                                                            .displayName
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? user.displayName![0]
                                                        .toUpperCase()
                                                    : '?'),
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          )
                                          : null,
                                  onBackgroundImageError:
                                      (error, stackTrace) {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Obx(
                                  () => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userController.userName.isNotEmpty
                                            ? userController.userName
                                            : (user.displayName ??
                                                'No name available'),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontSize: 18,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userController.userEmail.isNotEmpty
                                            ? userController.userEmail
                                            : (user.email ??
                                                'No email available'),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor),
                        ),
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.95),
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
                                  'Preferences',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onInverseSurface,
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Divider(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.1),
                                ),
                              ),
                              SwitchListTile.adaptive(
                                value: themeController.isDarkMode,
                                title: Text(
                                  'Dark Mode',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                onChanged: (value) {
                                  themeController.setThemeMode(value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Dark mode ${value ? 'enabled' : 'disabled'}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onInverseSurface,
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
