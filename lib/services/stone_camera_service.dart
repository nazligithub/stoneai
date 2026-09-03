import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../helpers/stone_navigation_helper.dart';

/// Opens the platform camera and sends the captured image to the scan flow.
///
/// Keeping this in one place prevents each camera button from maintaining a
/// separate camera controller or presenting a second, custom camera UI.
class StoneCameraService {
  StoneCameraService._();

  static final StoneCameraService instance = StoneCameraService._();

  final ImagePicker _imagePicker = ImagePicker();
  bool _isOpeningCamera = false;

  Future<XFile?> captureImage({BuildContext? context}) async {
    if (_isOpeningCamera) return null;

    // Resolve the messenger before the native picker suspends this method.
    // This avoids retaining a BuildContext across an async gap.
    final messenger = context != null && context.mounted
        ? ScaffoldMessenger.maybeOf(context)
        : null;

    _isOpeningCamera = true;
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Native camera error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showCameraError(messenger);
      return null;
    } catch (error, stackTrace) {
      debugPrint('Native camera error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showCameraError(messenger);
      return null;
    } finally {
      _isOpeningCamera = false;
    }
  }

  Future<void> openNativeCamera({BuildContext? context}) async {
    final image = await captureImage(context: context);

    // Cancelling the native camera is a normal user action.
    if (image == null) return;

    // Wait for the detail route so compatibility callers can cleanly return
    // to the screen that launched the native camera.
    await StoneNavigationHelper.goToPhotoDetail(imagePath: image.path);
  }

  void _showCameraError(ScaffoldMessengerState? messenger) {
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('camera.error.message'.tr())));
  }
}
