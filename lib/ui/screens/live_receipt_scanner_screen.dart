import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../data/services/receipt_scanner_service.dart';
import '../theme/app_theme.dart';

class LiveReceiptScannerScreen extends StatefulWidget {
  const LiveReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  State<LiveReceiptScannerScreen> createState() => _LiveReceiptScannerScreenState();
}

class _LiveReceiptScannerScreenState extends State<LiveReceiptScannerScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isBusy = false;
  bool _isFlashOn = false;

  String? _lastAmountsKey;
  int _matchCount = 0;
  final int _requiredMatches = 3; // Sweet spot between 2 (too fast/unstable) and 4 (too slow)

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.veryHigh, // 1080p provides a good balance between OCR clarity and performance
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await _cameraController?.initialize();
    if (!mounted) return;
    
    // We intentionally don't await this so it streams
    _cameraController?.startImageStream(_processCameraImage);
    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isBusy = false;
        return;
      }

      final recognizedText = await _textRecognizer.processImage(inputImage);
      final amounts = ReceiptScannerService.extractPossibleAmounts(recognizedText.text);

      if (amounts.isNotEmpty) {
        final amountsKey = amounts.join('|');
        if (_lastAmountsKey == amountsKey) {
          _matchCount++;
          if (_matchCount >= _requiredMatches) {
            // Stop stream and show selection if needed
            await _cameraController?.stopImageStream();
            if (mounted) {
              if (amounts.length == 1) {
                Navigator.pop(context, amounts.first);
              } else {
                _showAmountSelectionSheet(amounts);
              }
            }
          }
        } else {
          _lastAmountsKey = amountsKey;
          _matchCount = 1;
        }
      } else {
        _lastAmountsKey = null;
        _matchCount = 0;
      }
    } catch (e) {
      debugPrint('Error processing image stream: $e');
    }

    _isBusy = false;
  }

  Future<void> _showAmountSelectionSheet(List<double> amounts) async {
    final selectedAmount = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Birden fazla tutar algılandı.\nLütfen doğru tutarı seçin:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              ...amounts.map((amount) => ListTile(
                    title: Text('${amount.toStringAsFixed(2).replaceAll('.', ',')} ₺', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.check_circle_outline, color: AppTheme.futureColor),
                    onTap: () => Navigator.pop(context, amount),
                  )),
            ],
          ),
        );
      },
    );

    if (selectedAmount != null) {
      if (mounted) Navigator.pop(context, selectedAmount);
    } else {
      if (mounted) {
        _lastAmountsKey = null;
        _matchCount = 0;
        _cameraController?.startImageStream(_processCameraImage);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) return null;
    
    final rotation = InputImageRotationValue.fromRawValue(_cameraController!.description.sensorOrientation);
    if (rotation == null) return null;

    final bytes = Platform.isAndroid
        ? _concatenatePlanes(image.planes)
        : image.planes[0].bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _toggleFlash() {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fiş Tara', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          )
        ],
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: AppTheme.futureColor))
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                
                // Overlay for guide frame
                Container(
                  decoration: ShapeDecoration(
                    shape: _ScannerOverlayShape(
                      borderColor: AppTheme.futureColor,
                      borderWidth: 3.0,
                    ),
                  ),
                ),
                
                const Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Okutmak istediğiniz tutarı çerçevenin içine alın',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getClipPath(Rect rect) {
      return Path()
        ..addRect(rect)
        // Center cutout
        ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: rect.center,
                width: rect.width * 0.8,
                height: rect.width * 0.4),
            const Radius.circular(10)))
        ..fillType = PathFillType.evenOdd;
    }

    return _getClipPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final centerRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.8,
      height: rect.width * 0.4,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // First draw standard black54 overlay matching the cutout
    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(10)))
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Then draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
      
    canvas.drawRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(10)), borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
    );
  }
}
