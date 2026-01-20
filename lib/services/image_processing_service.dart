import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/document_model.dart';

class ImageProcessingService {
  static ImageProcessingService? _instance;
  static ImageProcessingService get instance => _instance ??= ImageProcessingService._();
  ImageProcessingService._();

  // Detect document edges (simplified version - you can enhance this)
  Future<List<Offset>> detectDocumentEdges(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return [];

      // Return default corners (full image)
      return [
        const Offset(0, 0),
        Offset(image.width.toDouble(), 0),
        Offset(image.width.toDouble(), image.height.toDouble()),
        Offset(0, image.height.toDouble()),
      ];
    } catch (e) {
      debugPrint('Edge detection failed: $e');
      return [];
    }
  }

  // Correct perspective based on detected edges
  Future<File?> correctPerspective(
    File imageFile,
    List<Offset> edges,
    String outputPath,
  ) async {
    try {
      // For now, just copy the original image
      // You can implement actual perspective correction using opencv or custom algorithm
      await imageFile.copy(outputPath);
      return File(outputPath);
    } catch (e) {
      debugPrint('Perspective correction failed: $e');
      return null;
    }
  }

  // Apply filters to image
  Future<File?> applyFilter(
    File imageFile,
    FilterType filter,
    String outputPath,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      img.Image processedImage;
      
      switch (filter) {
        case FilterType.grayscale:
          processedImage = img.grayscale(image);
          break;
          
        case FilterType.blackWhite:
          processedImage = _applyBlackWhite(image);
          break;
          
        case FilterType.enhanced:
          processedImage = _enhanceImage(image);
          break;
          
        case FilterType.none:
        default:
          processedImage = image;
      }

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(processedImage, quality: 90));
      
      return outputFile;
    } catch (e) {
      debugPrint('Filter application failed: $e');
      return null;
    }
  }

  img.Image _applyBlackWhite(img.Image image) {
    final grayscale = img.grayscale(image);
    
    // Apply threshold for black and white effect
    for (int y = 0; y < grayscale.height; y++) {
      for (int x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        
        // Threshold at 128
        final newColor = luminance > 128 ? 255 : 0;
        grayscale.setPixel(x, y, img.ColorRgb8(newColor, newColor, newColor));
      }
    }
    
    return grayscale;
  }

  img.Image _enhanceImage(img.Image image) {
    // Adjust contrast and brightness
    var enhanced = img.adjustColor(
      image,
      contrast: 1.2,
      brightness: 1.1,
      saturation: 1.1,
    );
    
    // Sharpen the image
    enhanced = img.convolution(
      enhanced,
      filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ],
      div: 1,
    );
    
    return enhanced;
  }

  // Crop image
  Future<File?> cropImage(
    File imageFile,
    Rect cropRect,
    String outputPath,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      final cropped = img.copyCrop(
        image,
        x: cropRect.left.toInt(),
        y: cropRect.top.toInt(),
        width: cropRect.width.toInt(),
        height: cropRect.height.toInt(),
      );

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));
      
      return outputFile;
    } catch (e) {
      debugPrint('Crop failed: $e');
      return null;
    }
  }

  // Rotate image
  Future<File?> rotateImage(
    File imageFile,
    int degrees,
    String outputPath,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      img.Image rotated;
      switch (degrees) {
        case 90:
          rotated = img.copyRotate(image, angle: 90);
          break;
        case 180:
          rotated = img.copyRotate(image, angle: 180);
          break;
        case 270:
          rotated = img.copyRotate(image, angle: 270);
          break;
        default:
          rotated = image;
      }

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(rotated, quality: 90));
      
      return outputFile;
    } catch (e) {
      debugPrint('Rotation failed: $e');
      return null;
    }
  }
}