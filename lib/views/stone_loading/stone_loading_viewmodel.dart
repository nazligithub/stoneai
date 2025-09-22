import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import '../../services/stone_api_service.dart';
import '../../helpers/stone_navigation_helper.dart';
import '../../helpers/stone_storage_helper.dart';
import '../../constants/crystal_colors.dart';
import '../../viewmodels/stone_app_provider.dart';

class StoneLoadingViewModel extends ChangeNotifier {
  final String imagePath;
  late final StoneApiService _apiService;
  
  double _progress = 0.0;
  String _statusText = 'stone_loading.preparing_image'.tr();
  String? _error;
  bool _isDisposed = false;
  Timer? _progressTimer;
  Timer? _statusTimer;
  
  double get progress => _progress;
  String get statusText => _statusText;
  String? get error => _error;

  StoneLoadingViewModel(this.imagePath) {
    final currentLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _apiService = StoneApiService(
      userId: 'test-user-123', // TODO: Get from authenticated user
      locale: currentLocale,
    );
  }

  Future<void> startScanning() async {
    if (_isDisposed) return;
    
    _error = null;
    _progress = 0.0;
    _statusText = 'stone_loading.preparing_image'.tr();
    _safeNotifyListeners();
    
    // Start progress animation
    _startProgressAnimation();
    
    try {
      final imageFile = File(imagePath);
      
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Görsel dosyası bulunamadı');
      }

      // Call API to scan the stone
      final response = await _apiService.scanStone(
        imageFile: imageFile,
        scanType: 'identification',
      );

      if (_isDisposed) return;

      if (response.success && response.data != null) {
        // Complete the progress bar
        _progress = 1.0;
        _safeNotifyListeners();
        
        // Debug log API response
        debugPrint('API Response Stone Name: ${response.data!.stone.name}');
        debugPrint('API Response Confidence: ${response.data!.stone.confidence}');
        debugPrint('API Response FAQs count: ${response.data!.stone.faqs.length}');
        debugPrint('API Response HTML Content: ${response.data!.stone.htmlContent != null ? "EXISTS (${response.data!.stone.htmlContent!.length} chars)" : "NULL"}');
        debugPrint('API Response Energy Benefits: ${response.data!.stone.energyBenefits != null ? "EXISTS" : "NULL"}');
        debugPrint('API Response Physical Beliefs: ${response.data!.stone.physicalBeliefs != null ? "EXISTS" : "NULL"}');
        debugPrint('API Response Collection Tips: ${response.data!.stone.collectionTips != null ? "EXISTS" : "NULL"}');
        debugPrint('API Response Localities: ${response.data!.stone.localities != null ? "EXISTS" : "NULL"}');
        if (response.data!.stone.htmlContent != null) {
          debugPrint('HTML Content Preview: ${response.data!.stone.htmlContent!.substring(0, response.data!.stone.htmlContent!.length > 300 ? 300 : response.data!.stone.htmlContent!.length)}...');
        }
        
        // Save to history
        try {
          debugPrint('StoneLoadingViewModel: Saving to history...');
          final userId = 'guest'; // TODO: Get actual user ID from auth service
          await StoneStorageHelper().addApiScanToHistory(
            stoneName: response.data!.stone.name,
            imageUrl: response.data!.imageUrl,
            confidence: response.data!.stone.confidence,
            scanDate: DateTime.now(),
            fullData: response.data!.toJson(),
            userId: userId,
          );
          debugPrint('StoneLoadingViewModel: Saved to history successfully');
          
          // Debug: Check if it was actually saved
          final history = StoneStorageHelper().getApiScanHistory(userId: userId);
          debugPrint('StoneLoadingViewModel: Current history count: ${history.length}');
        } catch (e) {
          debugPrint('StoneLoadingViewModel: Error saving to history: $e');
        }
        
        // Wait a bit for completion animation
        await Future.delayed(Duration(milliseconds: 500));
        
        if (!_isDisposed) {
          // Increment scan count when user successfully views the results
          try {
            final context = StoneNavigationHelper.navigatorKey.currentContext;
            if (context != null) {
              // ignore: use_build_context_synchronously
              final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
              await appProvider.incrementScanCount();
              debugPrint('StoneLoadingViewModel: Scan count incremented after successful identification');
            }
          } catch (e) {
            debugPrint('StoneLoadingViewModel: Error incrementing scan count: $e');
          }
          
          // Navigate to stone detail page with results
          StoneNavigationHelper.replaceWith(
            '/stone-detail',
            arguments: {
              'stoneId': response.data!.submissionId.toString(),
              'stoneData': response.data!.stone,
              'imageUrl': response.data!.imageUrl,
            },
          );
        }
      } else {
        _error = response.message.isNotEmpty 
            ? response.message 
            : 'Analiz sırasında bir hata oluştu';
        
        // Check if this is a "no stone detected" error
        if (response.message.contains('Görüntüde taş veya kristal tespit edilemedi') ||
            response.message.contains('örüntüde taş veya kristal tespit edilemedi') ||
            response.message.contains('Lütfen bir taş/kristal fotoğrafı yükleyin') ||
            response.message.contains('Failed to identify stone')) {
          _showNoStoneDetectedDialog();
          return;
        }
        
        _safeNotifyListeners();
      }
    } catch (e) {
      debugPrint('Scan error: $e');
      if (!_isDisposed) {
        final errorMessage = e.toString();
        
        // Check if this is a "no stone detected" error in exception
        if (errorMessage.contains('Görüntüde taş veya kristal tespit edilemedi') ||
            errorMessage.contains('örüntüde taş veya kristal tespit edilemedi') ||
            errorMessage.contains('Lütfen bir taş/kristal fotoğrafı yükleyin') ||
            errorMessage.contains('Failed to identify stone')) {
          _showNoStoneDetectedDialog();
          return;
        }
        
        _error = _getErrorMessage(errorMessage);
        _safeNotifyListeners();
      }
    } finally {
      _stopTimers();
    }
  }

  Future<void> _updateStatus(String status, double targetProgress) async {
    if (_isDisposed) return;
    
    _statusText = status;
    // Progress is now handled by the smooth animation timer
    _safeNotifyListeners();
  }

  void _startProgressAnimation() {
    // Smooth progress animation over 15 seconds
    const totalDuration = Duration(seconds: 15);
    const updateInterval = Duration(milliseconds: 100);
    final totalSteps = totalDuration.inMilliseconds ~/ updateInterval.inMilliseconds;
    int currentStep = 0;
    
    _progressTimer = Timer.periodic(updateInterval, (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      if (_error != null) {
        timer.cancel();
        return;
      }
      
      currentStep++;
      
      // Calculate smooth progress (0 to 0.95 over 15 seconds)
      // Leave the last 5% for when API actually completes
      _progress = (currentStep / totalSteps) * 0.95;
      
      if (_progress >= 0.95) {
        timer.cancel();
        _progress = 0.95;
      }
      
      _safeNotifyListeners();
    });
  }

  String _getErrorMessage(String error) {
    final cleanError = error.replaceFirst('Exception: ', '');
    
    if (cleanError.contains('Connection timeout') || 
        cleanError.contains('timeout')) {
      return 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
    } else if (cleanError.contains('Cannot connect') || 
               cleanError.contains('connection')) {
      return 'Sunucuya bağlanılamıyor. İnternet bağlantınızı kontrol edin.';
    } else if (cleanError.contains('413') || 
               cleanError.contains('too large')) {
      return 'Görsel dosyası çok büyük. Maksimum boyut 10MB olmalıdır.';
    } else if (cleanError.contains('400') || 
               cleanError.contains('Bad request')) {
      return 'Geçersiz istek. Lütfen tekrar deneyin.';
    } else if (cleanError.contains('500') || 
               cleanError.contains('Server error')) {
      return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
    }
    
    return cleanError.isNotEmpty ? cleanError : 'Bilinmeyen bir hata oluştu';
  }

  Future<void> retryScanning() async {
    _error = null;
    _progress = 0.0;
    _safeNotifyListeners();
    await startScanning();
  }

  void goBack() {
    StoneNavigationHelper.goBack();
  }

  void _showNoStoneDetectedDialog() {
    // Get the current context from NavigationHelper
    final context = StoneNavigationHelper.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'stone_loading.stone_not_detected'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Text(
            'stone_loading.stone_not_detected_desc'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                goBack(); // Go back to photo/camera
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text(
                'stone_loading.ok'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                retryScanning(); // Retry the same image
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CrystalColors.primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'stone_loading.try_again'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _stopTimers() {
    _progressTimer?.cancel();
    _statusTimer?.cancel();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _isDisposed = true;
    _stopTimers();
    _apiService.dispose();
    super.dispose();
  }
}