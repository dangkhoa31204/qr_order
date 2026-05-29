import 'dart:typed_data';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class QrCodeGenerator {
  static Future<Uint8List?> generateQrCode(String data) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.isValid) {
        final byteData = await QrPainter(
          data: data,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        ).toImageData(200);

        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }
    } catch (e) {
      print("Error generating QR code: $e");
    }
    return null;
  }

  static Future<bool> saveQrCode(String tableId, String tableLabel) async {
    try {
      // Generate QR code
      final qrImageData = await generateQrCode("table_$tableId");

      if (qrImageData == null) {
        print("Failed to generate QR code image");
        return false;
      }

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        print("Downloads directory not found");
        return false;
      }

      // Create filename with timestamp
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'QR_${tableLabel}_${timestamp}.png';
      final filePath = '${downloadsDir.path}/$filename';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(qrImageData);

      print("QR code saved to: $filePath");
      return true;
    } catch (e) {
      print("Error saving QR code: $e");
      return false;
    }
  }
}
