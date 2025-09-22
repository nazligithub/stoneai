import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'photo_detail_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../viewmodels/stone_app_provider.dart';

class PhotoDetailView extends StatelessWidget {
  final String imagePath;
  
  const PhotoDetailView({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('PhotoDetailView build called with imagePath: $imagePath');
    return ChangeNotifierProvider(
      create: (_) {
        debugPrint('Creating PhotoDetailViewModel with imagePath: $imagePath');
        return PhotoDetailViewModel(imagePath);
      },
      child: const _PhotoDetailViewContent(),
    );
  }
}

class _PhotoDetailViewContent extends StatelessWidget {
  const _PhotoDetailViewContent();

  @override
  Widget build(BuildContext context) {
    debugPrint('_PhotoDetailViewContent build called');
    return Consumer2<PhotoDetailViewModel, StoneAppProvider>(
      builder: (context, viewModel, appProvider, child) {
        debugPrint('Consumer builder called, displayImagePath: ${viewModel.displayImagePath}');
        if (viewModel.error != null) {
          debugPrint('PhotoDetailViewModel has error: ${viewModel.error}');
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Image Display with constrained size and white border
                Positioned(
                  top: 100.h, // Space for app bar
                  left: 16.w,
                  right: 16.w,
                  bottom: 200.h, // Space for controls
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: viewModel.displayImagePath != null
                          ? Image.file(
                              File(viewModel.displayImagePath!),
                              fit: BoxFit.contain,
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: CrystalColors.primaryBlue,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                // Top header with PRO and AI buttons
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
                    child: Center(
                      child: Text(
                        'Rock Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.9),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Error message
                        if (viewModel.error != null)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    viewModel.error!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Start Scan button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: CrystalColors.crystalTabGradient,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: ElevatedButton(
                              onPressed: viewModel.isProcessing
                                  ? null
                                  : () => viewModel.startScan(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 0,
                              ),
                            child: viewModel.isProcessing
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.w,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'photo_detail.start_scan'.tr(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Crop and Retake buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: OutlinedButton(
                                  onPressed: () => viewModel.cropImage(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.crop,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'photo_detail.crop'.tr(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: OutlinedButton(
                                  onPressed: () => viewModel.retake(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'photo_detail.retake'.tr(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}