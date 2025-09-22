import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../helpers/stone_navigation_helper.dart';
import '../../providers/remote_config_provider.dart';

class StoneItem {
  final String name;
  final String iconPath;
  final String stoneStatus;
  final String type;
  final Color color;

  StoneItem({
    required this.name,
    required this.iconPath,
    required this.stoneStatus,
    required this.type,
    required this.color,
  });
}

class StoneOnboardTwoViewModel extends ChangeNotifier {
  String get title => 'onboard.step2.title'.tr();
  String get subtitle => 'onboard.step2.subtitle'.tr();
  String get buttonTitle => 'onboard.step2.button'.tr();

  List<StoneItem> get stones => [
    StoneItem(
      name: 'onboard.step2.stones.amethyst'.tr(),
      iconPath: 'assets/onboards/onboard_2/1.png',
      stoneStatus: 'onboard.step2.detected'.tr(),
      type: 'onboard.step2.stone_types.purple_crystal'.tr(),
      color: Color(0xFF9B59B6),
    ),
    StoneItem(
      name: 'onboard.step2.stones.lapis_lazuli'.tr(),
      iconPath: 'assets/onboards/onboard_2/2.png',
      stoneStatus: 'onboard.step2.detected'.tr(),
      type: 'onboard.step2.stone_types.wisdom_stone'.tr(),
      color: Color(0xFF3498DB),
    ),
    StoneItem(
      name: 'onboard.step2.stones.emerald'.tr(),
      iconPath: 'assets/onboards/onboard_2/3.png',
      stoneStatus: 'onboard.step2.detected'.tr(),
      type: 'onboard.step2.stone_types.green_crystal'.tr(),
      color: Color(0xFF27AE60),
    ),
    StoneItem(
      name: 'onboard.step2.stones.dioptase'.tr(),
      iconPath: 'assets/onboards/onboard_2/4.png',
      stoneStatus: 'onboard.step2.detected'.tr(),
      type: 'onboard.step2.stone_types.healing_stone'.tr(),
      color: Color(0xFF16A085),
    ),
  ];

  void onContinue(BuildContext context) async {
    HapticFeedback.mediumImpact();

    // Check remote config for rating screen
    final remoteConfig = Provider.of<RemoteConfigProvider>(context, listen: false);

    // Wait for config to load if still loading
    if (remoteConfig.isLoading) {
      debugPrint('⏳ Waiting for remote config to load...');
      // Show loading indicator or wait briefly
      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint('🎯 Remote Config Check:');
    debugPrint('showRatingScreen: ${remoteConfig.showRatingScreen}');
    debugPrint('isLoading: ${remoteConfig.isLoading}');

    if (remoteConfig.showRatingScreen) {
      debugPrint('✅ Navigating to Rating Screen');
      StoneNavigationHelper.goToRating();
    } else {
      debugPrint('❌ Navigating to Paywall (Rating disabled)');
      StoneNavigationHelper.goToPaywall(isFromOnboarding: true);
    }
  }
}