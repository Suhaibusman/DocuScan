import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = StorageService.instance;
  
  String _themeMode = 'system';
  String _defaultFilter = 'none';
  bool _autoEnhance = true;
  bool _autoSave = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _themeMode = _storageService.getThemeMode();
      _defaultFilter = _storageService.getDefaultFilter();
      _autoEnhance = _storageService.getAutoEnhance();
      _autoSave = _storageService.getAutoSave();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeLabel(_themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showThemeDialog,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Scanning',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.filter),
                  title: const Text('Default Filter'),
                  subtitle: Text(_getFilterLabel(_defaultFilter)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFilterDialog,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.auto_awesome),
                  title: const Text('Auto Enhance'),
                  subtitle: const Text('Automatically enhance scanned images'),
                  value: _autoEnhance,
                  onChanged: (value) async {
                    setState(() {
                      _autoEnhance = value;
                    });
                    await _storageService.setAutoEnhance(value);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.save),
                  title: const Text('Auto Save'),
                  subtitle: const Text('Automatically save after scanning'),
                  value: _autoSave,
                  onChanged: (value) async {
                    setState(() {
                      _autoSave = value;
                    });
                    await _storageService.setAutoSave(value);
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.gavel),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to terms of service
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'DocuScan - Professional Document Scanner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: _themeMode,
              onChanged: (value) async {
                setState(() {
                  _themeMode = value!;
                });
                await _storageService.setThemeMode(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: _themeMode,
              onChanged: (value) async {
                setState(() {
                  _themeMode = value!;
                });
                await _storageService.setThemeMode(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: _themeMode,
              onChanged: (value) async {
                setState(() {
                  _themeMode = value!;
                });
                await _storageService.setThemeMode(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('None'),
              value: 'none',
              groupValue: _defaultFilter,
              onChanged: (value) async {
                setState(() {
                  _defaultFilter = value!;
                });
                await _storageService.setDefaultFilter(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Grayscale'),
              value: 'grayscale',
              groupValue: _defaultFilter,
              onChanged: (value) async {
                setState(() {
                  _defaultFilter = value!;
                });
                await _storageService.setDefaultFilter(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Black & White'),
              value: 'blackWhite',
              groupValue: _defaultFilter,
              onChanged: (value) async {
                setState(() {
                  _defaultFilter = value!;
                });
                await _storageService.setDefaultFilter(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Enhanced'),
              value: 'enhanced',
              groupValue: _defaultFilter,
              onChanged: (value) async {
                setState(() {
                  _defaultFilter = value!;
                });
                await _storageService.setDefaultFilter(value!);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System';
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'grayscale':
        return 'Grayscale';
      case 'blackWhite':
        return 'Black & White';
      case 'enhanced':
        return 'Enhanced';
      case 'none':
      default:
        return 'None';
    }
  }
}