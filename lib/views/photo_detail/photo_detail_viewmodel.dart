import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../helpers/stone_navigation_helper.dart';
import '../../services/stone_api_service.dart';

class PhotoDetailViewModel extends ChangeNotifier {
  final String originalImagePath;
  String? _displayImagePath;
  final bool _isProcessing = false;
  bool _isDisposed = false;
  String? _error;
  late final StoneApiService _apiService;

  String? get displayImagePath => _displayImagePath;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  PhotoDetailViewModel(this.originalImagePath) {
    debugPrint('PhotoDetailViewModel constructor called with path: $originalImagePath');
    try {
      _displayImagePath = originalImagePath;
      final currentLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _apiService = StoneApiService(
        userId: 'test-user-123', // TODO: Get from authenticated user
        locale: currentLocale,
      );
      debugPrint('PhotoDetailViewModel constructor completed successfully');
    } catch (e) {
      debugPrint('PhotoDetailViewModel constructor error: $e');
      _error = 'Failed to initialize photo detail: ${e.toString()}';
    }
  }

  Future<void> cropImage() async {
    if (_isDisposed) return;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _displayImagePath ?? originalImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF13C8A3),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
          ),
        ],
      );

      if (croppedFile != null && !_isDisposed) {
        _displayImagePath = croppedFile.path;
        _safeNotifyListeners();
      }
    } catch (e) {
      debugPrint('Crop error: $e');
    }
  }

  Future<void> startScan(BuildContext context) async {
    if (_isDisposed || _isProcessing) return;

    try {
      final imageFile = File(_displayImagePath ?? originalImagePath);
      
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Görsel dosyası bulunamadı');
      }

      // Navigate to loading screen which will handle the API call
      // Note: Scan count will be incremented when user actually views the results
      StoneNavigationHelper.navigateTo(
        '/stone-loading',
        arguments: _displayImagePath ?? originalImagePath,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _safeNotifyListeners();
    }
  }

  void retake() {
    // Navigate back to camera
    StoneNavigationHelper.goBack();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _apiService.dispose();
    super.dispose();
  }
}