import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../helpers/revenue_cat_helper.dart';
import '../../constants/crystal_colors.dart';

class StoneSettingsViewModel extends ChangeNotifier {
  // Navigation methods
  void navigateToPaywall() {
    HapticFeedback.mediumImpact();
    StoneNavigationHelper.navigatorKey.currentState?.pushNamed('/paywall');
  }

  void navigateToNotifications() {
    HapticFeedback.lightImpact();
    // TODO: Implement notifications navigation
  }

  void navigateToCameraPermissions() {
    HapticFeedback.lightImpact();
    // TODO: Implement camera permissions navigation
  }

  void navigateToLanguageSettings() {
    HapticFeedback.lightImpact();
    // TODO: Implement language settings navigation
  }

  // URL launch methods
  Future<void> launchSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mobinaz.com',
      query: 'subject=Rock & Stone Identifier Support',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError('Could not launch email client');
    }
  }

  Future<void> launchPrivacyPolicy() async {
    await _launchURL('https://mobinaz.com/privacy-rockify');
  }

  Future<void> launchTermsOfService() async {
    await _launchURL('https://mobinaz.com/terms-rockify');
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not launch $url');
    }
  }

  // Purchase methods
  Future<void> restorePurchases() async {
    try {
      await RevenueCatHelper.shared.restorePurchases();
      _showSuccess('Purchases restored successfully');
    } catch (e) {
      _showError('Failed to restore purchases: $e');
    }
  }

  // Dialog methods
  void showClearRecentStonesDialog(BuildContext context, VoidCallback onConfirm) {
    _showConfirmationDialog(
      context,
      title: 'Clear Recent Stones',
      content: 'This will remove all your recent stone identifications. Continue?',
      onConfirm: onConfirm,
    );
  }

  void showResetAllDataDialog(BuildContext context, VoidCallback onConfirm) {
    _showConfirmationDialog(
      context,
      title: 'Reset All Data',
      content: 'This will delete all your data including favorites, recent stones, and preferences. This cannot be undone.',
      onConfirm: onConfirm,
      isDangerous: true,
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool isDangerous = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: isDangerous ? CrystalColors.rubyRed : CrystalColors.textPrimary,
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: isDangerous ? CrystalColors.rubyRed : CrystalColors.primaryBlue,
              ),
              child: Text(isDangerous ? 'Delete' : 'Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  void _showSuccess(String message) {
    final context = StoneNavigationHelper.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CrystalColors.primaryBlue,
        ),
      );
    }
  }

  void _showError(String message) {
    final context = StoneNavigationHelper.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CrystalColors.rubyRed,
        ),
      );
    }
  }

  // App version
  String get appVersion => '1.0.0';
}