import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../helpers/stone_navigation_helper.dart';

class StoneOnboardOneViewModel extends ChangeNotifier {
  String get title => 'onboard.step1.title'.tr();
  String get subtitle => 'onboard.step1.subtitle'.tr();
  String get buttonTitle => 'onboard.step1.button'.tr();
  String get detectedStone => 'onboard.step1.detected_stone'.tr();
  String get stoneStatus => 'onboard.step1.stone_status'.tr();

  void onContinue() {
    HapticFeedback.mediumImpact();
    StoneNavigationHelper.navigatorKey.currentState?.pushReplacementNamed('/stone-onboard-two');
  }
}