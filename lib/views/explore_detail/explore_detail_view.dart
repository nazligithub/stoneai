import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'explore_detail_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../models/stone_model.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../constants/app_shadows.dart';

class ExploreDetailView extends StatelessWidget {
  final String stoneId;

  const ExploreDetailView({super.key, required this.stoneId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExploreDetailViewModel()..initialize(stoneId),
      child: const _ExploreDetailViewContent(),
    );
  }
}

class _ExploreDetailViewContent extends StatelessWidget {
  const _ExploreDetailViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ExploreDetailViewModel>(
      builder: (context, detailViewModel, child) {
        if (detailViewModel.isLoading) {
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final stone = detailViewModel.stone;
        if (stone == null) {
          return Scaffold(body: const Center(child: Text('Stone not found')));
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                onPressed: () {
                  StoneNavigationHelper.goBack();
                },
              ),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: _buildContent(stone),
        );
      },
    );
  }

  Widget _buildContent(StoneModel stone) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stone Image Hero Section with Name Overlay
          Container(
            width: double.infinity,
            height: 350.h,
            decoration: BoxDecoration(color: const Color(0xFF1E1E2E)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Stone Image
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
                            Colors.grey.withValues(alpha: 0.4),
                            Colors.grey.withValues(alpha: 0.2),
                            const Color(0xFF11111B),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 60.sp,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay for better text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Stone name centered at bottom
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: Text(
                    stone.name,
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2.h),
                          blurRadius: 8.r,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Content with padding
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                _buildCard(
                  icon: '📖',
                  title: 'explore_detail.description'.tr(),
                  content: _buildDescription(stone.id),
                ),
                SizedBox(height: 16.h),

                // Basic Identity
                _buildCard(
                  icon: '🔮',
                  title: 'explore_detail.basic_identity'.tr(),
                  content: _buildCoreIdentity(stone.id),
                ),
                SizedBox(height: 16.h),

                // Spiritual Properties
                if (_buildSpiritualProperties(stone.id).isNotEmpty) ...[
                  _buildCard(
                    icon: '✨',
                    title: 'explore_detail.spiritual_properties'.tr(),
                    content: _buildSpiritualProperties(stone.id),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Physical Beliefs
                if (_buildPhysicalBeliefs(stone.id).isNotEmpty) ...[
                  _buildCard(
                    icon: '🩺',
                    title: 'explore_detail.physical_beliefs'.tr(),
                    content: _buildPhysicalBeliefs(stone.id),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Collection Tips
                if (_buildCollectionTips(stone.id).isNotEmpty) ...[
                  _buildCard(
                    icon: '💎',
                    title: 'explore_detail.collection_tips'.tr(),
                    content: _buildCollectionTips(stone.id),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Localities
                if (_buildLocalities(stone.id).isNotEmpty) ...[
                  _buildCard(
                    icon: '🌍',
                    title: 'Localities',
                    content: _buildLocalities(stone.id),
                  ),
                  SizedBox(height: 16.h),
                ],

                // FAQs
                if (_buildFAQs(stone.id).isNotEmpty) ...[
                  _buildCard(
                    icon: '❓',
                    title: 'explore_detail.faqs'.tr(),
                    content: _buildFAQs(stone.id),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Disclaimer
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'explore_detail.disclaimer'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: CrystalColors.primaryBlue.withValues(alpha: 0.07),
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: CrystalColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: CrystalColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _getSpiritualTheme(String stoneId) {
    switch (stoneId) {
      case 'emerald':
        return 'explore_detail.stones.emerald.spiritual_theme'.tr();
      case 'diamond':
        return 'explore_detail.stones.diamond.spiritual_theme'.tr();
      case 'ruby':
        return 'explore_detail.stones.ruby.spiritual_theme'.tr();
      case 'sapphire':
        return 'explore_detail.stones.sapphire.spiritual_theme'.tr();
      case 'alexandrite':
        return 'explore_detail.stones.alexandrite.spiritual_theme'.tr();
      case 'tourmaline':
        return 'explore_detail.stones.tourmaline.spiritual_theme'.tr();
      default:
        return '';
    }
  }

  String _buildCollectionTips(String stoneId) {
    return 'explore_detail.stones.$stoneId.collectors_insight'.tr();
  }

  String _buildSpiritualProperties(String stoneId) {
    return 'explore_detail.stones.$stoneId.spiritual_properties'.tr();
  }

  String _buildPhysicalBeliefs(String stoneId) {
    return 'explore_detail.stones.$stoneId.physical_beliefs'.tr();
  }

  String _buildFAQs(String stoneId) {
    return 'explore_detail.stones.$stoneId.faqs'.tr();
  }

  String _buildDescription(String stoneId) {
    return 'explore_detail.stones.$stoneId.description'.tr();
  }

  String _buildCoreIdentity(String stoneId) {
    return 'explore_detail.stones.$stoneId.core_identity'.tr();
  }

  String _buildLocalities(String stoneId) {
    return 'explore_detail.stones.$stoneId.localities'.tr();
  }
}
