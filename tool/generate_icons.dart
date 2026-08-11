import 'dart:io';
import 'package:image/image.dart' as img;

final _topColor = img.ColorRgba8(0x1D, 0x4E, 0xD8, 255);
final _bottomColor = img.ColorRgba8(0x7C, 0x3A, 0xED, 255);
final _white = img.ColorRgba8(255, 255, 255, 255);
final _transparent = img.ColorRgba8(0, 0, 0, 0);

img.Image _blank(int size) =>
    img.Image(width: size, height: size, numChannels: 4);

img.ColorRgba8 _lerpColor(img.ColorRgba8 a, img.ColorRgba8 b, double t) {
  return img.ColorRgba8(
    (a.r + (b.r - a.r) * t).round(),
    (a.g + (b.g - a.g) * t).round(),
    (a.b + (b.b - a.b) * t).round(),
    255,
  );
}

void _fillGradient(img.Image image) {
  for (var y = 0; y < image.height; y++) {
    final t = image.height <= 1 ? 0.0 : y / (image.height - 1);
    img.fillRect(
      image,
      x1: 0,
      y1: y,
      x2: image.width,
      y2: y + 1,
      color: _lerpColor(_topColor, _bottomColor, t),
    );
  }
}

void _drawRing(
  img.Image image, {
  required int x,
  required int y,
  required double radius,
  required double thickness,
  required img.Color color,
}) {
  final inner = (radius - thickness / 2).round();
  final outer = (radius + thickness / 2).round();
  for (var r = inner; r <= outer; r++) {
    if (r <= 0) continue;
    img.drawCircle(image, x: x, y: y, radius: r, color: color, antialias: true);
  }
}

void _drawLogo(
  img.Image canvas, {
  required double cx,
  required double cy,
  required double scale,
}) {
  int X(double v) => (cx + v * scale).round();
  int Y(double v) => (cy + v * scale).round();
  int R(double v) => (v * scale).round();

  final wavesX = X(250);
  final wavesY = Y(0);

  _drawRing(
    canvas,
    x: wavesX,
    y: wavesY,
    radius: R(160).toDouble(),
    thickness: R(38).toDouble(),
    color: _white,
  );
  _drawRing(
    canvas,
    x: wavesX,
    y: wavesY,
    radius: R(95).toDouble(),
    thickness: R(38).toDouble(),
    color: _white,
  );

  _drawRing(
    canvas,
    x: X(0),
    y: Y(90),
    radius: R(165).toDouble(),
    thickness: R(40).toDouble(),
    color: _white,
  );

  final capsuleHalfW = R(140);
  img.fillRect(
    canvas,
    x1: X(0) - capsuleHalfW,
    y1: Y(-70),
    x2: X(0) + capsuleHalfW,
    y2: Y(70),
    color: _white,
  );
  img.fillCircle(
    canvas,
    x: X(0),
    y: Y(-70),
    radius: R(140),
    color: _white,
    antialias: true,
  );
  img.fillCircle(
    canvas,
    x: X(0),
    y: Y(70),
    radius: R(140),
    color: _white,
    antialias: true,
  );
}

img.Image _circularMask(img.Image image, int cx, int cy, int radius) {
  final out = _blank(image.width);
  final r2 = radius * radius;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r2) {
        out.setPixel(x, y, image.getPixel(x, y));
      } else {
        out.setPixel(x, y, _transparent);
      }
    }
  }
  return out;
}

img.Image _buildMaster() {
  final canvas = _blank(1024);
  _fillGradient(canvas);
  _drawLogo(canvas, cx: 377, cy: 492, scale: 1.0);
  return canvas;
}

img.Image _buildForeground() {
  final canvas = _blank(1024);
  _drawLogo(canvas, cx: 377, cy: 492, scale: 0.88);
  return canvas;
}

img.Image _buildBackground() {
  final canvas = _blank(1024);
  _fillGradient(canvas);
  return canvas;
}

void _writePng(img.Image image, String path) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  print('  -> $path (${image.width}x${image.height})');
}

img.Image _scaled(img.Image image, int size) =>
    img.copyResize(image, width: size, height: size, interpolation: img.Interpolation.cubic);

const _legacySizes = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const _adaptiveSizes = <String, int>{
  'mipmap-mdpi': 108,
  'mipmap-hdpi': 162,
  'mipmap-xhdpi': 216,
  'mipmap-xxhdpi': 324,
  'mipmap-xxxhdpi': 432,
};

const _adaptiveXml = '''
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
''';

void main() {
  final master = _buildMaster();
  final foreground = _buildForeground();
  final background = _buildBackground();
  final round = _circularMask(master, 512, 512, 512);

  final resDir = 'android/app/src/main/res';

  print('Generating legacy launcher icons...');
  for (final entry in _legacySizes.entries) {
    _writePng(_scaled(master, entry.value), '$resDir/${entry.key}/ic_launcher.png');
    _writePng(_scaled(round, entry.value), '$resDir/${entry.key}/ic_launcher_round.png');
  }

  print('Generating adaptive icon layers...');
  for (final entry in _adaptiveSizes.entries) {
    _writePng(
      _scaled(foreground, entry.value),
      '$resDir/${entry.key}/ic_launcher_foreground.png',
    );
    _writePng(
      _scaled(background, entry.value),
      '$resDir/${entry.key}/ic_launcher_background.png',
    );
  }

  final anydpi = '$resDir/mipmap-anydpi-v26';
  Directory(anydpi).createSync(recursive: true);
  File('$anydpi/ic_launcher.xml').writeAsStringSync(_adaptiveXml);
  File('$anydpi/ic_launcher_round.xml').writeAsStringSync(_adaptiveXml);
  print('  -> $anydpi/ic_launcher.xml');
  print('  -> $anydpi/ic_launcher_round.xml');

  print('Generating Play Store icon...');
  final play = _blank(512);
  _fillGradient(play);
  _drawLogo(play, cx: 188.5, cy: 246, scale: 0.5);
  _writePng(play, 'branding/app_icon_512.png');

  _writePng(master, 'branding/app_icon_1024.png');

  print('Done.');
}
