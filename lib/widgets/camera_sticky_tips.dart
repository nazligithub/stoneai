import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/crystal_colors.dart';

class CameraStickyTips extends StatefulWidget {
  const CameraStickyTips({super.key});

  @override
  State<CameraStickyTips> createState() => _CameraStickyTipsState();
}

class _CameraStickyTipsState extends State<CameraStickyTips>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  
  List<CameraTip> get _tips => [
    CameraTip(
      imagePath: 'assets/sticky/1.png',
      title: 'camera.tips.tip1.title'.tr(),
      subtitle: 'camera.tips.tip1.subtitle'.tr(),
      iconColor: Colors.red,
      icon: Icons.warning_amber_rounded,
    ),
    CameraTip(
      imagePath: 'assets/sticky/2.png',
      title: 'camera.tips.tip2.title'.tr(),
      subtitle: 'camera.tips.tip2.subtitle'.tr(),
      iconColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
    ),
    CameraTip(
      imagePath: 'assets/sticky/3.png',
      title: 'camera.tips.tip3.title'.tr(),
      subtitle: 'camera.tips.tip3.subtitle'.tr(),
      iconColor: Colors.green,
      icon: Icons.check_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
  }

  void _nextTip() {
    if (_currentIndex < _tips.length - 1) {
      setState(() {
        _currentIndex++;
      });
      
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousTip() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showTipsModal(BuildContext context) {
    // Reset to first tip every time modal opens
    setState(() {
      _currentIndex = 0;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    
                    // Header
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'camera.tips.title'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    SizedBox(
                      height: 400.h,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _tips.length,
                        onPageChanged: (index) {
                          setModalState(() {
                            _currentIndex = index;
                          });
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final tip = _tips[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Status with icon
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: tip.iconColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        tip.icon,
                                        color: tip.iconColor,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        tip.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: tip.iconColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                
                                // Image
                                Container(
                                  height: 250.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Image.asset(
                                      tip.imagePath,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                
                                // Subtitle
                                Text(
                                  tip.subtitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Dots indicator only
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _tips.length,
                          (index) => Container(
                            width: 8.w,
                            height: 8.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? _tips[_currentIndex].iconColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Button
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      child: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: CrystalColors.crystalTabGradient,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'camera.tips.buttons.got_it'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, top: 8.h),
      child: _buildCollapsedButton(),
    );
  }

  Widget _buildCollapsedButton() {
    return GestureDetector(
      onTap: () {
        _showTipsModal(context);
      },
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.info_outline,
          color: Colors.grey.shade700,
          size: 20.sp,
        ),
      ),
    );
  }

}

class CameraTip {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color iconColor;
  final IconData icon;

  CameraTip({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.icon,
  });
}