import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _scannedData;
  final Set<String> _scannedQRCodes = {};
  bool _torchEnabled = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: const Text('Scan Result', style: TextStyle(color: Colors.green)),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = false;
              });
            },
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showDuplicateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: const Text('Alert!', style: TextStyle(color: Colors.red)),
        content: const Text('This QR code has already been scanned.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = false;
              });
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleQRScan(String qrData) {
    if (_scannedQRCodes.contains(qrData)) {
      _showDuplicateAlert();
    } else {
      _scannedQRCodes.add(qrData);
      _scannedData = qrData;
      _showResultDialog(qrData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen.shade700,
        foregroundColor: Colors.white,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _scannedQRCodes.clear();
                _scannedData = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleared all scanned QR codes'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Clear all scanned QR codes',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      if (!_isScanning) {
                        setState(() {
                          _isScanning = true;
                        });
                        
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            _handleQRScan(barcode.rawValue!);
                          }
                        }
                        
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              _isScanning = false;
                            });
                          }
                        });
                      }
                    },
                  ),
                  CustomPaint(
                    painter: ScannerOverlay(scanWindow: Rect.fromCenter(
                      center: MediaQuery.of(context).size.center(
                        const Offset(0, -50),
                      ),
                      width: 250,
                      height: 250,
                    )),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Scanned: ${_scannedQRCodes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.green.shade100,
              child: Column(
                children: [
                  const Text(
                    'Scan Voter QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _scannedData ?? 'No QR code scanned yet',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.green,
                        icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
                        onPressed: () {
                          setState(() {
                            _torchEnabled = !_torchEnabled;
                          });
                          cameraController.toggleTorch();
                        },
                      ),
                      IconButton(
                        color: Colors.green,
                        icon: Icon(_cameraFacing == CameraFacing.back 
                            ? Icons.camera_rear 
                            : Icons.camera_front),
                        onPressed: () {
                          setState(() {
                            _cameraFacing = _cameraFacing == CameraFacing.back
                                ? CameraFacing.front
                                : CameraFacing.back;
                          });
                          cameraController.switchCamera();
                        },
                      ),
                      IconButton(
                        color: Colors.green,
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () {
                          setState(() {
                            _scannedData = null;
                          });
                        },
                        tooltip: 'Clear current scan',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay({required this.scanWindow});

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRect(scanWindow, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}