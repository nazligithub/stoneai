import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'stone_loading_viewmodel.dart';
import '../../constants/crystal_colors.dart';

class StoneLoadingView extends StatelessWidget {
  final String imagePath;
  
  const StoneLoadingView({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneLoadingViewModel(imagePath)..startScanning(),
      child: const _StoneLoadingViewContent(),
    );
  }
}

class _StoneLoadingViewContent extends StatelessWidget {
  const _StoneLoadingViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoneLoadingViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false, // Prevent back navigation
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      const Color(0xFF0D1117),
                      Colors.black,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header spacing
                    SizedBox(height: 60.h),
                    
                    // Diamond Animation
                    SizedBox(
                      width: 280.w,
                      height: 280.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 250.w,
                            height: 250.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  CrystalColors.primaryBlue.withValues(alpha: 0.3),
                                  CrystalColors.primaryBlue.withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Lottie Animation - Larger size
                          Lottie.asset(
                            'assets/animations/Diamond.json',
                            width: 240.w,
                            height: 240.h,
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Loading Text
                    Text(
                      'stone_loading.analyzing'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Progress indicator
                    Container(
                      width: 200.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: 200.w * viewModel.progress,
                            height: 4.h,
                            decoration: BoxDecoration(
                              gradient: CrystalColors.crystalTabGradient,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Status Text
                    Text(
                      'stone_loading.duration_warning'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 60.h),
                    
                    // Error message if any
                    if (viewModel.error != null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'stone_loading.error_title'.tr(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              viewModel.error!,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.red.withValues(alpha: 0.9),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => viewModel.retryScanning(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.red, width: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: Text(
                                      'stone_loading.retry'.tr(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => viewModel.goBack(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: Text(
                                      'stone_loading.go_back'.tr(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    // AI Tips
                    if (viewModel.error == null)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: CrystalColors.primaryBlue.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: CrystalColors.primaryBlue,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'stone_loading.ai_tip'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}