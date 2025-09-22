import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../constants/crystal_colors.dart';
import '../stone_home/stone_home_view.dart';
import '../stone_history/stone_history_view.dart';
import '../camera_capture/stone_camera_view.dart';

class CrystalMainNavigationView extends StatefulWidget {
  const CrystalMainNavigationView({super.key});

  @override
  State<CrystalMainNavigationView> createState() => _CrystalMainNavigationViewState();
}

class _CrystalMainNavigationViewState extends State<CrystalMainNavigationView>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;

  final List<IconData> iconList = [
    Icons.home_rounded,
    Icons.history_rounded,
  ];

  List<String> get tabLabels => [
    'navigation.home'.tr(),
    'navigation.history'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(borderRadiusCurve);

    _fabAnimationController.forward();
    _borderRadiusAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _borderRadiusAnimationController.dispose();
    super.dispose();
  }

  Widget _buildTabView(int index) {
    switch (index) {
      case 0:
        return StoneHomeView(); // Home tab
      case 1:
        return StoneCameraView(); // Camera tab (floating button'dan erişilir)
      case 2:
        return StoneHistoryView(); // History tab
      default:
        return StoneHomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoneAppProvider>(
      builder: (context, appProvider, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: appProvider.selectedTabIndex == 2 ? 1 : appProvider.selectedTabIndex,
            sizing: StackFit.expand,
            children: [
              _buildTabView(0), // Home
              appProvider.selectedTabIndex == 2 ? _buildTabView(2) : _buildTabView(1), // History or Camera
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: AnimatedBottomNavigationBar.builder(
              itemCount: iconList.length,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.softEdge,
              tabBuilder: (int index, bool isActive) {
                // Manual control for active state
                bool manualActive = false;
                if (index == 0 && (appProvider.selectedTabIndex == 0 || appProvider.selectedTabIndex == 1)) {
                  manualActive = appProvider.selectedTabIndex == 0; // Only Home tab should be active, not camera
                } else if (index == 1 && appProvider.selectedTabIndex == 2) {
                  manualActive = true; // History tab
                }
                
                final color = manualActive 
                    ? CrystalColors.primaryBlue
                    : CrystalColors.textSecondary;
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconList[index],
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabLabels[index],
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 11,
                        fontWeight: manualActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
              backgroundColor: Colors.white,
              activeIndex: appProvider.selectedTabIndex == 0 ? 0 : (appProvider.selectedTabIndex == 2 ? 1 : -1),
              splashColor: Colors.transparent,
              splashSpeedInMilliseconds: 0,
              leftCornerRadius: 0,
              rightCornerRadius: 0,
              onTap: (index) {
                if (!mounted) return; // Fix unmounted widget error
                final realIndex = index == 0 ? 0 : 2;
                if (realIndex == appProvider.selectedTabIndex) {
                  // If same tab is tapped, trigger scroll to top
                  appProvider.requestTabScroll(realIndex);
                } else {
                  appProvider.setTabIndex(realIndex);
                  // Notify history tab to reload when selected
                  if (realIndex == 2) {
                    appProvider.notifyHistoryTabSelected();
                  }
                }
              },
              shadow: BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 12,
                spreadRadius: 0.5,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              if (!mounted) return; // Fix unmounted widget error
              // Camera tab'a geçiş yap
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
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
        );
      },
    );
  }
}