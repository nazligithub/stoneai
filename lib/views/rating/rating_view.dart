import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rating_viewmodel.dart';
import '../../constants/crystal_colors.dart';

class RatingView extends StatefulWidget {
  const RatingView({super.key});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RatingViewModel(),
      child: Consumer<RatingViewModel>(
        builder: (context, viewModel, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    const Color(0xFF4A90A4).withValues(alpha: 0.3),
                    Colors.black,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      // Title
                      Text(
                        'rating.title'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'rating.subtitle'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Lottie animation
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SizedBox(
                                  width: 300.w,
                                  height: 300.h,
                                  child: Lottie.asset(
                                    'assets/rockify_rating.json',
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Rated button
                      AnimatedOpacity(
                        opacity: viewModel.showRatedButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: viewModel.showRatedButton ? 40.h : 0,
                          child: TextButton(
                            onPressed: viewModel.showRatedButton
                                ? viewModel.onRatedButtonTapped
                                : null,
                            child: Text(
                              'rating.rated'.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A90A4),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Leave rating button
                      SizedBox(
                        width: double.infinity,
                        height: 60.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: CrystalColors.crystalTabGradient,
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: ElevatedButton(
                            onPressed: viewModel.showRatedButton
                                ? viewModel.onRatedButtonTapped
                                : viewModel.onLeaveRating,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              viewModel.showRatedButton
                                  ? 'rating.continue'.tr()
                                  : 'rating.button'.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}