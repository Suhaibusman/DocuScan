# DocuScan - Professional Document Scanner App

A complete Flutter document scanning application similar to CamScanner with all professional features including OCR, PDF generation, image filters, and more.

## Features

✅ **Document Capture & Scanning**
- Capture documents using device camera
- Automatic edge detection and perspective correction
- Multi-page scanning support
- Manual crop adjustment

✅ **Image Enhancement**
- Grayscale filter
- Black & White filter
- Enhanced mode (brightness, contrast, sharpness)
- Auto-enhance option

✅ **PDF Generation**
- Convert scanned images to PDF
- Add watermarks
- Page numbers support
- High-quality compression

✅ **OCR (Text Recognition)**
- Extract text from scanned documents
- Multi-language support
- Searchable PDFs
- Copy and share extracted text

✅ **Document Management**
- Organize scanned documents
- Search by name or content
- Statistics and insights
- Sort by date

✅ **Sharing & Export**
- Share PDFs via any app
- Print documents
- Export images
- Cloud backup ready

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter --version
   ```

2. **Android Studio** or **VS Code** with Flutter extensions

3. **Android SDK** (API level 21 or higher for Android)

### Installation Steps

1. **Clone or create the project**
   ```bash
   flutter create docuscan
   cd docuscan
   ```

2. **Replace the files**
   - Copy all provided files to their respective locations
   - Ensure folder structure matches exactly

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Create necessary folders**
   ```bash
   mkdir -p assets/images
   mkdir -p assets/icon
   ```

5. **Add app icon**
   - Place your app icon at `assets/icon/app_icon.png` (1024x1024 recommended)
   - Place foreground icon at `assets/icon/app_icon_foreground.png`

6. **Generate launcher icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## Running the App

### Development Mode

```bash
# Run on connected device or emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device_id>

# Run in release mode for testing
flutter run --release
```

### Build for Production

#### Android APK

```bash
# Build APK
flutter build apk --release

# Build split APKs (recommended for Play Store)
flutter build apk --split-per-abi --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)

```bash
# Build App Bundle
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

## Play Store Deployment

### 1. Prepare App Signing

Create a keystore for signing your app:

```bash
keytool -genkey -v -keystore ~/docuscan-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias docuscan
```

Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=docuscan
storeFile=<path-to-keystore>/docuscan-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

### 2. Build Release App Bundle

```bash
flutter build appbundle --release
```

### 3. Play Store Console Setup

1. **Create Play Store Account**
   - Go to https://play.google.com/console
   - Pay one-time $25 registration fee

2. **Create Application**
   - Click "Create app"
   - Fill in app details:
     - App name: DocuScan
     - Default language: English
     - App type: App
     - Category: Productivity

3. **Store Listing**
   - App description (short & full)
   - Screenshots (at least 2)
   - Feature graphic (1024x500)
   - App icon (512x512)

4. **Content Rating**
   - Complete questionnaire
   - Get rating certificate

5. **Privacy Policy**
   - Add privacy policy URL (required)

6. **Upload App Bundle**
   - Go to "Production" → "Create new release"
   - Upload `app-release.aab`
   - Add release notes
   - Review and roll out

### 4. Required Assets for Play Store

Create these assets:

- **App Icon**: 512x512 PNG
- **Feature Graphic**: 1024x500 PNG
- **Screenshots**: 
  - Phone: at least 2 (min 320px, max 3840px)
  - Tablet: at least 1 (recommended)
- **Promotional Graphics** (optional):
  - Promo graphic: 180x120
  - TV banner: 1280x720

## Privacy Policy

Create a privacy policy that covers:
- What data the app collects
- How data is used
- Data storage and security
- User rights
- Contact information

Host it on:
- Your website
- GitHub Pages
- Google Sites (free)

## Important Notes

### Permissions

The app requires these permissions:
- **Camera**: For scanning documents
- **Storage**: For saving scanned documents and PDFs
- **Internet**: For potential future cloud features

### Testing Before Release

1. **Test all features**:
   - Document scanning
   - Image filters
   - PDF generation
   - OCR functionality
   - Sharing
   - Printing

2. **Test on multiple devices**:
   - Different Android versions
   - Different screen sizes
   - Different camera qualities

3. **Performance testing**:
   - Large documents (20+ pages)
   - Multiple scans
   - Memory usage
   - Battery consumption

### Optimization Tips

1. **Reduce APK size**:
   ```bash
   flutter build apk --split-per-abi --release
   ```

2. **Enable R8 (already configured)**:
   - Reduces code size
   - Optimizes performance

3. **Optimize images**:
   - Compress images before scanning
   - Use appropriate quality settings

## Troubleshooting

### Common Issues

1. **Camera not working**
   - Check permissions in AndroidManifest.xml
   - Test on physical device (emulator cameras have limitations)

2. **PDF generation fails**
   - Check storage permissions
   - Ensure sufficient device storage

3. **OCR not accurate**
   - Ensure good lighting
   - Use higher resolution images
   - Try different filters

### Debug Commands

```bash
# Check for errors
flutter doctor

# Clean build
flutter clean
flutter pub get

# View logs
flutter logs

# Analyze code
flutter analyze
```

## Version Updates

To update version:

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+build_number
   ```

2. Rebuild:
   ```bash
   flutter build appbundle --release
   ```

3. Upload new version to Play Store

## Future Enhancements

Planned features:
- [ ] Cloud backup (Firebase/Google Drive)
- [ ] Document templates
- [ ] Batch scanning
- [ ] Document annotations
- [ ] Multiple language OCR
- [ ] Dark mode enhancements
- [ ] Widget support

## Support

For issues or questions:
- GitHub Issues: [Your repo]
- Email: [Your email]
- Documentation: [Your docs]

## License

[Your chosen license]

---

**Built with Flutter ❤️**

Last updated: January 2025