import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'paywall_viewmodel.dart';
import '../../helpers/stone_navigation_helper.dart';

class PaywallView extends StatelessWidget {
  final bool fromOnboarding;

  const PaywallView({
    super.key,
    this.fromOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get fromOnboarding from route arguments if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isFromOnboarding = args?['isFromOnboarding'] ?? fromOnboarding;

    return ChangeNotifierProvider(
      create: (_) => PaywallViewModel()..initialize(),
      child: Consumer<PaywallViewModel>(
        builder: (context, viewModel, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent,
            ),
            child: _PaywallContent(
              fromOnboarding: isFromOnboarding,
              viewModel: viewModel,
            ),
          );
        },
      ),
    );
  }
}

class _PaywallContent extends StatefulWidget {
  final bool fromOnboarding;
  final PaywallViewModel viewModel;

  const _PaywallContent({
    required this.fromOnboarding,
    required this.viewModel,
  });

  @override
  State<_PaywallContent> createState() => _PaywallContentState();
}

class _PaywallContentState extends State<_PaywallContent> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/rock_paywall.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.setVolume(0);
    _videoController.play();
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background video with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background video
                if (_isVideoInitialized)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                else
                  // Fallback image while video loads
                  Positioned.fill(
                    child: Image.asset(
                      'assets/paywall.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: const Color(0xFF030712));
                      },
                    ),
                  ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF030712).withOpacity(0),
                          const Color(0xFF030712).withOpacity(1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        if (widget.fromOnboarding) {
                          // Go to main tabs when closing paywall from onboarding
                          StoneNavigationHelper.goToMainTabsAndClearStack();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),

                // Expanded to push content to bottom
                const Spacer(),

                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'paywall.title'.tr(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'paywall.subtitle'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Features list
                      Column(
                        children: [
                          _buildFeatureItem(
                            '🔍',
                            'paywall.features.unlimited_identification'.tr(),
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureItem(
                            '📚',
                            'paywall.features.all_facts'.tr(),
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureItem('⚡', 'paywall.features.ai_analysis'.tr()),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pricing options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildPricingOption(
                        index: 0,
                        title: 'paywall.plans.weekly.title'.tr(),
                        subtitle: 'paywall.plans.weekly.subtitle'.tr(),
                        price: widget.viewModel.weeklyPrice,
                        isSelected: widget.viewModel.isWeeklySelected,
                        isWeekly: true,
                        onTap: () => widget.viewModel.selectWeekly(),
                      ),
                      const SizedBox(height: 12),
                      _buildPricingOption(
                        index: 1,
                        title: 'paywall.plans.lifetime.title'.tr(),
                        subtitle: 'paywall.plans.lifetime.subtitle'.tr(),
                        price: widget.viewModel.lifetimePrice,
                        isSelected: widget.viewModel.isLifetimeSelected,
                        isWeekly: false,
                        onTap: () => widget.viewModel.selectLifetime(),
                        savingsPercentage: widget.viewModel.savingsPercentage,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Start button at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: widget.viewModel.isLoading
                        ? null
                        : () async {
                            final purchased = await widget.viewModel
                                .purchase();
                            if (purchased && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: widget.viewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                'paywall.continue'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Security badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Platform.isIOS
                          ? 'paywall.security.ios'.tr()
                          : 'paywall.security.android'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.viewModel.openTerms,
                      child: Text(
                        'paywall.footer.terms'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      width: 1,
                      height: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    GestureDetector(
                      onTap: widget.viewModel.openPrivacy,
                      child: Text(
                        'paywall.footer.privacy'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      width: 1,
                      height: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final restored = await widget.viewModel.restore();
                        if (restored && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text(
                        'paywall.footer.restore'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOption({
    required int index,
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
    required bool isWeekly,
    required VoidCallback onTap,
    int? savingsPercentage,
  }) {
    final isYearly = !isWeekly;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withOpacity(0.2)
                  : const Color(0xFF000000).withOpacity(0.54),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 16)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Discount badge for lifetime plan
          if (!isWeekly)
            Positioned(
              top: -10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF94D4), Color(0xFFE7B4F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.black, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      'SAVE ${savingsPercentage ?? 70}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}