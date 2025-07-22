import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/profile/profile_controller.dart';
import 'package:splitrip/controller/theme/theme_controller.dart';
import 'package:splitrip/widgets/myappbar.dart';
import 'package:splitrip/widgets/my_button.dart';

import '../../controller/participant/participent_selection_controller.dart';
import '../../model/friend/friend_model.dart';

class TripParticipantSelectorPage extends StatelessWidget {
  const TripParticipantSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tripId = _parseTripId();
    if (tripId == null) return _buildErrorUI(theme);

    final tag = 'TripParticipantSelectorController-$tripId';
    final controller = Get.put(TripParticipantSelectorController(tripId), tag: tag);

    return Obx(
          () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: true,
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: CustomAppBar(title: controller.authToken.value != null ? 'Select Your Identity' : '', centerTitle: true,),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Obx(() => _buildBody(context, theme, controller, tag)),
            ),
          ),
        ),
      ),
    );
  }

  int? _parseTripId() {
    final tripIdStr = Get.parameters['tripId'] ?? Get.parameters['id'];
    return int.tryParse(tripIdStr ?? '');
  }

  Widget _buildBody(
      BuildContext context,
      ThemeData theme,
      TripParticipantSelectorController controller,
      String tag,
      ) {
    if (controller.authToken.value != null) {
      return _buildLoginUI(context, theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructions(theme),
        const SizedBox(height: 24),
        Expanded(
          child: GetBuilder<TripParticipantSelectorController>(
            tag: tag,
            builder: (controller) {
              controller.loadParticipants();
              return Obx(() => _buildParticipantList(controller, theme));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantList(TripParticipantSelectorController controller, ThemeData theme) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.participants.isEmpty) {
      return _buildEmpty(theme);
    }
    return ListView.separated(
      itemCount: controller.participants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildParticipantCard(
        context,
        controller.participants[index],
        theme,
        controller,
      ),
    );
  }

  Widget _buildErrorUI(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Text(
          'Invalid or missing trip ID',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No participants found',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you?',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap your name below to join this trip as that participant.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(
      BuildContext context,
      FriendModel friend,
      ThemeData theme,
      TripParticipantSelectorController controller,
      ) {
    final participant = friend.participant;
    if (participant == null) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleParticipantSelection(context, theme, controller, participant.referenceId),
      child: Semantics(
        label: 'Select participant ${participant.name ?? 'Unnamed'}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.highlightColor,
                child: const Icon(Icons.person, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  participant.name ?? 'Unnamed',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleParticipantSelection(
      BuildContext context,
      ThemeData theme,
      TripParticipantSelectorController controller,
      String? referenceId,
      ) async {
    if (referenceId == null) {
      Get.snackbar('Error', 'Participant reference ID is missing');
      return;
    }
    await controller.linkuserWithParticipant(
      context: context,
      theme: theme,
      referenceId: referenceId,
    );
  }

  Widget _buildLoginUI(BuildContext context, ThemeData theme) {
    final profileController = Get.find<ProfileController>();
    final themeController = Provider.of<ThemeController>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildHeader(theme)),
                SizedBox(height: isWide ? 0 : 24, width: isWide ? 40 : 0),
                Expanded(child: _buildFormSection(context, theme, profileController, themeController)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_circle, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Welcome to Splitrip',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Join or log in to manage your trips',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
        _buildButton(
          context,
          label: 'Continue with Google',
          icon: Brand(Brands.google, size: 18),
          onTap: () => profileController.signInWithGoogle(context),
        ),
        const SizedBox(height: 16),
        _buildButton(
          context,
          label: 'Continue with Facebook',
          icon: const Icon(Icons.facebook, size: 18, color: Color(0xFF1877F2)),
          onTap: () => profileController.signInWithFacebook(context),
          foregroundColor: const Color(0xFF1877F2),
        ),
        const SizedBox(height: 32),
        Divider(color: theme.dividerColor.withValues(alpha: 0.3), thickness: 0.5),
        const SizedBox(height: 16),
        _buildThemeToggle(themeController, theme),
      ],
    );
  }

  Widget _buildButton(
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
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      minimumSize: const Size(double.infinity, 48),
      useGradient: false,
      showLoadingIndicator: false,
    );
  }

  Widget _buildThemeToggle(ThemeController controller, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Dark Mode', style: theme.textTheme.bodyMedium),
        Switch.adaptive(
          value: controller.isDarkMode,
          onChanged: controller.setThemeMode,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}