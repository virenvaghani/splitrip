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
    final profileController = Get.find<ProfileController>();
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildHeader(theme),
                    ),
                    const SizedBox(height: 24, width: 40),
                    Expanded(
                      child: _buildFormSection(
                        context,
                        theme,
                        profileController,
                        themeController,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_circle, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          "Welcome to Splitrip",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Join or log in to manage your trips",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormSection(
      BuildContext context,
      ThemeData theme,
      ProfileController profileController,
      ThemeController themeController,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _minimalButton(
          context,
          label: "Continue with Google",
          icon: Brand(Brands.google, size: 18),
          onTap: () => profileController.signInWithGoogle(context),
        ),
        const SizedBox(height: 16),
        _minimalButton(
          context,
          label: "Continue with Facebook",
          icon: const Icon(Icons.facebook, size: 18, color: Color(0xFF1877F2)),
          onTap: () => profileController.signInWithFacebook(),
          foregroundColor: const Color(0xFF1877F2),
        ),
        const SizedBox(height: 32),
        Divider(color: theme.dividerColor.withOpacity(0.3), thickness: 0.5),
        const SizedBox(height: 16),
        _minimalPreferenceToggle(themeController, theme),
      ],
    );
  }

  Widget _minimalButton(
      BuildContext context, {
        required String label,
        required Widget icon,
        required VoidCallback onTap,
        Color? foregroundColor,
      }) {
    final theme = Theme.of(context);
    return CustomAnimatedButton(
      buttonId: label,
      onTap: onTap,
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: foregroundColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      borderColor: theme.colorScheme.outline.withOpacity(0.2),
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      minimumSize: const Size(double.infinity, 48),
      useGradient: false,
      showLoadingIndicator: false,
    );
  }

  Widget _minimalPreferenceToggle(ThemeController controller, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Dark Mode", style: theme.textTheme.bodyMedium),
        Switch.adaptive(
          value: controller.isDarkMode,
          onChanged: controller.setThemeMode,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
