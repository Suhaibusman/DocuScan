# DocuScan - Play Store Deployment Checklist

## Pre-Development Checklist

- [ ] Flutter SDK installed (3.0.0+)
- [ ] Android Studio / VS Code setup
- [ ] Android SDK configured
- [ ] Physical Android device for testing

## Development Checklist

### Code Setup
- [ ] All files copied to correct locations
- [ ] `pubspec.yaml` configured
- [ ] Run `flutter pub get`
- [ ] No errors in `flutter doctor`
- [ ] Code runs without errors

### App Icon & Branding
- [ ] App icon created (1024x1024)
- [ ] App icon added to `assets/icon/app_icon.png`
- [ ] Foreground icon added
- [ ] Run `flutter pub run flutter_launcher_icons`
- [ ] App name finalized in code

### Features Testing
- [ ] Camera functionality works
- [ ] Multi-page scanning works
- [ ] All filters apply correctly (Grayscale, B&W, Enhanced)
- [ ] PDF generation successful
- [ ] OCR extracts text correctly
- [ ] Share functionality works
- [ ] Print functionality works
- [ ] Search documents works
- [ ] Delete documents works
- [ ] Settings save correctly

### Performance Testing
- [ ] Test with 20+ page documents
- [ ] Test on low-end device
- [ ] Test on high-end device
- [ ] Check memory usage
- [ ] Check battery consumption
- [ ] No crashes during normal use

## Pre-Release Checklist

### App Configuration
- [ ] Update app version in `pubspec.yaml`
- [ ] Update `applicationId` in `android/app/build.gradle`
- [ ] Update app name in `AndroidManifest.xml`
- [ ] Set correct `minSdkVersion` (21)
- [ ] Set correct `targetSdkVersion` (34)

### Permissions
- [ ] Camera permission declared
- [ ] Storage permissions declared
- [ ] All permissions tested on device
- [ ] Permission dialogs user-friendly

### App Signing
- [ ] Keystore created
- [ ] `key.properties` file created
- [ ] `build.gradle` updated for signing
- [ ] Test signed APK builds successfully

### Build Release
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build APK: `flutter build apk --release`
- [ ] Test release APK on device
- [ ] Build App Bundle: `flutter build appbundle --release`
- [ ] App bundle size < 150MB

## Play Store Assets

### Required Assets
- [ ] App icon 512x512 PNG
- [ ] Feature graphic 1024x500 PNG
- [ ] Phone screenshots (min 2, ideally 4-8)
  - [ ] Home screen
  - [ ] Camera screen
  - [ ] Preview screen
  - [ ] PDF viewer
  - [ ] Settings
- [ ] Tablet screenshots (min 1)

### Optional Assets
- [ ] Promo graphic 180x120
- [ ] TV banner 1280x720
- [ ] Video preview (30 sec - 2 min)

### Store Listing Content
- [ ] App title (max 50 chars): "DocuScan - Document Scanner"
- [ ] Short description (max 80 chars)
- [ ] Full description (max 4000 chars)
- [ ] Keywords for SEO
- [ ] Category selected: Productivity
- [ ] Tags added

## Legal & Compliance

### Privacy & Terms
- [ ] Privacy policy created
- [ ] Privacy policy hosted online
- [ ] Privacy policy URL added to store listing
- [ ] Terms of service created (if needed)
- [ ] Data collection disclosed
- [ ] GDPR compliance checked (if targeting EU)
- [ ] COPPA compliance (if app for children)

### Content Rating
- [ ] Content rating questionnaire completed
- [ ] Rating certificate obtained
- [ ] Rating appropriate for app

## Play Store Console Setup

### Account & App
- [ ] Google Play Developer account created ($25)
- [ ] Account verified
- [ ] App created in console
- [ ] App details filled

### Store Listing
- [ ] All required fields completed
- [ ] Screenshots uploaded
- [ ] Feature graphic uploaded
- [ ] App icon uploaded
- [ ] Short description added
- [ ] Full description added
- [ ] Category selected
- [ ] Contact email added
- [ ] Privacy policy URL added

### Pricing & Distribution
- [ ] App pricing set (Free/Paid)
- [ ] Countries selected for distribution
- [ ] Content rating added
- [ ] Target audience specified

### App Content
- [ ] Ads declaration completed
- [ ] In-app purchases declared (if any)
- [ ] Data safety form completed
- [ ] App access requirements specified

### Release
- [ ] App bundle uploaded
- [ ] Release notes written
- [ ] Release name set
- [ ] Rollout percentage chosen (100% or staged)

## Pre-Launch Checks

### Final Testing
- [ ] Test on 3+ different devices
- [ ] Test on different Android versions (10, 11, 12, 13, 14)
- [ ] Test all user flows end-to-end
- [ ] Test offline functionality
- [ ] Test with low storage
- [ ] Test with poor camera

### Security
- [ ] No hardcoded API keys
- [ ] No sensitive data logged
- [ ] Secure data storage
- [ ] ProGuard rules configured

### Performance
- [ ] App size optimized
- [ ] Images compressed
- [ ] Startup time < 3 seconds
- [ ] No memory leaks
- [ ] Battery usage acceptable

### User Experience
- [ ] All text is clear and grammatically correct
- [ ] All buttons have appropriate labels
- [ ] Error messages are helpful
- [ ] Loading indicators show during operations
- [ ] Crash handling implemented

## Launch Checklist

### Submission
- [ ] All checklist items above completed
- [ ] Submit app for review
- [ ] Monitor review status
- [ ] Respond to review feedback if needed

### Post-Launch
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Respond to user feedback
- [ ] Track download statistics
- [ ] Monitor performance metrics
- [ ] Plan first update

## Update Checklist (For Future Updates)

- [ ] Update version in `pubspec.yaml`
- [ ] Write release notes
- [ ] Test new features thoroughly
- [ ] Build new app bundle
- [ ] Upload to Play Store
- [ ] Update store listing if needed
- [ ] Announce update to users

## Emergency Checklist (If Issues Found)

- [ ] Identify critical bug
- [ ] Fix bug quickly
- [ ] Test fix thoroughly
- [ ] Increment version
- [ ] Build emergency release
- [ ] Submit urgent update
- [ ] Notify affected users

---

## Important Numbers to Track

- Minimum Android Version: **21 (Android 5.0 Lollipop)**
- Target Android Version: **34 (Android 14)**
- Version Code: Start at **1**
- Version Name: Start at **1.0.0**

## Recommended Tools

- **Screenshot Tool**: Use device screenshots or tools like Fastlane
- **Icon Generator**: Use online tools or Flutter launcher icons package
- **Privacy Policy Generator**: Use free online generators
- **APK Analyzer**: Use Android Studio's APK Analyzer
- **Testing**: Use Firebase Test Lab (optional)

---

**Remember**: Quality over speed. Better to delay launch than release a buggy app!

**Last Updated**: January 2026