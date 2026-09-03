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
              backgroundColor: CrystalColors.background,
              body: Container(
                // Warm limestone wash across the top of the page
                decoration: const BoxDecoration(
                  gradient: CrystalColors.pageGradient,
                ),
                child: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                          child: _Header(appProvider: appProvider),
                        ),
                      ),

                      // The scan is the primary action, so it leads the page.
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 0),
                          child: _ScanCard(
                            onTap: () =>
                                homeViewModel.navigateToCamera(context),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                          child: _ExpertCard(viewModel: homeViewModel),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 14.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  'home.featured_crystals'.tr(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    color: CrystalColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                'home.see_all'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: CrystalColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (homeViewModel.isLoading)
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 200.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: CrystalColors.accent,
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
                                    size: 44.sp,
                                    color: CrystalColors.textTertiary,
                                  ),
                                  SizedBox(height: 14.h),
                                  Text(
                                    homeViewModel.error ?? 'home.error'.tr(),
                                    textAlign: TextAlign.center,
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
                                final stone =
                                    homeViewModel.featuredStones[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: StoneCardHorizontal(
                                    stone: stone,
                                    onTap: () => homeViewModel
                                        .navigateToStoneDetail(stone.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Clearance for the navigation bar and its scan button
                      SliverToBoxAdapter(child: SizedBox(height: 132.h)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appProvider});

  final StoneAppProvider appProvider;

  @override
  Widget build(BuildContext context) {
    final isPremium = appProvider.isPremiumUser;
    final pillColor =
        isPremium ? CrystalColors.amberGold : CrystalColors.accent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gemstone ID',
                style: GoogleFonts.poppins(
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 1.05,
                  color: CrystalColors.textPrimary,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'home.subtitle'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: CrystalColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isPremium
                    ? null
                    : () => StoneNavigationHelper.goToPaywall(),
                child: Container(
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: pillColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: pillColor.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 14.sp,
                        color: pillColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'PRO',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: pillColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () =>
                    StoneNavigationHelper.navigateTo(StoneRoutes.gemSettings),
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: CrystalColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: CrystalColors.hairline),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 17.sp,
                    color: CrystalColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dark card is the one heavy block on a light page, so the eye lands on
/// the scan before anything else. Copper is reserved for this action alone.
class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 12.w, 20.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A231D), Color(0xFF191411)],
          ),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.inkDark.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home.scan_rock'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.15,
                      color: const Color(0xFFFBF3E9),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'home.identify_stones'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFA99684),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    height: 38.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: CrystalColors.accentAction,
                      borderRadius: BorderRadius.circular(19.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_rounded,
                          size: 16.sp,
                          color: const Color(0xFFFFF6EE),
                        ),
                        SizedBox(width: 7.w),
                        Text(
                          'home.open_camera'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFF6EE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(
              'assets/scan_Rock.png',
              width: 104.w,
              height: 104.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.viewModel});

  final StoneHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: CrystalColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: CrystalColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: CrystalColors.accentSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 19.sp,
                  color: CrystalColors.accent,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.crystal_expert_title'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: CrystalColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'home.crystal_expert_subtitle'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: CrystalColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: CrystalColors.surfaceAlt,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.questionController,
                    autofocus: false,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: CrystalColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'home.ask_question'.tr(),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w400,
                        color: CrystalColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(14.w, 13.h, 8.w, 13.h),
                    ),
                    onSubmitted: (_) => viewModel.submitQuestion(),
                    onTap: () => viewModel.setKeyboardVisible(true),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: GestureDetector(
                    onTap: viewModel.submitQuestion,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: CrystalColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      final homeViewModel = Provider.of<StoneHomeViewModel>(
        context,
        listen: false,
      );
      homeViewModel.setKeyboardVisible(isKeyboardVisible);
    }
  }
}
