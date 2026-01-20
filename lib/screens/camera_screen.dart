import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../services/camera_service.dart';
import '../widgets/camera_overlay.dart';
import '../constants/colors.dart';
import 'scan_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final _cameraService = CameraService.instance;
  bool _isFlashOn = false;
  List<Offset>? _detectedCorners;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_cameraService.isInitialized)
            SizedBox.expand(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Camera Overlay
          if (_cameraService.isInitialized)
            CameraOverlay(
              screenSize: MediaQuery.of(context).size,
              detectedCorners: _detectedCorners,
            ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  IconButton(
                    onPressed: () => _cancelScan(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                  // Page counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pages: ${scanProvider.currentScanImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Flash toggle
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery/Preview
                    if (scanProvider.currentScanImages.isNotEmpty)
                      GestureDetector(
                        onTap: () => _previewScannedImages(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60),

                    // Capture Button
                    GestureDetector(
                      onTap: scanProvider.isProcessing ? null : _captureImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: scanProvider.isProcessing
                              ? Colors.grey
                              : AppColors.primary,
                        ),
                        child: scanProvider.isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                    ),

                    // Switch Camera
                    IconButton(
                      onPressed: _switchCamera,
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing Indicator
          if (scanProvider.isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Processing image...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _captureImage() async {
    final scanProvider = context.read<ScanProvider>();
    final success = await scanProvider.capturePage();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Page ${scanProvider.currentScanImages.length} captured'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture page'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _toggleFlash() async {
    final controller = _cameraService.controller;
    if (controller != null) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  void _switchCamera() async {
    await _cameraService.switchCamera();
    setState(() {});
  }

  void _previewScannedImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanPreviewScreen(),
      ),
    );
  }

  void _cancelScan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Scan'),
        content: const Text('Are you sure? All captured pages will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Scanning'),
          ),
          TextButton(
            onPressed: () {
              context.read<ScanProvider>().cancelScan();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close camera screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Scan'),
          ),
        ],
      ),
    );
  }
}
