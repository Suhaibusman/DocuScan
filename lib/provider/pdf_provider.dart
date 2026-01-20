import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document_model.dart';
import '../services/storage_service.dart';
import '../services/ocr_service.dart';

class PdfProvider extends ChangeNotifier {
  final _storageService = StorageService.instance;
  final _ocrService = OCRService.instance;

  bool _isGeneratingPdf = false;
  bool _isPerformingOcr = false;
  String? _currentPdfPath;

  bool get isGeneratingPdf => _isGeneratingPdf;
  bool get isPerformingOcr => _isPerformingOcr;
  String? get currentPdfPath => _currentPdfPath;

  // Generate PDF from document
  Future<String?> generatePdf(
    DocumentModel document, {
    String? watermarkText,
    bool addPageNumbers = false,
  }) async {
    try {
      _isGeneratingPdf = true;
      notifyListeners();

      final pdf = pw.Document();

      for (int i = 0; i < document.imagePaths.length; i++) {
        final imageFile = File(document.imagePaths[i]);
        if (!await imageFile.exists()) continue;

        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                  if (watermarkText != null)
                    pw.Center(
                      child: pw.Opacity(
                        opacity: 0.3,
                        child: pw.Transform.rotate(
                          angle: -0.5,
                          child: pw.Text(
                            watermarkText,
                            style: pw.TextStyle(
                              fontSize: 48,
                              color: PdfColors.grey,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (addPageNumbers)
                    pw.Positioned(
                      bottom: 20,
                      right: 20,
                      child: pw.Text(
                        'Page ${i + 1} of ${document.imagePaths.length}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      }

      final pdfPath = '${_storageService.pdfPath}/${document.name}.pdf';
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // Update document with PDF path
      final updatedDocument = document.copyWith(
        pdfPath: pdfPath,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveDocument(updatedDocument);

      _currentPdfPath = pdfPath;
      _isGeneratingPdf = false;
      notifyListeners();

      return pdfPath;
    } catch (e) {
      debugPrint('PDF generation failed: $e');
      _isGeneratingPdf = false;
      notifyListeners();
      return null;
    }
  }

  // Perform OCR on document
  Future<String?> performOCR(DocumentModel document) async {
    try {
      _isPerformingOcr = true;
      notifyListeners();

      final extractedTexts = <String>[];

      for (final imagePath in document.imagePaths) {
        final text = await _ocrService.extractTextFromImage(imagePath);
        if (text.isNotEmpty) {
          extractedTexts.add(text);
        }
      }

      final fullText = extractedTexts.join('\n\n--- Page Break ---\n\n');

      // Update document with extracted text
      if (fullText.isNotEmpty) {
        final updatedDocument = document.copyWith(
          extractedText: fullText,
          updatedAt: DateTime.now(),
        );
        await _storageService.saveDocument(updatedDocument);
      }

      _isPerformingOcr = false;
      notifyListeners();

      return fullText.isEmpty ? null : fullText;
    } catch (e) {
      debugPrint('OCR failed: $e');
      _isPerformingOcr = false;
      notifyListeners();
      return null;
    }
  }

  // Print PDF
  Future<bool> printPdf(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(onLayout: (format) => bytes);
      return true;
    } catch (e) {
      debugPrint('Print failed: $e');
      return false;
    }
  }

  // Share PDF
  Future<bool> sharePdf(String pdfPath, String documentName) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return false;

      await Share.shareXFiles(
        [XFile(pdfPath)],
        subject: documentName,
        text: 'Sharing document: $documentName',
      );
      return true;
    } catch (e) {
      debugPrint('Share failed: $e');
      return false;
    }
  }

  // Generate PDF with custom settings
  Future<String?> generateCustomPdf({
    required DocumentModel document,
    PdfPageFormat? pageFormat,
    String? watermark,
    bool pageNumbers = false,
    bool compress = true,
  }) async {
    return generatePdf(
      document,
      watermarkText: watermark,
      addPageNumbers: pageNumbers,
    );
  }
}