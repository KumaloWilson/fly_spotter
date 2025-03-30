// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data'; // Added import for Uint8List
// import 'package:image/image.dart' as img;
//
// class ImageAnalyzer {
//   /// Analyzes an image to determine if it was taken in low light conditions
//   /// Returns a double between 0.0 (very dark) and 1.0 (very bright)
//   static Future<double> getLightLevel(File imageFile) async {
//     try {
//       // Read the image file
//       final bytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(bytes); // No need to convert to List<int>
//
//       if (image == null) {
//         return 0.5; // Default value if image can't be decoded
//       }
//
//       // Calculate average brightness
//       int totalPixels = image.width * image.height;
//       int totalBrightness = 0;
//
//       // Sample pixels (for performance, we don't need to check every pixel)
//       int sampleSize = max(1, totalPixels ~/ 10000); // Sample at most 10,000 pixels
//       int sampledPixels = 0;
//
//       for (int y = 0; y < image.height; y += sampleSize) {
//         for (int x = 0; x < image.width; x += sampleSize) {
//           final pixel = image.getPixel(x, y);
//           // Calculate brightness using the luminance formula
//           final brightness = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255;
//           totalBrightness += (brightness * 100).round();
//           sampledPixels++;
//         }
//       }
//
//       // Calculate average brightness (0.0 to 1.0)
//       final averageBrightness = sampledPixels > 0
//           ? totalBrightness / (sampledPixels * 100)
//           : 0.5;
//
//       return averageBrightness;
//     } catch (e) {
//       // If there's an error, return a middle value
//       return 0.5;
//     }
//   }
//
//   /// Determines if an image was taken in low light conditions
//   /// Returns true if the image is considered to be in low light
//   static Future<bool> isLowLightImage(File imageFile) async {
//     final lightLevel = await getLightLevel(imageFile);
//     // Consider images with brightness below 0.4 as low light
//     return lightLevel < 0.4;
//   }
// }