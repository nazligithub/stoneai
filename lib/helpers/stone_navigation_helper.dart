import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/stone_routes.dart';
import '../viewmodels/stone_app_provider.dart';
import '../views/paywall/paywall_view.dart';
import '../views/ai_chat/ai_chat_view.dart';

class StoneNavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  // Safe navigation helper that checks if navigator is available
  static bool get isNavigatorReady => navigatorKey.currentState != null;
  
  // Basic navigation with safety checks
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return Future.value(null);
    }
    try {
      return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return Future.value(null);
    }
  }

  static Future<T?> replaceWith<T extends Object?>(String routeName, {Object? arguments}) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return Future.value(null);
    }
    try {
      return navigatorKey.currentState!.pushReplacementNamed<T, T>(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return Future.value(null);
    }
  }

  static void goBack<T>([T? result]) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return;
    }
    try {
      if (canGoBack()) {
        navigatorKey.currentState!.pop<T>(result);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  static Future<T?> navigateAndClearStack<T>(String routeName, {Object? arguments}) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return Future.value(null);
    }
    try {
      return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return Future.value(null);
    }
  }

  // App-specific navigation methods
  static Future<void> goToMainTabsAndClearStack() async {
    // Complete onboarding when navigating to main tabs
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
        if (!appProvider.isOnboardingCompleted) {
          await appProvider.completeOnboarding();
        }
      } catch (e) {
        debugPrint('Error completing onboarding: $e');
      }
    }
    
    return navigateAndClearStack(StoneRoutes.mainTabs);
  }

  static Future<void> goToOnboardingAndClearStack() {
    return navigateAndClearStack(StoneRoutes.onboarding);
  }

  static Future<void> goToStoneHome() {
    return navigateTo(StoneRoutes.stoneHome);
  }

  static Future<void> goToCrystalDiscover() {
    return navigateTo(StoneRoutes.crystalDiscover);
  }

  static Future<void> goToRockProfile() {
    return navigateTo(StoneRoutes.rockProfile);
  }

  static Future<void> goToGemSettings() {
    return navigateTo(StoneRoutes.gemSettings);
  }

  static Future<void> goToStoneDetail({required String stoneId, Object? extraData}) {
    return navigateTo(
      StoneRoutes.stoneDetail,
      arguments: {'stoneId': stoneId, 'extraData': extraData},
    );
  }

  static Future<void> goToExploreDetail({required String stoneId}) {
    return navigateTo(
      StoneRoutes.exploreDetail,
      arguments: {'stoneId': stoneId},
    );
  }

  static Future<void> goToPaywall({bool isFromOnboarding = false}) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return Future.value();
    }
    try {
      return navigatorKey.currentState!.push<void>(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PaywallView(),
          fullscreenDialog: true,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: RouteSettings(
            name: StoneRoutes.paywall,
            arguments: {'isFromOnboarding': isFromOnboarding},
          ),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return Future.value();
    }
  }

  static Future<void> goToRating() {
    return navigateTo(StoneRoutes.rating);
  }

  static Future<void> goToAIChat() {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return Future.value();
    }
    try {
      return navigatorKey.currentState!.push<void>(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AIChatView(),
          fullscreenDialog: true,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: RouteSettings(
            name: StoneRoutes.aiChat,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return Future.value();
    }
  }

  static Future<void> goToPhotoDetail({required String imagePath}) {
    return navigateTo(StoneRoutes.photoDetail, arguments: imagePath);
  }

  // Modal and bottom sheet helpers with safety checks
  static Future<T?> showRockModalBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    if (context == null) {
      debugPrint('Modal failed: Context not available');
      return Future.value(null);
    }
    try {
      return showModalBottomSheet<T>(
        context: context!,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        backgroundColor: Colors.transparent,
        builder: (context) => child,
      );
    } catch (e) {
      debugPrint('Modal error: $e');
      return Future.value(null);
    }
  }

  static Future<T?> showCrystalDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    if (context == null) {
      debugPrint('Dialog failed: Context not available');
      return Future.value(null);
    }
    try {
      return showDialog<T>(
        context: context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    } catch (e) {
      debugPrint('Dialog error: $e');
      return Future.value(null);
    }
  }

  // Utility methods
  static bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  static void popUntilRoute(String routeName) {
    if (!isNavigatorReady) {
      debugPrint('Navigation failed: Navigator not ready');
      return;
    }
    try {
      navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
  
  // Tab-specific navigation helpers
  static void navigateToTab(int tabIndex) {
    // This will be handled by the main navigation provider
    debugPrint('Navigate to tab: $tabIndex');
  }
  
  // Safe context-based navigation for widgets that have context
  static Future<T?> navigateWithContext<T>(BuildContext context, String routeName, {Object? arguments}) {
    try {
      return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('Context navigation error: $e');
      return Future.value(null);
    }
  }
  
  static void goBackWithContext(BuildContext context, [dynamic result]) {
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      debugPrint('Context navigation error: $e');
    }
  }
}