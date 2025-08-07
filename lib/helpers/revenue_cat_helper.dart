import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

class RevenueCatHelper {
  static final RevenueCatHelper _instance = RevenueCatHelper._internal();
  factory RevenueCatHelper() => _instance;
  RevenueCatHelper._internal();

  static RevenueCatHelper get shared => _instance;

  // API Key
  static const String _apiKey = 'appl_WvgYlOJOLVZowDhCXalgoXETPDA';
  
  // Entitlement identifier
  static const String _entitlementId = 'pro';
  
  // Products list
  List<StoreProduct> products = [];
  
  // Subscription status
  bool isActive = false;
  
  // Initialize RevenueCat
  Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      PurchasesConfiguration configuration;
      configuration = PurchasesConfiguration(_apiKey);
      
      await Purchases.configure(configuration);
      
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization error: $e');
    }
  }
  
  // Load products
  Future<void> loadProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current != null) {
        // Get default offering products
        final currentOffering = offerings.current!;
        products = currentOffering.availablePackages
            .map((package) => package.storeProduct)
            .toList();
        
        debugPrint('Loaded ${products.length} products');
        for (var product in products) {
          debugPrint('Product: ${product.identifier} - ${product.title} - ${product.priceString}');
        }
      } else {
        debugPrint('No current offering available');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }
  
  // Check subscription status
  Future<void> checkSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      
      // Check if user has active pro entitlement
      isActive = customerInfo.entitlements.active.containsKey(_entitlementId);
      
      debugPrint('Subscription status - isActive: $isActive');
      
      if (isActive) {
        final entitlement = customerInfo.entitlements.active[_entitlementId];
        debugPrint('Active entitlement: ${entitlement?.identifier}');
        debugPrint('Expires: ${entitlement?.expirationDate}');
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      isActive = false;
    }
  }
  
  // Purchase product
  Future<bool> purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current != null) {
        final packages = offerings.current!.availablePackages;
        final package = packages.firstWhere(
          (package) => package.storeProduct.identifier == productId,
          orElse: () => throw Exception('Product not found'),
        );
        
        final purchaseResult = await Purchases.purchasePackage(package);
        
        // Update subscription status
        isActive = purchaseResult.customerInfo.entitlements.active.containsKey(_entitlementId);
        
        debugPrint('Purchase successful - isActive: $isActive');
        return isActive;
      }
      
      return false;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }
  
  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      
      // Update subscription status
      isActive = customerInfo.entitlements.active.containsKey(_entitlementId);
      
      debugPrint('Restore successful - isActive: $isActive');
      return isActive;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }
  
  // Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }
  
  // Check if user has any active entitlements
  Future<bool> hasActiveEntitlements() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking entitlements: $e');
      return false;
    }
  }
}