import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../providers/pdf_provider.dart';
import '../constants/colors.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isGeneratingPdf = false;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = ModalRoute.of(context)!.settings.arguments as DocumentModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name),
        backgroundColor: AppColors.primary,
        actions: [
          if (document.hasPdf)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _sharePdf(document),
            ),
          if (document.hasPdf)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _printPdf(document),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'generate_pdf':
                  _generatePdf(document);
                  break;
                case 'perform_ocr':
                  _performOCR(document);
                  break;
                case 'view_text':
                  _viewExtractedText(document);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!document.hasPdf)
                const PopupMenuItem(
                  value: 'generate_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Generate PDF'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'perform_ocr',
                child: Row(
                  children: [
                    Icon(Icons.text_fields),
                    SizedBox(width: 8),
                    Text('Extract Text (OCR)'),
                  ],
                ),
              ),
              if (document.hasText)
                const PopupMenuItem(
                  value: 'view_text',
                  child: Row(
                    children: [
                      Icon(Icons.article),
                      SizedBox(width: 8),
                      Text('View Extracted Text'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: document.hasPdf
          ? SfPdfViewer.file(
              File(document.pdfPath!),
              controller: _pdfViewerController,
            )
          : _buildImageViewer(document),
    );
  }

  Widget _buildImageViewer(DocumentModel document) {
    return PageView.builder(
      itemCount: document.imagePaths.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.primary,
              child: Text(
                'Page ${index + 1} of ${document.imagePaths.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.file(
                  File(document.imagePaths[index]),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePdf(DocumentModel document) async {
    final pdfProvider = context.read<PdfProvider>();

    // Show options dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _GeneratePdfDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _isGeneratingPdf = true;
      });

      final pdfPath = await pdfProvider.generatePdf(
        document,
        watermarkText: result['watermark'],
        addPageNumbers: result['pageNumbers'] ?? false,
      );

      setState(() {
        _isGeneratingPdf = false;
      });

      if (pdfPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload the screen to show PDF
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PdfViewerScreen(),
            settings: RouteSettings(arguments: document),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate PDF'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _performOCR(DocumentModel document) async {
    final pdfProvider = context.read<PdfProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final extractedText = await pdfProvider.performOCR(document);

    if (mounted) {
      Navigator.pop(context);

      if (extractedText != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text extracted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _viewExtractedText(document.copyWith(extractedText: extractedText));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text found or OCR failed'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  void _viewExtractedText(DocumentModel document) {
    if (!document.hasText) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Extracted Text',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: SelectableText(
                      document.extractedText!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sharePdf(DocumentModel document) async {
    if (!document.hasPdf) return;

    final pdfProvider = context.read<PdfProvider>();
    final success = await pdfProvider.sharePdf(document.pdfPath!, document.name);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share PDF'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _printPdf(DocumentModel document) async {
    if (!document.hasPdf) return;

    final pdfProvider = context.read<PdfProvider>();
    final success = await pdfProvider.printPdf(document.pdfPath!);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to print PDF'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _GeneratePdfDialog extends StatefulWidget {
  @override
  State<_GeneratePdfDialog> createState() => _GeneratePdfDialogState();
}

class _GeneratePdfDialogState extends State<_GeneratePdfDialog> {
  final TextEditingController _watermarkController = TextEditingController();
  bool _addPageNumbers = false;

  @override
  void dispose() {
    _watermarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('PDF Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _watermarkController,
            decoration: const InputDecoration(
              labelText: 'Watermark (optional)',
              hintText: 'Enter watermark text',
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Add Page Numbers'),
            value: _addPageNumbers,
            onChanged: (value) {
              setState(() {
                _addPageNumbers = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'watermark': _watermarkController.text.isEmpty
                  ? null
                  : _watermarkController.text,
              'pageNumbers': _addPageNumbers,
            });
          },
          child: const Text('Generate'),
        ),
      ],
    );
  }
}