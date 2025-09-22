import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'stone_home_viewmodel.dart';
import '../../widgets/stone_card_horizontal.dart';
import '../../constants/stone_routes.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../viewmodels/stone_app_provider.dart';

class StoneHomeView extends StatelessWidget {
  const StoneHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneHomeViewModel()..loadHomeData(),
      child: const _StoneHomeViewContent(),
    );
  }
}

class _StoneHomeViewContent extends StatefulWidget {
  const _StoneHomeViewContent();

  @override
  State<_StoneHomeViewContent> createState() => _StoneHomeViewContentState();
}

class _StoneHomeViewContentState extends State<_StoneHomeViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen to keyboard visibility changes
      WidgetsBinding.instance.addObserver(_KeyboardVisibilityObserver(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoneHomeViewModel, StoneAppProvider>(
      builder: (context, homeViewModel, appProvider, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside
              FocusScope.of(context).unfocus();
              homeViewModel.setKeyboardVisible(false);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: CustomScrollView(
                slivers: [
                  // App Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gemstone ID',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: CrystalColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'home.subtitle'.tr(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: CrystalColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // PRO and Settings buttons aligned with title
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: appProvider.isPremiumUser ? null : () {
                                  StoneNavigationHelper.goToPaywall();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: appProvider.isPremiumUser ? [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ] : [
                                        CrystalColors.primaryBlue,
                                        Colors.black,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '👑',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'PRO',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: CrystalColors.textSecondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    StoneNavigationHelper.navigateTo(StoneRoutes.gemSettings);
                                  },
                                  icon: Icon(
                                    Icons.settings,
                                    color: CrystalColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Crystal Expert Assistant Card - Redesigned
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 0),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CrystalColors.primaryBlue,
                              Colors.black,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: CrystalColors.primaryBlue.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'home.crystal_expert_title'.tr(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'home.crystal_expert_subtitle'.tr(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: TextField(
                                controller: homeViewModel.questionController,
                                autofocus: false,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'home.ask_question'.tr(),
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  suffixIcon: IconButton(
                                    onPressed: homeViewModel.submitQuestion,
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      size: 18.sp,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => homeViewModel.submitQuestion(),
                                onTap: () {
                                  homeViewModel.setKeyboardVisible(true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Scan Rock Identifier Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                      child: GestureDetector(
                        onTap: () {
                          homeViewModel.navigateToCamera();
                        },
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CrystalColors.primaryBlue,
                                Colors.black,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: CrystalColors.primaryBlue.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.asset(
                                    'assets/scan_Rock.png',
                                    width: 50.w,
                                    height: 50.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'home.scan_rock'.tr(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'home.identify_stones'.tr(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Featured Crystals Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
                      child: Text(
                        'home.featured_crystals'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: CrystalColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Featured Crystals - Horizontal List
                  if (homeViewModel.isLoading)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: CrystalColors.primaryBlue,
                          ),
                        ),
                      ),
                    )
                  else if (homeViewModel.hasError)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200.h,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: CrystalColors.textSecondary,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                homeViewModel.error ?? 'home.error'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: CrystalColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 220.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: homeViewModel.featuredStones.length,
                          itemBuilder: (context, index) {
                            final stone = homeViewModel.featuredStones[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 16.w),
                              child: StoneCardHorizontal(
                                stone: stone,
                                onTap: () => homeViewModel.navigateToStoneDetail(stone.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Bottom padding for navigation bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100.h),
                  ),
                ],
                ),
              ),
              floatingActionButton: homeViewModel.isKeyboardVisible ? null : Consumer<StoneAppProvider>(
              builder: (context, appProvider, child) {
                return FloatingActionButton(
                  heroTag: "home_fab",
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    if (!mounted) return;
                    appProvider.setTabIndex(1);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CrystalColors.crystalTabGradient,
                      boxShadow: [
                        BoxShadow(
                          color: CrystalColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: appProvider.selectedTabIndex == 1 ? 28 : 24,
                    ),
                  ),
                );
              },
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            ),
          ),
        );
      },
    );
  }
}

class _KeyboardVisibilityObserver extends WidgetsBindingObserver {
  final BuildContext context;

  _KeyboardVisibilityObserver(this.context);

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    if (context.mounted) {
      final homeViewModel = Provider.of<StoneHomeViewModel>(context, listen: false);
      homeViewModel.setKeyboardVisible(isKeyboardVisible);
    }
  }
}