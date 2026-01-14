# One App

A Flutter utility app that bundles QR, OCR, image analysis, and PDF tools in one place.

## Features
- QR code generator with templates and custom branding (logo + colors)
- QR code scanner with link detection, copy/open actions
- Image to text (multi‑script OCR)
- Image labeling + forensic insights (EXIF, hash, objects, faces, colors, histogram)
- PDF to text extraction
- PDF to DOC (local extraction + CloudConvert for layout‑preserving DOCX)
- Light/Dark/System theme support

## Requirements
- Flutter SDK (stable)
- Android SDK

## Run
```bash
flutter pub get
flutter run
```

## CloudConvert (PDF → DOCX with layout)
Set the API key at build time:
```bash
flutter run --dart-define=CLOUDCONVERT_API_KEY=YOUR_KEY_HERE
```
Without the key, the app falls back to local text extraction and saves a DOC file.

## Saving files
- QR codes save to the gallery.
- PDF → DOC saves to the Downloads folder (Android).

## Notes
- The app uses ML Kit on‑device models for OCR and vision features.
- Some features require runtime permissions (camera, photos/storage).

## Project structure
- `lib/` main Flutter code
- `android/` native Android integration (Downloads save channel)
