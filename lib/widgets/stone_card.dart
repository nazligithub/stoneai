import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/stone_model.dart';
import '../constants/crystal_colors.dart';

class StoneCard extends StatelessWidget {
  final StoneModel stone;
  final VoidCallback onTap;

  const StoneCard({
    super.key,
    required this.stone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E2E),
              const Color(0xFF181825),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getStoneColor(stone.color).withValues(alpha: 0.25),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: -3.r,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 15.r,
              offset: Offset(0, 4.h),
              spreadRadius: -2.r,
            ),
          ],
          border: Border.all(
            color: _getStoneColor(stone.color).withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with enhanced styling
            Expanded(
              flex: 7,
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        stone.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  _getStoneColor(stone.color).withValues(alpha: 0.4),
                                  _getStoneColor(stone.color).withValues(alpha: 0.2),
                                  const Color(0xFF11111B),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2E).withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getStoneColor(stone.color).withValues(alpha: 0.5),
                                    width: 2.w,
                                  ),
                                ),
                                child: Icon(
                                  Icons.diamond_outlined,
                                  size: 24.sp,
                                  color: _getStoneColor(stone.color),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Enhanced gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                            stops: const [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                      // Subtle shine effect
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                _getStoneColor(stone.color).withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Enhanced content area
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        stone.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStoneColor(stone.color).withValues(alpha: 0.3),
                            _getStoneColor(stone.color).withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: _getStoneColor(stone.color).withValues(alpha: 0.2),
                            blurRadius: 4.r,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Text(
                        stone.category,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStoneColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'clear':
      case 'white':
      case 'colorless to various colors':
        return CrystalColors.crystalWhite;
      case 'purple':
        return Colors.purple;
      case 'blue':
      case 'blue (most common), various colors':
        return CrystalColors.primaryBlue;
      case 'green':
      case 'green to red':
        return CrystalColors.gemGreen;
      case 'red':
        return CrystalColors.rubyRed;
      case 'yellow':
      case 'gold':
        return CrystalColors.amberGold;
      case 'brown':
        return CrystalColors.rockBrown;
      case 'gray':
      case 'grey':
        return CrystalColors.stoneGray;
      case 'wide variety of colors':
        return Colors.deepPurple;
      default:
        return CrystalColors.primaryBlue;
    }
  }
}