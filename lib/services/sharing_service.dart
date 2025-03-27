import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../models/fly_identification.dart';

class SharingService {
  // Share identification result
  Future<void> shareIdentificationResult(IdentificationResult result) async {
    try {
      String text = 'I identified a ${result.species.name} (${result.species.scientificName}) '
          'with ${(result.confidenceScore * 100).toStringAsFixed(1)}% confidence using FlySpotter!';

      await Share.share(text, subject: 'My Fly Identification');
    } catch (e) {
      throw 'Failed to share: $e';
    }
  }

  // Share identification result with image
  Future<void> shareIdentificationWithImage(IdentificationResult result) async {
    try {
      // Download the image
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/fly_identification.jpg';

      // Create a file with the image URL
      final response = await HttpClient().getUrl(Uri.parse(result.imageUrl));
      final HttpClientResponse responseData = await response.close();
      final List<int> imageData = await responseData.expand((data) => data).toList();
      final File file = File(imagePath);
      await file.writeAsBytes(imageData);

      // Share text and image
      String text = 'I identified a ${result.species.name} (${result.species.scientificName}) '
          'with ${(result.confidenceScore * 100).toStringAsFixed(1)}% confidence using FlySpotter!';

      await Share.shareXFiles([file as XFile], text: text, subject: 'My Fly Identification');
    } catch (e) {
      throw 'Failed to share with image: $e';
    }
  }

  // Share app
  Future<void> shareApp() async {
    try {
      String text = 'Check out FlySpotter, an amazing app for identifying flies using AI! '
          'Download it now: https://flyspotter.app';

      await Share.share(text, subject: 'FlySpotter App');
    } catch (e) {
      throw 'Failed to share app: $e';
    }
  }

  // Share widget as image
  Future<void> shareWidgetAsImage(GlobalKey key, String text) async {
    try {
      // Capture widget as image
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save image to temporary file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/flyspotter_share.png';
      final File file = File(imagePath);
      await file.writeAsBytes(pngBytes);

      // Share image with text
      await Share.shareXFiles([file as XFile], text: text, subject: 'My Fly Identification');
    } catch (e) {
      throw 'Failed to share widget as image: $e';
    }
  }
}

