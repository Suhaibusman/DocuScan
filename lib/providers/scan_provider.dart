import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import '../services/storage_service.dart';
import '../services/camera_service.dart';
import '../services/image_processing_service.dart';

class ScanProvider extends ChangeNotifier {
  final _storageService = StorageService.instance;
  final _cameraService = CameraService.instance;
  final _imageProcessor = ImageProcessingService.instance;

  // Private state variables
  List<DocumentModel> _documents = [];
  bool _isScanning = false;
  bool _isProcessing = false;
  FilterType _currentFilter = FilterType.none;
  List<String> _currentScanImages = [];
  String _currentDocumentName = '';
  String _searchQuery = '';

  // Getters
  List<DocumentModel> get documents => _documents;
  bool get isScanning => _isScanning;
  bool get isProcessing => _isProcessing;
  FilterType get currentFilter => _currentFilter;
  List<String> get currentScanImages => _currentScanImages;
  String get currentDocumentName => _currentDocumentName;
  String get searchQuery => _searchQuery;

  // Filtered documents based on search
  List<DocumentModel> get filteredDocuments {
    if (_searchQuery.isEmpty) return _documents;

    return _documents
        .where((doc) =>
            doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (doc.extractedText
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            doc.tags.any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  // Statistics getters
  int get totalDocuments => _documents.length;
  int get thisMonthDocuments => _documents
      .where((doc) =>
          doc.createdAt.month == DateTime.now().month &&
          doc.createdAt.year == DateTime.now().year)
      .length;
  int get documentsWithText => _documents.where((doc) => doc.hasText).length;

  // Initialize provider
  Future<void> initialize() async {
    await loadDocuments();
  }

  // Load all documents
  Future<void> loadDocuments() async {
    try {
      _documents = await _storageService.getAllDocuments();
      _documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load documents: $e');
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Start new scan session
  void startNewScan() {
    _currentScanImages = [];
    _currentDocumentName = 'Document ${DateTime.now().millisecondsSinceEpoch}';
    _isScanning = true;
    _currentFilter = FilterType.none;
    notifyListeners();
  }

  // Capture single page
  Future<bool> capturePage() async {
    if (!_cameraService.isInitialized) {
      return false;
    }

    try {
      _isProcessing = true;
      notifyListeners();

      final imageFile = await _cameraService.takePicture();

      if (imageFile != null) {
        // Detect edges and correct perspective
        final edges = await _imageProcessor.detectDocumentEdges(imageFile);

        final documentId = const Uuid().v4();
        final pageIndex = _currentScanImages.length;

        final outputPath =
            '${_storageService.documentsPath}/${documentId}_temp_$pageIndex.jpg';
        final correctedImage = await _imageProcessor.correctPerspective(
          imageFile,
          edges,
          outputPath,
        );

        if (correctedImage != null) {
          _currentScanImages.add(correctedImage.path);
          _isProcessing = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Failed to capture page: $e');
    }

    _isProcessing = false;
    notifyListeners();
    return false;
  }

  // Apply filter to current scan
  Future<bool> applyFilter(FilterType filter) async {
    if (_currentScanImages.isEmpty) return false;

    try {
      _isProcessing = true;
      notifyListeners();

      for (int i = 0; i < _currentScanImages.length; i++) {
        final inputFile = File(_currentScanImages[i]);
        final outputPath = inputFile.path.replaceAll('_temp_', '_filtered_');

        final filteredImage = await _imageProcessor.applyFilter(
          inputFile,
          filter,
          outputPath,
        );

        if (filteredImage != null) {
          // Delete old file if it's different
          if (inputFile.path != filteredImage.path) {
            await inputFile.delete();
          }
          _currentScanImages[i] = filteredImage.path;
        }
      }

      _currentFilter = filter;
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to apply filter: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  // Save current scan as document
  Future<bool> saveCurrentScan() async {
    if (_currentScanImages.isEmpty) return false;

    try {
      _isProcessing = true;
      notifyListeners();

      final documentId = const Uuid().v4();
      final now = DateTime.now();

      // Copy images to final location
      final finalImagePaths = <String>[];
      for (int i = 0; i < _currentScanImages.length; i++) {
        final tempFile = File(_currentScanImages[i]);
        final finalPath =
            await _storageService.saveImage(tempFile, documentId, i);
        finalImagePaths.add(finalPath);

        // Delete temp file
        await tempFile.delete();
      }

      // Create document model
      final document = DocumentModel(
        id: documentId,
        name: _currentDocumentName.isEmpty
            ? 'Document ${now.day}/${now.month}/${now.year}'
            : _currentDocumentName,
        imagePaths: finalImagePaths,
        createdAt: now,
        updatedAt: now,
        status: DocumentStatus.processed,
        appliedFilter: _currentFilter,
      );

      // Save to storage
      await _storageService.saveDocument(document);
      await loadDocuments();

      // Reset scan state
      _resetScanState();

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to save document: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      await _storageService.deleteDocument(documentId);
      _documents.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to delete document: $e');
      return false;
    }
  }

  // Cancel current scan
  void cancelScan() {
    // Delete temp images
    for (final imagePath in _currentScanImages) {
      File(imagePath).delete().catchError((_) => null);
    }
    _resetScanState();
  }

  void _resetScanState() {
    _currentScanImages = [];
    _currentDocumentName = '';
    _currentFilter = FilterType.none;
    _isScanning = false;
    notifyListeners();
  }

  // Update document name
  void updateDocumentName(String name) {
    _currentDocumentName = name;
    notifyListeners();
  }

  // Get documents by status
  List<DocumentModel> getDocumentsByStatus(DocumentStatus status) {
    return _documents.where((doc) => doc.status == status).toList();
  }

  // Remove single page from current scan
  void removePageFromScan(int index) {
    if (index >= 0 && index < _currentScanImages.length) {
      final imagePath = _currentScanImages[index];
      File(imagePath).delete().catchError((_) => null);
      _currentScanImages.removeAt(index);
      notifyListeners();
    }
  }
}