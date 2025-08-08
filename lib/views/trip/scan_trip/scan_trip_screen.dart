import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:splitrip/data/constants.dart';

import '../../../controller/participant/participent_selection_controller.dart';
import '../../../widgets/myappbar.dart';

// QR Scanner Page
class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(TripParticipantSelectorController()); // Temporary tripId, updated after scan
    final double scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;

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
          appBar: AppBar(
            title: Stack(
              children: [
                Text(
                  "Scan Qr",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                Text("Scan Qr", style: theme.textTheme.headlineSmall),
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
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: controller.scannerController,
                onDetect: (capture) => _handleQRScan(capture, context, theme, controller),
              ),
              QRScannerOverlay(scanArea: scanArea),
              Obx(() {
                if (controller.scannedData.value != null) {
                  return Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black54,
                      child: Text(
                        'Scanned: ${controller.scannedData.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(child: _buildInstructions(theme),height: 80,)
                ),

            ],
          ),
          floatingActionButton: kIsWeb
              ? null
              : Obx(() => FloatingActionButton(
            onPressed: controller.toggleTorch,
            child: Icon(
              controller.isTorchOn.value ? Icons.flashlight_off : Icons.flashlight_on,
            ),
          )),
        ),
      ),
    );
  }

  void _handleQRScan(
      BarcodeCapture capture,
      BuildContext context,
      ThemeData theme,
      TripParticipantSelectorController controller,
      ) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      final scannedValue = barcode.rawValue;
      if (scannedValue != null) {
        controller.scannedData.value = scannedValue;
        debugPrint('QR Code found: $scannedValue');

        // Only tripId is expected now
        final tripId = int.tryParse(scannedValue);

        if (tripId != null) {
          // Stop scanner to avoid multiple triggers
          controller.scannerController.stop();

          // Ensure no old state lingers
          Get.delete<TripParticipantSelectorController>();

          // Navigate with only tripId
          Get.offAndToNamed(
            PageConstant.selectionPage,
            arguments: {'tripId': tripId},
          );
        } else {
          Get.snackbar('Error', 'Invalid trip ID in QR code');
        }

        break; // Process only the first valid scan
      }
    }
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
            'Scan QR Code',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan the QR code to join the trip.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

}

// QR Scanner Overlay Widget
class QRScannerOverlay extends StatelessWidget {
  final double scanArea;

  const QRScannerOverlay({
    super.key,
    required this.scanArea,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
            BlendMode.darken,
          ),
          child: Container(color: Colors.transparent),
        ),
        Center(
          child: Container(
            width: scanArea,
            height: scanArea,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}