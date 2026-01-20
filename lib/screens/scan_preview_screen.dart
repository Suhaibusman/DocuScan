import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../models/document_model.dart';
import '../widgets/filter_button.dart';
import '../constants/colors.dart';

class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({Key? key}) : super(key: key);

  @override
  State<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final scanProvider = context.read<ScanProvider>();
    _nameController.text = scanProvider.currentDocumentName;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview & Edit'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            onPressed: _showSaveDialog,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          if (scanProvider.currentScanImages.isEmpty) {
            return const Center(
              child: Text('No images to preview'),
            );
          }

          return Column(
            children: [
              // Document Name Editor
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Document Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: scanProvider.updateDocumentName,
                ),
              ),

              // Filter Options
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: FilterType.values.map((filter) {
                    return FilterButton(
                      filterType: filter,
                      isSelected: scanProvider.currentFilter == filter,
                      onPressed: () => _applyFilter(filter),
                    );
                  }).toList(),
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Page ${_currentPage + 1} of ${scanProvider.currentScanImages.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Image Preview
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: scanProvider.currentScanImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(scanProvider.currentScanImages[index]),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.backgroundLight,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Add More Pages
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Pages'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                    ),

                    // Delete Current Page
                    if (scanProvider.currentScanImages.length > 1)
                      ElevatedButton.icon(
                        onPressed: _deleteCurrentPage,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Page'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                      ),

                    // Save Document
                    ElevatedButton.icon(
                      onPressed: scanProvider.isProcessing ? null : _saveDocument,
                      icon: scanProvider.isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _applyFilter(FilterType filter) async {
    final scanProvider = context.read<ScanProvider>();
    final success = await scanProvider.applyFilter(filter);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to apply filter'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteCurrentPage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page'),
        content: const Text('Are you sure you want to delete this page?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final scanProvider = context.read<ScanProvider>();
              final imagePath = scanProvider.currentScanImages[_currentPage];
              
              // Delete file and remove from list
              File(imagePath).delete().catchError((_) {});
              scanProvider.currentScanImages.removeAt(_currentPage);
              
              // Adjust current page if necessary
              if (_currentPage >= scanProvider.currentScanImages.length) {
                _currentPage = scanProvider.currentScanImages.length - 1;
              }
              
              if (scanProvider.currentScanImages.isEmpty) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else {
                _pageController.animateToPage(
                  _currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
              
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Document Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('${context.read<ScanProvider>().currentScanImages.length} pages will be saved'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveDocument();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDocument() async {
    final scanProvider = context.read<ScanProvider>();
    final success = await scanProvider.saveCurrentScan();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Go back to home screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save document'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
