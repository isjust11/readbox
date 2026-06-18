// ignore_for_file: avoid_print

import 'dart:io';

import 'package:image/image.dart' as img;

/// Generates Android/iOS launcher icons from [assets/images/logo.png].
/// Run: dart --packages=.dart_tool/package_config.json tool/generate_launcher_icons.dart
void main() {
  const logoPath = 'assets/images/logo.png';
  const bgArgb = 0xFFFFFFFF;

  final bytes = File(logoPath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode $logoPath');
    exit(1);
  }

  final square = img.copyResizeCropSquare(decoded, 1024);

  void writePng(String path, img.Image image, {bool flattenAlpha = false}) {
    var out = image;
    if (flattenAlpha) {
      out = _flattenOnColor(out, bgArgb);
    }
    File(path).writeAsBytesSync(img.encodePng(out));
    print('  $path');
  }

  img.Image resize(int size) =>
      img.copyResize(square, width: size, height: size, interpolation: img.Interpolation.cubic);

  print('iOS AppIcon.appiconset');
  const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const iosIcons = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-50x50@1x.png': 50,
    'Icon-App-50x50@2x.png': 100,
    'Icon-App-57x57@1x.png': 57,
    'Icon-App-57x57@2x.png': 114,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-72x72@1x.png': 72,
    'Icon-App-72x72@2x.png': 144,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  for (final entry in iosIcons.entries) {
    writePng('$iosDir/${entry.key}', resize(entry.value), flattenAlpha: true);
  }

  print('Android mipmap (legacy launcher)');
  const mipmap = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  for (final entry in mipmap.entries) {
    writePng(
      'android/app/src/main/res/${entry.key}/ic_launcher.png',
      resize(entry.value),
    );
  }

  print('Android adaptive foreground');
  const foreground = <String, int>{
    'drawable-mdpi': 108,
    'drawable-hdpi': 162,
    'drawable-xhdpi': 216,
    'drawable-xxhdpi': 324,
    'drawable-xxxhdpi': 432,
  };
  for (final entry in foreground.entries) {
    writePng(
      'android/app/src/main/res/${entry.key}/ic_launcher_foreground.png',
      resize(entry.value),
    );
  }

  print('Done.');
}

img.Image _flattenOnColor(img.Image src, int color) {
  final out = img.Image(src.width, src.height);
  out.fill(color);
  img.drawImage(out, src, blend: true);
  return out;
}
