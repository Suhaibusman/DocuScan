import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static OCRService? _instance;
  static OCRService get instance => _instance ??= OCRService._();
  OCRService._();

  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      _textRecognizer = TextRecognizer();
      _isInitialized = true;
    } catch (e) {
      debugPrint('OCR initialization failed: $e');
    }
  }

  Future<String> extractTextFromImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Text extraction failed: $e');
      return '';
    }
  }

  void dispose() {
    if (_isInitialized) {
      _textRecognizer.close();
    }
  }
}
