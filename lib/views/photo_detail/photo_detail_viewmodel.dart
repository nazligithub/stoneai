import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../services/stone_api_service.dart';
import '../../viewmodels/stone_app_provider.dart';

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

  /// Cropping tight around the stone is what the API actually receives, so it
  /// is worth its place: a stone photographed on a cluttered table gives the
  /// model more to misread, and every attempt costs a scan.
  ///
  /// The aspect-ratio picker and the rotate buttons are hidden — a stone has no
  /// correct orientation and no useful aspect ratio, and the native camera
  /// already applies the right rotation.
  Future<void> cropImage() async {
    if (_isDisposed) return;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _displayImagePath ?? originalImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'photo_detail.crop_title'.tr(),
            toolbarColor: CrystalColors.inkDark,
            toolbarWidgetColor: const Color(0xFFFBF3E9),
            statusBarColor: CrystalColors.inkDark,
            backgroundColor: CrystalColors.inkDark,
            activeControlsWidgetColor: CrystalColors.accentAction,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'photo_detail.crop_title'.tr(),
            cancelButtonTitle: 'photo_detail.crop_cancel'.tr(),
            doneButtonTitle: 'photo_detail.crop_done'.tr(),
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
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
      // Check premium status and free scan limit
      final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
      if (appProvider.hasUsedFreeScans) {
        // Show paywall if user has used all free scans
        StoneNavigationHelper.goToPaywall();
        return;
      }

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