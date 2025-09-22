import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../helpers/revenue_cat_helper.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../helpers/stone_navigation_helper.dart';
import 'package:provider/provider.dart';

class PaywallViewModel extends ChangeNotifier {
  bool _isWeeklySelected = false;
  bool _isLifetimeSelected = true;
  bool _isLoading = false;

  bool get isWeeklySelected => _isWeeklySelected;
  bool get isLifetimeSelected => _isLifetimeSelected;
  bool get isLoading => _isLoading;

  StoreProduct? get weeklyProduct {
    final weeklyList = RevenueCatHelper.shared.products.where(
      (product) => product.identifier.toLowerCase().contains('weekly'),
    ).toList();

    if (weeklyList.isNotEmpty) {
      return weeklyList.first;
    }

    return RevenueCatHelper.shared.products.isNotEmpty
      ? RevenueCatHelper.shared.products.first
      : null;
  }

  StoreProduct? get lifetimeProduct {
    final lifetimeList = RevenueCatHelper.shared.products.where(
      (product) => product.identifier.toLowerCase().contains('lifetime'),
    ).toList();

    if (lifetimeList.isNotEmpty) {
      return lifetimeList.first;
    }

    return RevenueCatHelper.shared.products.isNotEmpty
      ? RevenueCatHelper.shared.products.last
      : null;
  }

  String get weeklyPrice => weeklyProduct?.priceString ?? '\$4.99';
  String get lifetimePrice => lifetimeProduct?.priceString ?? '\$39.99';

  String get lifetimeWeeklyPrice {
    final lifetimePriceValue = lifetimeProduct?.price ?? 39.99;
    final weeklyPrice = lifetimePriceValue / 52;
    return '\$${weeklyPrice.toStringAsFixed(2)}/week';
  }

  int get savingsPercentage {
    final weeklyPriceValue = weeklyProduct?.price ?? 4.99;
    final lifetimePriceValue = lifetimeProduct?.price ?? 39.99;
    final weeklyYearlyTotal = weeklyPriceValue * 52;
    if (weeklyYearlyTotal > 0) {
      final savings = ((weeklyYearlyTotal - lifetimePriceValue) / weeklyYearlyTotal * 100);
      return savings.round();
    }
    return 70;
  }

  void initialize() {
    // Products are already fetched in splash screen
    notifyListeners();
  }

  void selectWeekly() {
    _isWeeklySelected = true;
    _isLifetimeSelected = false;
    notifyListeners();
  }

  void selectLifetime() {
    _isWeeklySelected = false;
    _isLifetimeSelected = true;
    notifyListeners();
  }

  Future<bool> purchase() async {
    _isLoading = true;
    notifyListeners();

    try {
      StoreProduct? productToPurchase;

      if (_isWeeklySelected) {
        productToPurchase = weeklyProduct;
      } else if (_isLifetimeSelected) {
        productToPurchase = lifetimeProduct;
      }

      if (productToPurchase == null) {
        debugPrint('No product selected');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final success = await RevenueCatHelper.shared.purchaseProduct(productToPurchase.identifier);

      _isLoading = false;
      notifyListeners();

      // Notify app provider if purchase was successful
      if (success && StoneNavigationHelper.context != null) {
        final appProvider = Provider.of<StoneAppProvider>(
          StoneNavigationHelper.context!,
          listen: false,
        );
        await appProvider.setPremiumUser(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Purchase error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restore() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await RevenueCatHelper.shared.restorePurchases();

      _isLoading = false;
      notifyListeners();

      // Notify app provider if restore was successful
      if (success && StoneNavigationHelper.context != null) {
        final appProvider = Provider.of<StoneAppProvider>(
          StoneNavigationHelper.context!,
          listen: false,
        );
        await appProvider.setPremiumUser(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Restore error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void openTerms() async {
    const url = 'https://mobinaz.com/terms-rockify';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void openPrivacy() async {
    const url = 'https://mobinaz.com/privacy-rockify';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}