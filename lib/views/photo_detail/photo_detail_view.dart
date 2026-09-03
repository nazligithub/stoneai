import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/crystal_colors.dart';
import 'photo_detail_viewmodel.dart';

class PhotoDetailView extends StatelessWidget {
  final String imagePath;

  const PhotoDetailView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotoDetailViewModel(imagePath),
      child: const _PhotoDetailViewContent(),
    );
  }
}

class _PhotoDetailViewContent extends StatelessWidget {
  const _PhotoDetailViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoDetailViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1320),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 82.h, 16.w, 230.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF121E2E),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: viewModel.displayImagePath != null
                          ? Image.file(
                              File(viewModel.displayImagePath!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImageFallback();
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                color: CrystalColors.primaryLight,
                                strokeWidth: 2.5,
                              ),
                            ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Review your photo before identification',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.62),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundIconButton(
                        icon: Icons.auto_awesome_rounded,
                        onPressed: viewModel.isProcessing
                            ? null
                            : () => viewModel.startScan(context),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (viewModel.error != null) ...[
                          _ErrorBanner(message: viewModel.error!),
                          SizedBox(height: 12.h),
                        ],
                        Text(
                          'Ready to identify?',
                          style: GoogleFonts.poppins(
                            color: CrystalColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Make sure the stone is visible and well lit.',
                          style: GoogleFonts.poppins(
                            color: CrystalColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 54.h,
                          child: DecoratedBox(
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
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: viewModel.isProcessing
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'photo_detail.start_scan'.tr(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: viewModel.cropImage,
                                icon: Icon(Icons.crop_rounded, size: 18.sp),
                                label: Text('photo_detail.crop'.tr()),
                                style: _secondaryButtonStyle(),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: viewModel.retake,
                                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                                label: Text('photo_detail.retake'.tr()),
                                style: _secondaryButtonStyle(),
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

  Widget _buildImageFallback() {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white.withValues(alpha: 0.55),
        size: 42.sp,
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: CrystalColors.primaryBlue,
      side: BorderSide(
        color: CrystalColors.primaryBlue.withValues(alpha: 0.18),
      ),
      minimumSize: Size.fromHeight(46.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      textStyle: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20.sp),
        tooltip: null,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: CrystalColors.rubyRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: CrystalColors.rubyRed.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: CrystalColors.rubyRed,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: CrystalColors.rubyRed,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
