

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';  // Bu satırı ekleyin

void main() {
  runApp(MaterialApp(
    home: CameraScreen(),
  ));
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Fotoğraf çekme fonksiyonu
  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      await _controller!.takePicture().then((XFile file) {
        if (file != null) {
          setState(() {
            // Fotoğrafın kaydedildiği yolu gösterebiliriz veya fotoğrafı bir yerde kullanabiliriz
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Fotoğraf kaydedildi: $path'),
            ));
          });
        }
      });
    } catch (e) {
      print('Fotoğraf çekilemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isCameraInitialized
            ? Stack(
          children: [
            SizedBox.expand(
              child: CameraPreview(_controller!),
            ),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.4,
              child: FloatingActionButton(
                onPressed: _takePicture,
                child: Icon(Icons.camera_alt),
              ),
            ),
          ],
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}




