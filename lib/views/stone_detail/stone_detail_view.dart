import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'stone_detail_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../models/stone_scan_response.dart';
import '../../models/stone_model.dart';
import '../../helpers/stone_navigation_helper.dart';

class StoneDetailView extends StatelessWidget {
  final String? stoneId;
  final StoneDetails? apiStoneData;
  final String? imageUrl;
  
  const StoneDetailView({
    super.key,
    this.stoneId,
    this.apiStoneData,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneDetailViewModel()..initialize(
        stoneId: stoneId,
        apiStoneData: apiStoneData,
        imageUrl: imageUrl,
      ),
      child: const _RockDetailViewContent(),
    );
  }
}

class _RockDetailViewContent extends StatefulWidget {
  const _RockDetailViewContent();

  @override
  State<_RockDetailViewContent> createState() => _RockDetailViewContentState();
}

class _RockDetailViewContentState extends State<_RockDetailViewContent> {
  late WebViewController _webViewController;
  bool _isWebViewLoaded = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoneDetailViewModel>(
      builder: (context, detailViewModel, child) {
        if (detailViewModel.isLoading) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isApiData = detailViewModel.apiStoneData != null;
        final stone = detailViewModel.selectedStone;

        // Build HTML content for API data
        if (isApiData && detailViewModel.apiStoneData != null && !_isWebViewLoaded) {
          final apiStone = detailViewModel.apiStoneData!;
          final htmlContent = _buildFullHtmlContent(apiStone, detailViewModel.imageUrl);
          debugPrint('Loading HTML content into WebView (${htmlContent.length} chars)');
          debugPrint('HTML Preview: ${htmlContent.substring(0, 500)}...');
          
          // Check if this is the actual HTML or a placeholder
          if (htmlContent.contains('<!DOCTYPE html>')) {
            debugPrint('HTML content looks valid, loading into WebView');
            _webViewController.loadHtmlString(htmlContent);
          } else {
            debugPrint('WARNING: HTML content does not look like valid HTML!');
            debugPrint('Full content: $htmlContent');
            // Force load anyway
            _webViewController.loadHtmlString(htmlContent);
          }
          _isWebViewLoaded = true;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                StoneNavigationHelper.goToMainTabsAndClearStack();
              },
            ),
            title: Text(
              detailViewModel.stoneName,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: isApiData 
              ? WebViewWidget(controller: _webViewController)
              : _buildLocalContent(detailViewModel, stone!),
        );
      },
    );
  }

  String _buildFullHtmlContent(StoneDetails apiStone, String? imageUrl) {
    // If we have HTML content from API, use it directly
    if (apiStone.htmlContent != null && apiStone.htmlContent!.isNotEmpty) {
      debugPrint('Using HTML content from API (${apiStone.htmlContent!.length} chars)');
      
      // Check if HTML already includes the hero image, if not add it
      String htmlContent = apiStone.htmlContent!;
      
      // Remove confidence badge/button from HTML content
      htmlContent = _removeConfidenceBadge(htmlContent);
      
      // Remove "Bulunduğu Yerler" section, keep only "Localities"
      htmlContent = _removeBulunduguYerler(htmlContent);
      
      // Debug: Log all API data fields
      debugPrint('=== API DATA FIELDS DEBUG ===');
      debugPrint('Description: ${apiStone.description != null ? "EXISTS (${apiStone.description!.length} chars)" : "NULL"}');
      debugPrint('Energy Benefits: ${apiStone.energyBenefits != null ? "EXISTS (${apiStone.energyBenefits!.length} chars)" : "NULL"}');
      debugPrint('Physical Beliefs: ${apiStone.physicalBeliefs != null ? "EXISTS (${apiStone.physicalBeliefs!.length} chars)" : "NULL"}');
      debugPrint('Collection Tips: ${apiStone.collectionTips != null ? "EXISTS (${apiStone.collectionTips!.length} chars)" : "NULL"}');
      debugPrint('Localities: ${apiStone.localities != null ? "EXISTS (${apiStone.localities!.length} chars)" : "NULL"}');
      debugPrint('Basic Info: ${apiStone.basicInfo.mineralFamily} | ${apiStone.basicInfo.hardness}');
      debugPrint('Spiritual: ${apiStone.spiritual.elementChakra} | ${apiStone.spiritual.spiritualTheme}');
      debugPrint('FAQs count: ${apiStone.faqs.length}');
      debugPrint('=== END API DATA FIELDS DEBUG ===');
      
      // Add missing API data fields to HTML if they don't exist
      htmlContent = _ensureAllApiDataDisplayed(htmlContent, apiStone);
      
      // If imageUrl exists and HTML doesn't have hero image, prepend it
      if (imageUrl != null && !htmlContent.contains('hero-image')) {
        final heroSection = '''
        <div class="hero-image" style="width: 100%; height: 350px; position: relative; overflow: hidden; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
            <img src="$imageUrl" alt="${apiStone.name}" style="width: 100%; height: 100%; object-fit: cover;">
            <div class="hero-overlay" style="position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(to top, rgba(0,0,0,0.8), transparent); padding: 20px;">
                <div class="stone-name" style="color: white; font-size: 32px; font-weight: bold; margin-bottom: 8px;">${apiStone.name}</div>
            </div>
        </div>
        ''';
        
        // Insert hero section after body tag
        if (htmlContent.contains('<body>')) {
          htmlContent = htmlContent.replaceFirst('<body>', '<body>$heroSection');
        } else {
          // If no body tag, wrap content
          htmlContent = '''
          <!DOCTYPE html>
          <html>
          <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body>
              $heroSection
              $htmlContent
          </body>
          </html>
          ''';
        }
      }
      
      return htmlContent;
    }
    
    // Fallback: build complete HTML with all available data
    debugPrint('Building HTML content manually - htmlContent is null or empty');
    return _buildCompleteHtml(apiStone, imageUrl);
  }
  
  String _buildCompleteHtml(StoneDetails apiStone, String? imageUrl) {
    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                font-size: 16px; line-height: 1.6; color: #2D3748; background-color: #F7FAFC; padding-bottom: 20px;
            }
            .hero-image { width: 100%; height: 350px; position: relative; overflow: hidden; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
            .hero-image img { width: 100%; height: 100%; object-fit: cover; }
            .hero-overlay { position: absolute; bottom: 0; left: 0; right: 0; background: linear-gradient(to top, rgba(0,0,0,0.8), transparent); padding: 20px; }
            .stone-name { color: white; font-size: 32px; font-weight: bold; margin-bottom: 8px; }
            .card { background: white; margin: 16px; border-radius: 16px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
            .card-header { display: flex; align-items: center; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #E2E8F0; }
            .card-icon { font-size: 24px; margin-right: 12px; }
            .card-title { font-size: 20px; font-weight: bold; color: #1A202C; }
            .content { color: #4A5568; line-height: 1.8; font-size: 15px; }
        </style>
    </head>
    <body>
        ${imageUrl != null ? '''
        <div class="hero-image">
            <img src="$imageUrl" alt="${apiStone.name}">
            <div class="hero-overlay">
                <div class="stone-name">${apiStone.name}</div>
            </div>
        </div>
        ''' : ''}
        
        ${apiStone.description != null && apiStone.description!.isNotEmpty ? '''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">📖</span>
                <span class="card-title">Description</span>
            </div>
            <div class="content">${apiStone.description}</div>
        </div>
        ''' : ''}
        
        <!-- Basic Identity Section -->
        <div class="card">
            <div class="card-header">
                <span class="card-icon">🔮</span>
                <span class="card-title">Basic Identity</span>
            </div>
            <div class="content">
                <div style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; margin-bottom: 8px;">
                        <div style="width: 24px; height: 24px; background: #8B5CF6; border-radius: 4px; display: flex; align-items: center; justify-content: center; margin-right: 8px;">
                            <span style="color: white; font-size: 12px;">🔮</span>
                        </div>
                        <strong style="color: #4A5568;">Element & Chakra</strong>
                    </div>
                    <div style="color: #6B7280; margin-left: 32px;">${apiStone.spiritual.elementChakra}</div>
                </div>
                
                <div style="margin-bottom: 16px;">
                    <div style="display: flex; align-items: center; margin-bottom: 8px;">
                        <div style="width: 24px; height: 24px; background: #8B5CF6; border-radius: 4px; display: flex; align-items: center; justify-content: center; margin-right: 8px;">
                            <span style="color: white; font-size: 12px;">♒</span>
                        </div>
                        <strong style="color: #4A5568;">Zodiac Compatibility</strong>
                    </div>
                    <div style="color: #6B7280; margin-left: 32px;">${apiStone.spiritual.zodiacCompatibility}</div>
                </div>
                
                <div>
                    <div style="display: flex; align-items: center; margin-bottom: 8px;">
                        <div style="width: 24px; height: 24px; background: #10B981; border-radius: 4px; display: flex; align-items: center; justify-content: center; margin-right: 8px;">
                            <span style="color: white; font-size: 12px;">🍀</span>
                        </div>
                        <strong style="color: #4A5568;">Spiritual Theme</strong>
                    </div>
                    <div style="color: #6B7280; margin-left: 32px;">${apiStone.spiritual.spiritualTheme}</div>
                </div>
            </div>
        </div>
        
        ${apiStone.energyBenefits != null && apiStone.energyBenefits!.isNotEmpty ? '''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">⚡</span>
                <span class="card-title">Energy Benefits</span>
            </div>
            <div class="content">${apiStone.energyBenefits}</div>
        </div>
        ''' : ''}
        
        ${apiStone.physicalBeliefs != null && apiStone.physicalBeliefs!.isNotEmpty ? '''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">🩺</span>
                <span class="card-title">Physical Beliefs</span>
            </div>
            <div class="content">${apiStone.physicalBeliefs}</div>
        </div>
        ''' : ''}
        
        ${apiStone.collectionTips != null && apiStone.collectionTips!.isNotEmpty ? '''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">💎</span>
                <span class="card-title">Collection Tips</span>
            </div>
            <div class="content">${apiStone.collectionTips}</div>
        </div>
        ''' : ''}
        
        
        
    </body>
    </html>
    ''';
    
    return html;
  }

  String _removeConfidenceBadge(String htmlContent) {
    // Remove confidence badge/button and related elements
    // Remove common confidence patterns
    htmlContent = htmlContent.replaceAll(RegExp(r'<[^>]*confidence[^>]*>.*?</[^>]*>', caseSensitive: false, multiLine: true, dotAll: true), '');
    htmlContent = htmlContent.replaceAll(RegExp(r'<[^>]*>\s*confidence[^<]*</[^>]*>', caseSensitive: false, multiLine: true), '');
    htmlContent = htmlContent.replaceAll(RegExp(r'confidence:\s*\d+%', caseSensitive: false), '');
    htmlContent = htmlContent.replaceAll(RegExp(r'confidence\s*\d+%', caseSensitive: false), '');
    
    // Remove buttons or badges that contain confidence text
    htmlContent = htmlContent.replaceAll(RegExp(r'<button[^>]*>.*?confidence.*?</button>', caseSensitive: false, multiLine: true, dotAll: true), '');
    htmlContent = htmlContent.replaceAll(RegExp(r'<div[^>]*confidence[^>]*>.*?</div>', caseSensitive: false, multiLine: true, dotAll: true), '');
    htmlContent = htmlContent.replaceAll(RegExp(r'<span[^>]*>.*?confidence.*?</span>', caseSensitive: false, multiLine: true, dotAll: true), '');
    
    return htmlContent;
  }
  
  String _removeBulunduguYerler(String htmlContent) {
    // Remove ALL sections with Turkish "Yerleşim Yerleri" title completely
    final turkishPattern = RegExp(
      r'<div[^>]*class="card"[^>]*>.*?<span[^>]*class="card-title"[^>]*>.*?(?:Yerleşim Yerleri|Bulunduğu Yerler).*?</span>.*?</div>\s*</div>',
      multiLine: true,
      dotAll: true,
      caseSensitive: false
    );
    
    // Remove all Turkish locality sections
    htmlContent = htmlContent.replaceAll(turkishPattern, '');
    
    // Also remove any section that has the earth emoji followed by Turkish title
    final earthEmojiPattern = RegExp(
      r'<div[^>]*class="card"[^>]*>.*?🌍.*?(?:Yerleşim Yerleri|Bulunduğu Yerler).*?</div>\s*</div>',
      multiLine: true,
      dotAll: true,
      caseSensitive: false
    );
    
    htmlContent = htmlContent.replaceAll(earthEmojiPattern, '');
    
    // Remove duplicate Localities sections if they exist
    // Count how many times "Localities" appears
    final localitiesPattern = RegExp(
      r'<div[^>]*class="card"[^>]*>.*?<span[^>]*class="card-title"[^>]*>.*?Localities.*?</span>.*?</div>\s*</div>',
      multiLine: true,
      dotAll: true
    );
    
    final matches = localitiesPattern.allMatches(htmlContent).toList();
    if (matches.length > 1) {
      // Keep only the first occurrence, remove all others
      for (int i = matches.length - 1; i >= 1; i--) {
        htmlContent = htmlContent.replaceRange(matches[i].start, matches[i].end, '');
      }
    }
    
    return htmlContent;
  }
  
  String _ensureAllApiDataDisplayed(String htmlContent, StoneDetails apiStone) {
    // Check if HTML already contains all the required sections
    final hasDescription = apiStone.description != null && (htmlContent.toLowerCase().contains('description') || htmlContent.toLowerCase().contains('açıklama'));
    final hasEnergyBenefits = apiStone.energyBenefits != null && (htmlContent.toLowerCase().contains('energy') || htmlContent.toLowerCase().contains('enerji'));
    final hasPhysicalBeliefs = apiStone.physicalBeliefs != null && (htmlContent.toLowerCase().contains('physical beliefs') || htmlContent.toLowerCase().contains('fiziksel'));
    final hasCollectionTips = apiStone.collectionTips != null && (htmlContent.toLowerCase().contains('collection') || htmlContent.toLowerCase().contains('koleksiyon'));
    final hasLocalities = apiStone.localities != null && (htmlContent.toLowerCase().contains('localities'));
    
    // If HTML is missing essential sections, append them
    String additionalContent = '';
    
    if (!hasDescription && apiStone.description != null && apiStone.description!.isNotEmpty) {
      additionalContent += '''
      <div class="card">
          <div class="card-header">
              <span class="card-icon">📖</span>
              <span class="card-title">Description</span>
          </div>
          <div class="content">${apiStone.description}</div>
      </div>
      ''';
    }
    
    if (!hasEnergyBenefits && apiStone.energyBenefits != null && apiStone.energyBenefits!.isNotEmpty) {
      additionalContent += '''
      <div class="card">
          <div class="card-header">
              <span class="card-icon">⚡</span>
              <span class="card-title">Energy Benefits</span>
          </div>
          <div class="content">${apiStone.energyBenefits}</div>
      </div>
      ''';
    }
    
    if (!hasPhysicalBeliefs && apiStone.physicalBeliefs != null && apiStone.physicalBeliefs!.isNotEmpty) {
      additionalContent += '''
      <div class="card">
          <div class="card-header">
              <span class="card-icon">🩺</span>
              <span class="card-title">Physical Beliefs</span>
          </div>
          <div class="content">${apiStone.physicalBeliefs}</div>
      </div>
      ''';
    }
    
    if (!hasCollectionTips && apiStone.collectionTips != null && apiStone.collectionTips!.isNotEmpty) {
      additionalContent += '''
      <div class="card">
          <div class="card-header">
              <span class="card-icon">💎</span>
              <span class="card-title">Collection Tips</span>
          </div>
          <div class="content">${apiStone.collectionTips}</div>
      </div>
      ''';
    }
    
    if (!hasLocalities && apiStone.localities != null && apiStone.localities!.isNotEmpty) {
      additionalContent += '''
      <div class="card">
          <div class="card-header">
              <span class="card-icon">🌍</span>
              <span class="card-title">Localities</span>
          </div>
          <div class="content">${apiStone.localities}</div>
      </div>
      ''';
    }
    
    // Note: Basic Properties are already included in the API's HTML content
    // We don't need to duplicate them here
    
    // Note: FAQs are already included in the API's HTML content, no need to duplicate
    
    // Append additional content before closing body tag
    if (additionalContent.isNotEmpty) {
      if (htmlContent.contains('</body>')) {
        htmlContent = htmlContent.replaceFirst('</body>', '$additionalContent</body>');
      } else {
        htmlContent += additionalContent;
      }
    }
    
    return htmlContent;
  }

  

  Widget _buildLocalContent(StoneDetailViewModel detailViewModel, StoneModel stone) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stone.description,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: CrystalColors.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          
          // Uses
          if (stone.uses != null && stone.uses!.isNotEmpty) ...[
            Text(
              'Properties',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: CrystalColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            ...stone.uses!.map((use) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                '• $use',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: CrystalColors.textSecondary,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
}