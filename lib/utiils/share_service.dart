import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../models/fly_identification.dart';

class ShareService {
  // Share identification result
  static Future<void> shareIdentificationResult(IdentificationResult result) async {
    try {
      // Download the image
      final http.Response response = await http.get(Uri.parse(result.imageUrl));

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File imageFile = File('$tempPath/identification_image.jpg');
      await imageFile.writeAsBytes(response.bodyBytes);

      // Create share text
      final String shareText =
          "I identified a ${result.species.name} (${result.species.scientificName}) using FlySpotter!\n\n" +
              "Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%\n\n" +
              "Description: ${result.species.description}\n\n" +
              "Download FlySpotter to identify flies in your area!";

      // Share
      await Share.shareXFiles(
        [imageFile as XFile],
        text: shareText,
        subject: "Fly Identification with FlySpotter",
      );
    } catch (e) {
      print("Error sharing: $e");
    }
  }

  // Share app
  static Future<void> shareApp() async {
    try {
      await Share.share(
        "Check out FlySpotter, an amazing app to identify fly species using AI technology! Download it now!",
        subject: "FlySpotter - Fly Identification App",
      );
    } catch (e) {
      print("Error sharing app: $e");
    }
  }
}

