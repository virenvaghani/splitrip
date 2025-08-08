import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../../widgets/myappbar.dart';

class GenerateQRPage extends StatelessWidget {
  final int tripId;

  const GenerateQRPage({
    super.key,
    required this.tripId,
  });

  Future<String> _generateQRImage() async {
    try {
      // Gradient colors matching your theme
      const Color startColor = Color(0xFF475e64);
      const Color endColor = Color(0xFF62bed9);
      const Color bgColor = Color(0xCCecf7f8); // Semi-transparent

      final qrPainter = QrPainter(
        data: tripId.toString(),
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
        color: Colors.black, // Temporary, replaced later with gradient
        emptyColor: Colors.transparent,
      );

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/qr_code_${tripId}_${DateTime.now().millisecondsSinceEpoch}.png';

      // Render QR image
      final picData = await qrPainter.toImageData(800);
      if (picData == null) throw Exception('Failed to generate QR image');

      final buffer = picData.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(buffer);
      final frame = await codec.getNextFrame();
      final qrImage = frame.image;

      // Canvas for advanced design
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final double size = 900;
      final center = Offset(size / 2, size / 2);

      // Draw background with glassmorphism effect
      final bgPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(size, size),
          [bgColor, Colors.white.withValues(alpha: 0.7)],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size, size), const Radius.circular(60)),
        bgPaint,
      );

      // Outer glow ring
      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 30);
      canvas.drawCircle(center, size / 2.2, ringPaint);

      // Gradient for QR
      final qrShader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(qrImage.width.toDouble(), qrImage.height.toDouble()),
        [startColor, endColor],
      );

      // Draw QR with rounded modules
      final qrPaint = Paint()..shader = qrShader;
      final qrRect = Rect.fromLTWH(
        (size - qrImage.width) / 2,
        (size - qrImage.height) / 2,
        qrImage.width.toDouble(),
        qrImage.height.toDouble(),
      );
      canvas.drawImage(qrImage, qrRect.topLeft, qrPaint);

      // Center logo
      final logoData = await rootBundle.load('lib/media/logos/fb.png');
      final logoCodec = await ui.instantiateImageCodec(
        logoData.buffer.asUint8List(),
        targetWidth: 140,
        targetHeight: 140,
      );
      final logoFrame = await logoCodec.getNextFrame();
      final logoImage = logoFrame.image;

      // White circular border for logo
      final logoBgPaint = Paint()..color = Colors.white;
      canvas.drawCircle(center, 85, logoBgPaint);
      canvas.drawImage(logoImage, Offset(center.dx - 70, center.dy - 70), Paint());

      // Save final image
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(size.toInt(), size.toInt());
      final byteData =
      await finalImage.toByteData(format: ui.ImageByteFormat.png);

      final file = File(filePath);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      return filePath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate QR image: $e');
      rethrow;
    }
  }






  void _shareQRImage() async {

    try {
      final filePath = await _generateQRImage();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Join trip $tripId with this QR code!',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing QR image: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Share Trip QR Code',
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan this QR code to join trip #$tripId',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: QrImageView(
                data: tripId.toString(),
                size: 250,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                errorCorrectionLevel: QrErrorCorrectLevel.L,
              ),
            ),
            const SizedBox(height: 24),
           TextButton(onPressed: _shareQRImage, child: Text("share Qr")),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}