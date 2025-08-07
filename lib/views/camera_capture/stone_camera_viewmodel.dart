import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../helpers/stone_navigation_helper.dart';

class StoneCameraViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  // Camera state
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  
  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  // Capture state
  bool _isCapturing = false;
  bool get isCapturing => _isCapturing;

  // Flash state
  bool _isFlashOn = false;
  bool get isFlashOn => _isFlashOn;

  // Lifecycle state
  bool _isDisposed = false;

  // Safe notifyListeners that checks if disposed
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      // Set flash mode
      await _cameraController!.setFlashMode(FlashMode.off);
      
      _isCameraInitialized = true;
      
    } catch (e) {
      _error = 'Failed to initialize camera: ${e.toString()}';
      debugPrint('Camera initialization error: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Switch between front and back cameras
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      
      await _cameraController?.dispose();
      
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to switch camera: ${e.toString()}';
      debugPrint('Camera switch error: $e');
      _safeNotifyListeners();
    }
  }

  // Toggle flash
  Future<void> toggleFlash() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  // Capture photo
  Future<void> capturePhoto() async {
    if (!_isCameraInitialized || _cameraController == null || _isCapturing) return;

    try {
      _isCapturing = true;
      _safeNotifyListeners();

      // Take picture
      final XFile image = await _cameraController!.takePicture();
      
      // Process the image
      await _processImage(image.path);
      
    } catch (e) {
      _error = 'Failed to capture photo: ${e.toString()}';
      debugPrint('Photo capture error: $e');
      _safeNotifyListeners();
    } finally {
      _isCapturing = false;
      _safeNotifyListeners();
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    debugPrint('Starting gallery image picker...');
    try {
      _error = null;
      _safeNotifyListeners();
      
      debugPrint('Opening image picker...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      debugPrint('Image picker completed. Selected: ${image?.path}');
      
      if (image != null) {
        debugPrint('Processing selected image: ${image.path}');
        await _processImage(image.path);
        debugPrint('Image processing completed');
      } else {
        debugPrint('No image selected from gallery');
      }
    } catch (e) {
      _error = 'Failed to pick image: ${e.toString()}';
      debugPrint('Image picker error: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
      _safeNotifyListeners();
    }
  }

  // Process captured/picked image
  Future<void> _processImage(String imagePath) async {
    try {
      debugPrint('_processImage called with path: $imagePath');
      
      // Check if file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Selected image file does not exist: $imagePath');
      }
      
      debugPrint('File exists, size: ${await file.length()} bytes');
      
      // Navigate to photo detail screen for crop, retake, and scan options
      debugPrint('Navigating to photo detail screen...');
      
      await StoneNavigationHelper.goToPhotoDetail(imagePath: imagePath);
      
      debugPrint('Navigation completed successfully');
      
    } catch (e) {
      _error = 'Failed to process image: ${e.toString()}';
      debugPrint('Image processing error: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
      _safeNotifyListeners();
    }
  }

  // Get camera tips based on current state
  String getCameraTip() {
    final tips = [
      'Good lighting helps identification accuracy',
      'Hold the camera steady for clear photos',
      'Fill the frame with your stone',
      'Avoid shadows on the stone surface',
      'Clean your camera lens for better results',
    ];
    
    return tips[DateTime.now().millisecond % tips.length];
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraController?.dispose();
    super.dispose();
  }
}