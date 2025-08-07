import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'stone_camera_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../viewmodels/stone_app_provider.dart';

class StoneCameraView extends StatelessWidget {
  const StoneCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneCameraViewModel()..initializeCamera(),
      child: const _StoneCameraViewContent(),
    );
  }
}

class _StoneCameraViewContent extends StatelessWidget {
  const _StoneCameraViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoneCameraViewModel, StoneAppProvider>(
      builder: (context, cameraViewModel, appProvider, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Camera preview
                if (cameraViewModel.isCameraInitialized)
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: cameraViewModel.cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraViewModel.cameraController!),
                    ),
                  )
                else if (cameraViewModel.isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (cameraViewModel.hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'camera.error.title'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          cameraViewModel.error ?? 'camera.error.message'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            gradient: CrystalColors.crystalTabGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: cameraViewModel.initializeCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text('camera.error.try_again'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top overlay with Rockify app bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // App title
                        Text(
                            'Rockify',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        const Spacer(),
                        // AI Chat button
                        Container(
                          margin: EdgeInsets.only(right: 8.w),
                          child: TextButton.icon(
                            onPressed: () {
                              StoneNavigationHelper.goToAIChat();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.auto_awesome_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                            label: Text(
                              'AI Chat',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // PRO button
                        Container(
                          margin: EdgeInsets.only(right: 8.w),
                          child: TextButton(
                            onPressed: appProvider.isPremiumUser 
                                ? null 
                                : () {
                                    StoneNavigationHelper.goToPaywall();
                                  },
                            style: TextButton.styleFrom(
                              backgroundColor: appProvider.isPremiumUser 
                                  ? Colors.green 
                                  : CrystalColors.primaryBlue,
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!appProvider.isPremiumUser) ...[
                                  Text(
                                    '💎',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  SizedBox(width: 4.w),
                                ],
                                Text(
                                  appProvider.isPremiumUser ? 'Pro' : 'Pro',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Settings button
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/gem-settings');
                          },
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom overlay with controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 32.w,
                      right: 32.w,
                      bottom: 120.h, // More space from tab bar
                      top: 24.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery button
                        IconButton(
                          onPressed: () async {
                            if (appProvider.canScanForFree) {
                              try {
                                await cameraViewModel.pickImageFromGallery();
                              } catch (e) {
                                debugPrint('Gallery picker error: $e');
                              }
                            } else {
                              StoneNavigationHelper.goToPaywall();
                            }
                          },
                          icon: Container(
                            width: 56.w,
                            height: 56.h,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),

                        // Capture button
                        GestureDetector(
                          onTap: cameraViewModel.isCameraInitialized && !cameraViewModel.isCapturing
                              ? () async {
                                  if (appProvider.canScanForFree) {
                                    cameraViewModel.capturePhoto();
                                  } else {
                                    StoneNavigationHelper.goToPaywall();
                                  }
                                }
                              : null,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: cameraViewModel.isCapturing
                                  ? null
                                  : CrystalColors.crystalTabGradient,
                              color: cameraViewModel.isCapturing
                                  ? Colors.grey.withValues(alpha: 0.5)
                                  : null,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: cameraViewModel.isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),

                        // Flash button
                        IconButton(
                          onPressed: cameraViewModel.toggleFlash,
                          icon: Container(
                            width: 56.w,
                            height: 56.h,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Icon(
                              cameraViewModel.isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: cameraViewModel.isFlashOn ? Colors.yellow : Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}