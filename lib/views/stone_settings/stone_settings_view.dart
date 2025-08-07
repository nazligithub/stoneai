import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../constants/crystal_colors.dart';
import 'stone_settings_viewmodel.dart';

class CrystalSettingsView extends StatelessWidget {
  const CrystalSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneSettingsViewModel(),
      child: Consumer<StoneAppProvider>(
        builder: (context, appProvider, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: CrystalColors.backgroundLight,
              appBar: AppBar(
                backgroundColor: CrystalColors.backgroundLight,
                elevation: 0,
                title: Text(
                  'settings.title'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CrystalColors.textPrimary,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: CrystalColors.textPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    children: [
                      _buildPremiumCard(context, appProvider),
                      const SizedBox(height: 24),
                      _buildAboutSection(context),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, StoneAppProvider appProvider) {
    if (appProvider.isPremiumUser) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: CrystalColors.crystalTabGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings.premium.member_title'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'settings.premium.member_subtitle'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final viewModel = Provider.of<StoneSettingsViewModel>(context, listen: false);
        viewModel.navigateToPaywall();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: CrystalColors.crystalTabGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'settings.premium.upgrade_title'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'settings.premium.upgrade_subtitle'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: 'settings.sections.about'.tr(),
      children: [
        _buildSettingsTile(
          title: 'settings.about.help_support'.tr(),
          subtitle: 'settings.about.help_support_subtitle'.tr(),
          leading: const Icon(
            Icons.help_outline,
            color: CrystalColors.primaryBlue,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: CrystalColors.textSecondary,
            size: 16,
          ),
          onTap: () {
            final viewModel = Provider.of<StoneSettingsViewModel>(context, listen: false);
            viewModel.launchSupportEmail();
          },
        ),
        _buildSettingsTile(
          title: 'settings.about.privacy_policy'.tr(),
          subtitle: 'settings.about.privacy_policy_subtitle'.tr(),
          leading: const Icon(
            Icons.privacy_tip_outlined,
            color: CrystalColors.primaryBlue,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: CrystalColors.textSecondary,
            size: 16,
          ),
          onTap: () {
            final viewModel = Provider.of<StoneSettingsViewModel>(context, listen: false);
            viewModel.launchPrivacyPolicy();
          },
        ),
        _buildSettingsTile(
          title: 'settings.about.terms_of_service'.tr(),
          subtitle: 'settings.about.terms_of_service_subtitle'.tr(),
          leading: const Icon(
            Icons.description_outlined,
            color: CrystalColors.primaryBlue,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: CrystalColors.textSecondary,
            size: 16,
          ),
          onTap: () {
            final viewModel = Provider.of<StoneSettingsViewModel>(context, listen: false);
            viewModel.launchTermsOfService();
          },
        ),
        _buildSettingsTile(
          title: 'settings.about.restore_purchases'.tr(),
          subtitle: 'settings.about.restore_purchases_subtitle'.tr(),
          leading: const Icon(
            Icons.restore,
            color: CrystalColors.primaryBlue,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: CrystalColors.textSecondary,
            size: 16,
          ),
          onTap: () {
            final viewModel = Provider.of<StoneSettingsViewModel>(context, listen: false);
            viewModel.restorePurchases();
          },
        ),
        _buildSettingsTile(
          title: 'settings.about.version'.tr(),
          subtitle: Provider.of<StoneSettingsViewModel>(context, listen: false).appVersion,
          leading: const Icon(
            Icons.info_outline,
            color: CrystalColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CrystalColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CrystalColors.stoneGray.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: CrystalColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: CrystalColors.textSecondary,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

}