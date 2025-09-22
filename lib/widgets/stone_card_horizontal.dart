import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/stone_model.dart';

class StoneCardHorizontal extends StatelessWidget {
  final StoneModel stone;
  final VoidCallback onTap;

  const StoneCardHorizontal({
    super.key,
    required this.stone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
              spreadRadius: -3.r,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.4),
            width: 1.5.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              flex: 7,
              child: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
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
                                  Color(0xFF0A0A0A),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF087F5B).withValues(alpha: 0.8),
                                      Color(0xFF065E3C).withValues(alpha: 0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.diamond_outlined,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Shine effect
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 16.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                _getStoneColor(stone.color).withValues(alpha: 0.4),
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
            // Content area
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stone.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.1,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        stone.category,
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
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
        return Colors.white;
      case 'purple':
        return Colors.purple;
      case 'blue':
      case 'blue (most common), various colors':
        return Colors.blue;
      case 'green':
      case 'green to red':
        return Color(0xFF087F5B); // Emerald green
      case 'red':
        return Colors.red;
      case 'yellow':
      case 'gold':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'wide variety of colors':
        return Colors.deepPurple;
      default:
        return Color(0xFF087F5B); // Default emerald
    }
  }
}