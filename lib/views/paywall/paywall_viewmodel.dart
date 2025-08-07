import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../helpers/revenue_cat_helper.dart';

class PaywallViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isDisposed = false;

  // Purchase methods
  Future<void> purchaseYearly() async {
    await _makePurchase('yearly_premium');
  }

  Future<void> startTrial() async {
    await _makePurchase('weekly_trial');
  }

  Future<void> purchaseLifetime() async {
    await _makePurchase('lifetime_premium');
  }

  Future<void> startWeeklyTrial() async {
    await _makePurchase('weekly_trial');
  }

  Future<void> purchaseProduct(String productId) async {
    await _makePurchase(productId);
  }

  Future<void> _makePurchase(String productId) async {
    if (_isDisposed) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // Use RevenueCatHelper to make purchase
      final success = await RevenueCatHelper.shared.purchaseProduct(productId);
      
      if (success) {
        // Purchase successful
        await _handleSuccessfulPurchase();
      } else {
        throw Exception('Purchase failed');
      }

    } catch (e) {
      debugPrint('Purchase error: $e');
      _error = _getPurchaseErrorMessage(e);
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _handleSuccessfulPurchase() async {
    try {
      final context = StoneNavigationHelper.context;
      if (context != null && !_isDisposed) {
        // Update premium status in app provider
        final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
        await appProvider.setPremiumUser(true);
        
        // Perform navigation and show message without using context across async gaps
        if (!_isDisposed) {
          // Navigate back
          StoneNavigationHelper.goBack();
          
          // Schedule success message to be shown without using context
          _scheduleSuccessMessage();
        }
      }
    } catch (e) {
      debugPrint('Success handling error: $e');
    }
  }

  void _scheduleSuccessMessage() {
    // Use a callback approach or handle success message differently
    // For now, we'll use a simple approach
    Future.microtask(() {
      final context = StoneNavigationHelper.context;
      if (context != null && !_isDisposed) {
        // ignore: use_build_context_synchronously
        _showSuccessMessage(context);
      }
    });
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'paywall.messages.premium_activated'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getPurchaseErrorMessage(dynamic error) {
    if (error is PurchasesError) {
      switch (error.code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return 'Satın alma iptal edildi';
        case PurchasesErrorCode.paymentPendingError:
          return 'Ödeme beklemede';
        case PurchasesErrorCode.networkError:
          return 'İnternet bağlantısını kontrol edin';
        case PurchasesErrorCode.purchaseNotAllowedError:
          return 'Satın alma izni verilmedi';
        case PurchasesErrorCode.purchaseInvalidError:
          return 'Geçersiz satın alma';
        default:
          return 'Satın alma sırasında bir hata oluştu';
      }
    }
    return 'Beklenmeyen bir hata oluştu';
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    if (_isDisposed) return;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final success = await RevenueCatHelper.shared.restorePurchases();
      
      if (success) {
        await _handleSuccessfulPurchase();
      } else {
        _error = 'Aktif abonelik bulunamadı';
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      _error = 'Abonelik geri yükleme başarısız';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}