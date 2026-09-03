import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:easy_localization/easy_localization.dart';

import 'viewmodels/stone_app_provider.dart';
import 'providers/remote_config_provider.dart';
import 'helpers/stone_storage_helper.dart';
import 'helpers/stone_navigation_helper.dart';
import 'helpers/revenue_cat_helper.dart';
import 'services/supabase_service.dart';
import 'constants/stone_routes.dart';
import 'constants/crystal_colors.dart';
import 'views/main_navigation/crystal_main_navigation_view.dart';
import 'views/stone_detail/stone_detail_view.dart';
import 'views/explore_detail/explore_detail_view.dart';
import 'views/paywall/paywall_view.dart';
import 'views/ai_chat/ai_chat_view.dart';
import 'views/photo_detail/photo_detail_view.dart';
import 'views/stone_loading/stone_loading_view.dart';
import 'views/stone_onboard_one/stone_onboard_one_view.dart';
import 'views/stone_onboard_one/stone_onboard_one_viewmodel.dart';
import 'views/stone_onboard_two/stone_onboard_two_view.dart';
import 'views/stone_onboard_two/stone_onboard_two_viewmodel.dart';
import 'views/stone_settings/stone_settings_view.dart';
import 'views/stone_settings/stone_settings_viewmodel.dart';
import 'views/rating/rating_view.dart';
import 'models/stone_scan_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize storage
  await GetStorage.init();
  await StoneStorageHelper().init();

  // Initialize RevenueCat
  await RevenueCatHelper.shared.init();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
        Locale('fr'),
        Locale('ja'),
        Locale('ko'),
        Locale('pt'),
        Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const GemstoneIDApp(),
    ),
  );
}

class GemstoneIDApp extends StatelessWidget {
  const GemstoneIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => StoneAppProvider()..initializeApp(),
            ),
            ChangeNotifierProvider(create: (_) => RemoteConfigProvider()),
          ],
          child: Consumer<StoneAppProvider>(
            builder: (context, appProvider, child) {
              return MaterialApp(
                title: 'Rock & Stone Identifier',
                debugShowCheckedModeBanner: false,
                navigatorKey: StoneNavigationHelper.navigatorKey,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                themeMode: appProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: appProvider.isAppLoading
                    ? const GemstoneIDSplashScreen()
                    : appProvider.isOnboardingCompleted
                    ? const CrystalMainNavigationView()
                    : ChangeNotifierProvider(
                        create: (_) => StoneOnboardOneViewModel(),
                        child: const StoneOnboardOneView(),
                      ),
                routes: _buildRoutes(),
              );
            },
          ),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: CrystalColors.primaryBlue,
      scaffoldBackgroundColor: const Color(0xFFF5F8FB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: CrystalColors.primaryBlue,
        brightness: Brightness.light,
        surface: const Color(0xFFF5F8FB),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF5F8FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CrystalColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: CrystalColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: CrystalColors.primaryBlue.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CrystalColors.primaryLight,
            width: 1.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: CrystalColors.primaryDark,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CrystalColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: CrystalColors.primaryBlue,
      scaffoldBackgroundColor: CrystalColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CrystalColors.primaryBlue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: CrystalColors.backgroundDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CrystalColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      StoneRoutes.stoneOnboardOne: (context) => ChangeNotifierProvider(
        create: (_) => StoneOnboardOneViewModel(),
        child: const StoneOnboardOneView(),
      ),
      StoneRoutes.stoneOnboardTwo: (context) => ChangeNotifierProvider(
        create: (_) => StoneOnboardTwoViewModel(),
        child: const StoneOnboardTwoView(),
      ),
      StoneRoutes.mainTabs: (context) => const CrystalMainNavigationView(),
      StoneRoutes.stoneDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments;

        if (args is Map<String, dynamic>) {
          // API response data
          return StoneDetailView(
            stoneId: args['stoneId'] as String?,
            apiStoneData: args['stoneData'] as StoneDetails?,
            imageUrl: args['imageUrl'] as String?,
          );
        } else {
          // Legacy string stoneId
          return StoneDetailView(stoneId: args as String);
        }
      },
      StoneRoutes.exploreDetail: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ExploreDetailView(stoneId: args['stoneId'] as String);
      },
      StoneRoutes.paywall: (context) => const PaywallView(),
      StoneRoutes.rating: (context) => const RatingView(),
      StoneRoutes.aiChat: (context) => const AIChatView(),
      StoneRoutes.photoDetail: (context) {
        final imagePath = ModalRoute.of(context)!.settings.arguments as String;
        return PhotoDetailView(imagePath: imagePath);
      },
      StoneRoutes.stoneLoading: (context) {
        final imagePath = ModalRoute.of(context)!.settings.arguments as String;
        return StoneLoadingView(imagePath: imagePath);
      },
      StoneRoutes.gemSettings: (context) => ChangeNotifierProvider(
        create: (_) => StoneSettingsViewModel(),
        child: const CrystalSettingsView(),
      ),
    };
  }
}

class GemstoneIDSplashScreen extends StatelessWidget {
  const GemstoneIDSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CrystalColors.crystalTabGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Diamond Icon with shadow effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  // Diamond container with gradient
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.8),
                        ],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.diamond,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Rock & Stone',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                'Identifier',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.95),
                  letterSpacing: 2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
