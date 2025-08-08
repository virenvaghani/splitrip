import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/participant/participent_selection_controller.dart';
import '../../model/friend/friend_model.dart';
import '../../widgets/myappbar.dart';
import '../../widgets/my_button.dart';
import 'package:flutter/services.dart';

class ParticipantSelectorPage extends StatelessWidget {


  const ParticipantSelectorPage({super.key,});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arguments = Get.arguments;
    final tripId = arguments['tripId'];
    final tag = 'TripParticipantSelectorController-$tripId';
    final TripParticipantSelectorController  controller = Get.put(TripParticipantSelectorController(), tag: tag);

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
          appBar: CustomAppBar(
            title: 'Select Your Identity',
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructions(theme),
                const SizedBox(height: 24),
                CustomAnimatedButton(
                  buttonId: 'generate_qr',
                  onTap: () => controller.generateAndShowQR(context),
                  icon: const Icon(Icons.qr_code),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GetBuilder<TripParticipantSelectorController>(
                    tag: tag,
                    builder: (controller) {
                      return Obx(() => _buildParticipantList(controller, theme));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildParticipantList(
      TripParticipantSelectorController controller, ThemeData theme) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.participants.isEmpty) {
      return _buildEmpty(theme);
    }
    return ListView.separated(
      itemCount: controller.participants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final friend = controller.participants[index];
        return _buildParticipantCard(context, friend, theme, controller);
      },
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

  Widget _buildParticipantCard(
      BuildContext context,
      FriendModel friend,
      ThemeData theme,
      TripParticipantSelectorController controller,
      ) {
    final participant = friend.participant;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (participant.referenceId == null) {
          Get.snackbar('Error', 'Participant reference ID is missing');
          return;
        }
        _handleParticipantSelection(
          context,
          theme,
          controller,
          participant.referenceId!,
        );
      },
      child: Semantics(
        label: 'Select participant ${participant?.name ?? 'Unnamed'}',
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
                  participant?.name ?? 'Unnamed',
                  style: theme.textTheme.bodyMedium?.copyWith(
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
      String referenceId,
      ) async {
    await controller.linkuserWithParticipant(
      context: context,
      theme: theme,
      referenceId: referenceId,
    );
  }
}
