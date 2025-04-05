import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class VoterQrScreen extends StatefulWidget {
  final String documentId;

  const VoterQrScreen({super.key, required this.documentId});

  @override
  State<VoterQrScreen> createState() => _VoterQrScreenState();
}

class _VoterQrScreenState extends State<VoterQrScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveQrToGallery(Map<String, dynamic> data) async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied. Please enable it in settings');
      }

      final qrData = jsonEncode({
        'type': 'voter_info',
        'name': data['name'] ?? 'Not Available',
        'dob': data['dob'] ?? 'Not Available',
        'aadhar_number': data['aadhar_number'] ?? 'Not Available',
        'address': data['address'] ?? 'Not Available',
        'pincode': data['pin_code'] ?? 'Not Available',
      });

      final qrWidget = RepaintBoundary(
        key: _globalKey,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Column(
                children: [
                  Text(
                    'Election Commission of India',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const ui.Color.fromARGB(255, 218, 3, 43),
                    ),
                  ),
                  Text(
                    'Government of India',
                    style: TextStyle(
                      fontSize: 16,
                      color: const ui.Color.fromARGB(255, 238, 97, 3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VoteNet India\'s Online Verification',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const ui.Color.fromARGB(255, 8, 21, 198),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // QR Code (centered) - Black QR code
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Name of Voter: ${data['name'] ?? 'Not Available'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      );

      final overlayState = Overlay.of(context);
      final overlayEntry = OverlayEntry(builder: (context) => qrWidget);
      overlayState.insert(overlayEntry);
      await Future.delayed(const Duration(milliseconds: 500));

      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        overlayEntry.remove();
        throw Exception('Failed to render QR code');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlayEntry.remove();

      if (byteData == null) throw Exception('Failed to convert image to bytes');

      await FlutterImageGallerySaver.saveImage(byteData.buffer.asUint8List());

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    radius: 30,
                    child: Icon(
                      Icons.check,
                      color: Colors.green[800],
                      size: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "QR Saved Successfully!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your voter QR code has been saved to your gallery.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color:  ui.Color.fromARGB(255, 20, 20, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter QR Code'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('voters')
              .doc(widget.documentId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.shade400,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.blue.shade600, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading voter data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Go Back', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, color: Colors.blue.shade600, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Voter record not found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Go Back', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Voter Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Election Commission of India',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const ui.Color.fromARGB(255, 218, 3, 43),
                                  ),
                                ),
                                Text(
                                  'Government of India',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const ui.Color.fromARGB(255, 238, 97, 3),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'VoteNet India\'s Online Verification',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                     color: const ui.Color.fromARGB(255, 8, 21, 198),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Divider(color: Colors.blue.shade200),
                              ],
                            ),
                            
                            _buildInfoRow('Name of Voter', data['name'] ?? 'Not Available'),
                            Divider(color: Colors.blue.shade200),
                            _buildInfoRow('Date of Birth', data['dob'] ?? 'Not Available'),
                            Divider(color: Colors.blue.shade200),
                            _buildInfoRow('Aadhar Number', data['aadhar_number'] ?? 'Not Available'),
                            Divider(color: Colors.blue.shade200),
                            _buildInfoRow('Address', data['address'] ?? 'Not Available'),
                            Divider(color: Colors.blue.shade200),
                            _buildInfoRow('PIN Code', data['pin_code']?.toString() ?? 'Not Available'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // QR Code Display Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Your Verification QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const ui.Color.fromARGB(255, 2, 50, 122),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100, width: 2),
                            ),
                            child: QrImageView(
                              data: jsonEncode({
                                'type': 'voter_info',
                                'name': data['name'] ?? 'Not Available',
                                'aadhar_number': data['aadhar_number'] ?? 'Not Available',
                              }),
                              version: QrVersions.auto,
                              size: 200,
                              gapless: true,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['name'] ?? 'Not Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Generate QR Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.qr_code, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Saving QR...' : 'Save QR to Gallery',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: _isSaving ? null : () => _saveQrToGallery(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.blue.shade200,
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}