import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late final String _appDocumentsPath;
  late final String _documentsPath;
  late final String _pdfPath;
  late final SharedPreferences _prefs;

  String get appDocumentsPath => _appDocumentsPath;
  String get documentsPath => _documentsPath;
  String get pdfPath => _pdfPath;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _appDocumentsPath = appDir.path;
      
      _documentsPath = '$_appDocumentsPath/documents';
      _pdfPath = '$_appDocumentsPath/pdfs';
      
      await Directory(_documentsPath).create(recursive: true);
      await Directory(_pdfPath).create(recursive: true);
      
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Storage initialization failed: $e');
    }
  }

  // Save document metadata
  Future<void> saveDocument(DocumentModel document) async {
    try {
      final documentsList = await getAllDocuments();
      final existingIndex = documentsList.indexWhere((d) => d.id == document.id);
      
      if (existingIndex != -1) {
        documentsList[existingIndex] = document;
      } else {
        documentsList.add(document);
      }
      
      final jsonList = documentsList.map((d) => d.toJsonString()).toList();
      await _prefs.setStringList('documents', jsonList);
    } catch (e) {
      debugPrint('Failed to save document: $e');
    }
  }

  // Get all documents
  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      final jsonList = _prefs.getStringList('documents') ?? [];
      return jsonList.map((json) => DocumentModel.fromJsonString(json)).toList();
    } catch (e) {
      debugPrint('Failed to load documents: $e');
      return [];
    }
  }

  // Get document by ID
  Future<DocumentModel?> getDocumentById(String id) async {
    try {
      final documents = await getAllDocuments();
      return documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      debugPrint('Failed to get document: $e');
      return null;
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      final document = await getDocumentById(documentId);
      if (document == null) return;
      
      // Delete image files
      for (final imagePath in document.imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Delete PDF file
      if (document.pdfPath != null) {
        final pdfFile = File(document.pdfPath!);
        if (await pdfFile.exists()) {
          await pdfFile.delete();
        }
      }
      
      // Remove from storage
      final documents = await getAllDocuments();
      documents.removeWhere((d) => d.id == documentId);
      final jsonList = documents.map((d) => d.toJsonString()).toList();
      await _prefs.setStringList('documents', jsonList);
    } catch (e) {
      debugPrint('Failed to delete document: $e');
    }
  }

  // Save image file
  Future<String> saveImage(File imageFile, String documentId, int pageIndex) async {
    try {
      final fileName = '${documentId}_page_$pageIndex.jpg';
      final filePath = '$_documentsPath/$fileName';
      await imageFile.copy(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Failed to save image: $e');
      rethrow;
    }
  }

  // User preferences
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }

  Future<void> setDefaultFilter(String filter) async {
    await _prefs.setString('default_filter', filter);
  }

  String getDefaultFilter() {
    return _prefs.getString('default_filter') ?? 'none';
  }

  Future<void> setAutoEnhance(bool value) async {
    await _prefs.setBool('auto_enhance', value);
  }

  bool getAutoEnhance() {
    return _prefs.getBool('auto_enhance') ?? true;
  }

  Future<void> setAutoSave(bool value) async {
    await _prefs.setBool('auto_save', value);
  }

  bool getAutoSave() {
    return _prefs.getBool('auto_save') ?? false;
  }
}