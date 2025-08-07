import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'paywall_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../helpers/revenue_cat_helper.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ChangeNotifierProvider(
        create: (_) => PaywallViewModel(),
        child: const _PaywallViewContent(),
      ),
    );
  }
}

class _PaywallViewContent extends StatefulWidget {
  const _PaywallViewContent();

  @override
  State<_PaywallViewContent> createState() => _PaywallViewContentState();
}

class _PaywallViewContentState extends State<_PaywallViewContent> 
    with SingleTickerProviderStateMixin {
  bool _isLifetimeSelected = true;
  bool _isFromOnboarding = false;
  late AnimationController _closeButtonController;
  late Animation<double> _closeButtonAnimation;
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _closeButtonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _closeButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _closeButtonController,
      curve: Curves.easeInOut,
    ));
    
    // Show close button immediately
    setState(() {
      _showCloseButton = true;
    });
    _closeButtonController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get the arguments passed to this route
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _isFromOnboarding = args?['isFromOnboarding'] ?? false;
  }
  
  @override
  void dispose() {
    _closeButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaywallViewModel>(
      builder: (context, paywallViewModel, child) {
        return PopScope(
          canPop: !_isFromOnboarding,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 40.h), // Space for close button
                      
                      // Content with fixed layout
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
                                // Pro Image
                                SizedBox(
                                  height: 180.h,
                                  width: 180.w,
                                  child: Image.asset(
                                    'assets/pro.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                
                                // Title
                                Text(
                                  'paywall.title'.tr(),
                                  style: GoogleFonts.inter(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Features List
                                _buildFeatureItem(
                                  icon: Icons.camera_alt,
                                  title: 'paywall.features.identify_unlimited'.tr(),
                                ),
                                
                                SizedBox(height: 8.h),
                                
                                _buildFeatureItem(
                                  icon: Icons.school,
                                  title: 'paywall.features.unlock_facts'.tr(),
                                ),
                                
                                SizedBox(height: 8.h),
                                
                                _buildFeatureItem(
                                  icon: Icons.auto_awesome,
                                  title: 'paywall.features.ai_analysis'.tr(),
                                ),
                                
                                SizedBox(height: 8.h),
                                
                                _buildFeatureItem(
                                  icon: Icons.lock_open,
                                  title: 'paywall.features.remove_paywalls'.tr(),
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Dynamic pricing options from RevenueCat
                                ...RevenueCatHelper.shared.products.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final product = entry.value;
                                  final isSelected = index == (_isLifetimeSelected ? 0 : 1);
                                  
                                  // Determine if this is lifetime based on product identifier
                                  final isLifetime = product.identifier.toLowerCase().contains('lifetime');
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: index < RevenueCatHelper.shared.products.length - 1 ? 12.h : 0),
                                    child: _buildNewPricingCard(
                                      title: isLifetime ? 'paywall.plans.lifetime'.tr() : 'paywall.plans.weekly'.tr(),
                                      subtitle: isLifetime ? null : '${product.priceString} ${'paywall.plans.per_week'.tr()}',
                                      price: isLifetime ? product.priceString : null,
                                      badge: isLifetime ? 'paywall.plans.save_badge'.tr() : '',
                                      badgeColor: isLifetime ? Colors.red[600]! : Colors.green[600]!,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _isLifetimeSelected = index == 0;
                                        });
                                      },
                                    ),
                                  );
                                }),
                                
                                SizedBox(height: 32.h), // Space for button
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Purchase Button
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: CrystalColors.crystalTabGradient,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (RevenueCatHelper.shared.products.isNotEmpty) {
                                  final selectedIndex = _isLifetimeSelected ? 0 : 1;
                                  if (selectedIndex < RevenueCatHelper.shared.products.length) {
                                    final selectedProduct = RevenueCatHelper.shared.products[selectedIndex];
                                    paywallViewModel.purchaseProduct(selectedProduct.identifier);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 0,
                              ),
                              child: paywallViewModel.isLoading
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'paywall.continue'.tr(),
                                          style: GoogleFonts.inter(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Hamburger menu button positioned at top left
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: GestureDetector(
                      onTap: () => _showOptionsMenu(context),
                      child: Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu,
                          color: Colors.grey[600],
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  // Close button
                  if (_showCloseButton)
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: GestureDetector(
                        onTap: () async {
                          if (_isFromOnboarding) {
                            // Mark onboarding as completed
                            StoneNavigationHelper.goToMainTabsAndClearStack();
                          } else {
                            StoneNavigationHelper.goBack();
                          }
                        },
                        child: Container(
                          width: 28.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: CrystalColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: CrystalColors.primaryBlue,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPricingCard({
    required String title,
    String? subtitle,
    String? price,
    required String badge,
    required Color badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? CrystalColors.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Title and price section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Badge next to title
                      if (badge.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (price != null && price.isNotEmpty && subtitle == null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Check mark on the right
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? CrystalColors.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? CrystalColors.primaryBlue : Colors.grey[400]!,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'paywall.menu.title'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuOption(
                context,
                title: 'paywall.menu.privacy_policy'.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchURL('https://mobinaz.com/privacy-rockify');
                },
              ),
              Divider(height: 1.h, color: Colors.grey[300]),
              _buildMenuOption(
                context,
                title: 'paywall.menu.terms_of_service'.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchURL('https://mobinaz.com/terms-rockify');
                },
              ),
              Divider(height: 1.h, color: Colors.grey[300]),
              _buildMenuOption(
                context,
                title: 'paywall.menu.restore_purchases'.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  _restorePurchases();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'paywall.menu.cancel'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuOption(BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          color: CrystalColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await RevenueCatHelper.shared.restorePurchases();
      // Show success message
      ScaffoldMessenger.of(StoneNavigationHelper.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            'paywall.messages.restore_success'.tr(),
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: CrystalColors.primaryBlue,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(StoneNavigationHelper.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            '${'paywall.messages.restore_failed'.tr()}: $e',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}