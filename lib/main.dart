import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/scan_provider.dart';
import 'providers/pdf_provider.dart';
import 'services/storage_service.dart';
import 'services/camera_service.dart';
import 'services/ocr_service.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.instance.initialize();
  await CameraService.instance.initialize();
  await OCRService.instance.initialize();
  
  runApp(const DocuScanApp());
}

class DocuScanApp extends StatelessWidget {
  const DocuScanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ScanProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => PdfProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'DocuScan',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/camera': (context) => const CameraScreen(),
          '/pdf-viewer': (context) => const PdfViewerScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
