import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/stone_model.dart';
import '../../models/stone_scan_response.dart';
import '../../data/stone_data.dart';
import '../../helpers/stone_storage_helper.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../helpers/stone_navigation_helper.dart';

class StoneDetailViewModel extends ChangeNotifier {
  final StoneStorageHelper _storageHelper = StoneStorageHelper();
  
  // Lifecycle state
  bool _isDisposed = false;
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Stone data
  StoneModel? _stone;
  StoneModel? get stone => _stone;
  
  // API Stone data
  StoneDetails? _apiStoneData;
  StoneDetails? get apiStoneData => _apiStoneData;
  
  // Image URL for API results
  String? _imageUrl;
  String? get imageUrl => _imageUrl;
  
  // Whether this is API data or local data
  bool _isApiData = false;
  bool get isApiData => _isApiData;
  
  // Getters for stone_detail_view.dart compatibility
  StoneModel? get selectedStone => _stone;
  String get stoneName => _isApiData ? (_apiStoneData?.name ?? 'Unknown Stone') : (_stone?.name ?? 'Unknown Stone');
  
  // Detailed properties for the stone
  Map<String, dynamic>? _detailedProperties;
  Map<String, dynamic>? get detailedProperties => _detailedProperties;
  
  // Spiritual properties
  List<String>? _spiritualProperties;
  List<String>? get spiritualProperties => _spiritualProperties;
  
  // Spiritual theme
  String? _spiritualTheme;
  String? get spiritualTheme => _spiritualTheme;
  
  // Collection tips
  String? _collectionTips;
  String? get collectionTips => _collectionTips;
  
  // FAQs
  List<Map<String, String>> _faqs = [];
  List<Map<String, String>> get faqs => _faqs;
  
  // Physical beliefs
  List<String>? _physicalBeliefs;
  List<String>? get physicalBeliefs => _physicalBeliefs;
  
  // Initialize with either API data or local stone ID
  Future<void> initialize({
    String? stoneId,
    StoneDetails? apiStoneData,
    String? imageUrl,
  }) async {
    if (apiStoneData != null) {
      // Handle API data
      _isApiData = true;
      _apiStoneData = apiStoneData;
      _imageUrl = imageUrl;
      _loadApiProperties();
    } else if (stoneId != null) {
      // Handle local stone data
      _isApiData = false;
      await loadStoneDetail(stoneId);
    } else {
      _error = 'No stone data provided';
      _safeNotifyListeners();
    }
  }
  
  // Load properties from API stone data
  void _loadApiProperties() {
    if (_apiStoneData == null) return;
    
    final stone = _apiStoneData!;
    
    // Set spiritual theme
    _spiritualTheme = stone.spiritual.spiritualTheme;
    
    // Convert spiritual benefits to the expected format
    _spiritualProperties = stone.spiritual.benefits.map((benefit) => 
      '${benefit.title}: ${benefit.description}'
    ).toList();
    
    // Convert to physical beliefs format
    _physicalBeliefs = [stone.physical.description];
    
    // Set collection tips
    _collectionTips = '${stone.collection.qualityIndicators}\n\nKaynaklar: ${stone.collection.sources}\n\nDeğer Faktörleri: ${stone.collection.valueFactors}';
    
    // Convert FAQs
    _faqs = stone.faqs.map((faq) => {
      'question': faq.question,
      'answer': faq.answer,
    }).toList();
    
    // Set detailed properties from basic info
    _detailedProperties = {
      'mineral_family': stone.basicInfo.mineralFamily,
      'hardness': stone.basicInfo.hardness,
      'color_variations': stone.basicInfo.colorVariations,
      'crystal_system': stone.basicInfo.crystalSystem,
    };
    
    _safeNotifyListeners();
  }
  
  // Load stone detail
  Future<void> loadStoneDetail(String stoneId) async {
    if (_isDisposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();
    
    try {
      // Get stone from data
      _stone = StoneData.getRockById(stoneId);
      
      if (_stone == null) {
        throw Exception('Stone not found');
      }
      
      // Load detailed properties based on stone
      _loadDetailedProperties();
      
      // Add to recent stones
      if (!_isDisposed) {
        await _storageHelper.addRecentStone(stoneId);
      }
      
    } catch (e) {
      _error = 'Error loading stone details';
      debugPrint('Stone detail error: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }
  
  void _loadDetailedProperties() {
    if (_stone == null) return;
    
    // Set element/chakra and zodiac from stone data
    if (_stone!.element != null && _stone!.chakra != null) {
      _detailedProperties = {
        'element': _stone!.element,
        'chakra': _stone!.chakra,
        'zodiacSigns': _stone!.zodiacSigns?.join(', ') ?? '',
      };
    }
    
    switch (_stone!.name.toLowerCase()) {
      case 'emerald':
        _spiritualTheme = 'stone_details.emerald.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('emerald');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('emerald');
        _collectionTips = 'stone_details.emerald.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('emerald');
        break;
        
      case 'diamond':
        _spiritualTheme = 'stone_details.diamond.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('diamond');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('diamond');
        _collectionTips = 'stone_details.diamond.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('diamond');
        break;
        
      case 'ruby':
        _spiritualTheme = 'stone_details.ruby.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('ruby');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('ruby');
        _collectionTips = 'stone_details.ruby.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('ruby');
        break;
        
      case 'sapphire':
        _spiritualTheme = 'stone_details.sapphire.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('sapphire');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('sapphire');
        _collectionTips = 'stone_details.sapphire.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('sapphire');
        break;
        
      case 'alexandrite':
        _spiritualTheme = 'stone_details.alexandrite.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('alexandrite');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('alexandrite');
        _collectionTips = 'stone_details.alexandrite.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('alexandrite');
        break;
        
      case 'tourmaline':
      case 'paraíba tourmaline':
        _spiritualTheme = 'stone_details.tourmaline.spiritual_theme'.tr();
        _spiritualProperties = _getLocalizedSpiritualProperties('tourmaline');
        _physicalBeliefs = _getLocalizedPhysicalBeliefs('tourmaline');
        _collectionTips = 'stone_details.tourmaline.collection_tips'.tr();
        _faqs = _getLocalizedFAQs('tourmaline');
        break;
        
      default:
        _spiritualProperties = [
          'Bu değerli taş, benzersiz enerjisi ve güzelliğiyle binlerce yıldır insanları büyülüyor.',
          'Doğanın mükemmel bir sanat eseri olan bu taş, koleksiyonunuzun en değerli parçalarından biri olabilir.',
        ];
    }
    
    // Notify listeners after loading properties
    _safeNotifyListeners();
  }
  
  // Toggle favorite
  Future<void> toggleFavorite(String stoneId) async {
    try {
      final context = StoneNavigationHelper.context;
      if (context == null) return;
      
      final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
          
      final isFavorite = appProvider.isFavoriteStone(stoneId);
      
      if (isFavorite) {
        await appProvider.removeFavoriteStone(stoneId);
      } else {
        await appProvider.addFavoriteStone(stoneId);
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }
  
  // Helper methods for localized content
  List<String> _getLocalizedSpiritualProperties(String stoneName) {
    final locale = EasyLocalization.of(StoneNavigationHelper.context!)?.currentLocale?.languageCode ?? 'en';
    
    switch (stoneName) {
      case 'emerald':
        if (locale == 'tr') {
          return [
            'Duygusal Şifa: Kırgınlık, kıskançlık ve güvensizliği yumuşatır.',
            'Zihinsel Berraklık: Meditasyonda "arka plan gürültüsünü" azaltır, odak toplar.',
            'Bağlılık Taşı: Antik çağlardan beri nişan yüzüklerinde sadakati temsil eder.',
          ];
        }
        return [
          'Emotional Healing: Softens resentment, jealousy and insecurity.',
          'Mental Clarity: Reduces background noise in meditation, improves focus.',
          'Commitment Stone: Represents loyalty in engagement rings since ancient times.',
        ];
      case 'diamond':
        if (locale == 'tr') {
          return [
            'Enerji Büyüteci: Diğer kristallerin titreşimini "amplifiye ettiği" söylenir.',
            'Negatif Kalkan: Düşük titreşimli düşünceleri geri yansıtarak "aurayı parlatır".',
            'Odak & Karar: Karbon kristal kafesinin kusursuzluğu, kullanıcının hedefe kilitlenmesini simgeler.',
          ];
        }
        return [
          'Energy Amplifier: Said to amplify the vibration of other crystals.',
          'Negative Shield: Reflects low-vibration thoughts, polishing the aura.',
          'Focus & Decision: The perfection of carbon crystal lattice symbolizes user\'s target lock.',
        ];
      case 'ruby':
        if (locale == 'tr') {
          return [
            'Yaşam Gücü: Qi\'yi yükseltir, sabah yorgunluğunu keser.',
            'Özgüven Dopingi: Performans kaygısını bastırır, liderlik niteliklerini besler.',
            'Kalp Ateşi: Romantik tutkuyu harlar; taşın kırmızı ışıltısı duygusal çekimi simgeler.',
          ];
        }
        return [
          'Life Force: Raises Qi, cuts morning fatigue.',
          'Confidence Boost: Suppresses performance anxiety, nurtures leadership qualities.',
          'Heart Fire: Ignites romantic passion; stone\'s red glow symbolizes emotional attraction.',
        ];
      case 'sapphire':
        if (locale == 'tr') {
          return [
            'Sezgi Kapısı: Üçüncü göz meditasyonunda içgörüyü keskinleştirir.',
            'Öğrenme Taşı: Konsantrasyonu artırarak sınav‑proje dönemlerinde tercih edilir.',
            'Duygusal Soğutma: Aşırı heyecan ve öfkeyi dengeler, "sakin lider" enerjisi sunar.',
          ];
        }
        return [
          'Intuition Gateway: Sharpens insight in third eye meditation.',
          'Learning Stone: Preferred during exam-project periods by increasing concentration.',
          'Emotional Cooling: Balances excessive excitement and anger, offers calm leader energy.',
        ];
      case 'alexandrite':
        if (locale == 'tr') {
          return [
            'Yin‑Yang Dengesi: Işıkta renk değişimi kişinin esneklik ve adaptasyon becerisini yansıtır.',
            'Sezgi Keskinleştirici: Ruh hallerinin altında yatan gerçek motivasyonları görmeye yardım eder.',
            'Karar Netliği: Karmaşık konularda "iki renk, tek taş" metaforuyla bütüncül düşünceyi teşvik eder.',
          ];
        }
        return [
          'Yin-Yang Balance: Color change in light reflects person\'s flexibility and adaptation ability.',
          'Intuition Sharpener: Helps see true motivations underlying moods.',
          'Decision Clarity: Encourages holistic thinking with two colors, one stone metaphor in complex matters.',
        ];
      case 'tourmaline':
        if (locale == 'tr') {
          return [
            'Neon Yaşam Enerjisi: Yorgun zihinleri "şok" etkisiyle yeniden şarj ettiğine inanılır.',
            'İfade Özgürlüğü: Boğaz çakrasını açarak dürüst ve akıcı iletişimi destekler.',
            'Duygusal Temizlik: Negatif duyguları "elektriksel" akımla nötralize eder, sakin bir berraklık bırakır.',
          ];
        }
        return [
          'Neon Life Energy: Believed to recharge tired minds with shock effect.',
          'Freedom of Expression: Supports honest and fluent communication by opening throat chakra.',
          'Emotional Cleansing: Neutralizes negative emotions with electrical current, leaves calm clarity.',
        ];
      default:
        return [
          'This precious stone has been enchanting people for thousands of years with its unique energy and beauty.',
          'A perfect work of art from nature, this stone can be one of the most valuable pieces in your collection.',
        ];
    }
  }

  List<String> _getLocalizedPhysicalBeliefs(String stoneName) {
    final locale = EasyLocalization.of(StoneNavigationHelper.context!)?.currentLocale?.languageCode ?? 'en';
    
    switch (stoneName) {
      case 'emerald':
        if (locale == 'tr') {
          return [
            'Kalp ritmini dengelediği ve tansiyonu rahatlattığına inanılır.',
            'Bağışıklığı "canlandırdığı", kronik yorgunluğu hafiflettiği rivayet edilir.',
            'Strese bağlı baş ağrılarını yatıştırdığı söylenir.',
          ];
        }
        return [
          'Believed to balance heart rhythm and ease blood pressure.',
          'Said to revitalize immunity and relieve chronic fatigue.',
          'Believed to soothe stress-related headaches.',
        ];
      case 'diamond':
        if (locale == 'tr') {
          return [
            'Zihinsel keskinliği ve hafızayı güçlendirdiği rivayet edilir.',
            'Metabolizmayı uyarmaya, toksin atmaya yardım ettiği söylenir.',
          ];
        }
        return [
          'Reportedly strengthens mental sharpness and memory.',
          'Said to help stimulate metabolism and eliminate toxins.',
        ];
      case 'ruby':
        if (locale == 'tr') {
          return [
            'Kan dolaşımını hızlandırdığı, libido ve hormon dengesine yardımcı olduğu söylenir.',
            'Atletik dayanıklılığa katkı sunduğuna inanılır.',
          ];
        }
        return [
          'Said to accelerate blood circulation, help with libido and hormone balance.',
          'Believed to contribute to athletic endurance.',
        ];
      case 'sapphire':
        if (locale == 'tr') {
          return [
            'Göz sağlığını güçlendirdiği, migreni yatıştırdığı rivayet edilir.',
            'Uykusuzluğa karşı yatak başına yerleştirilir.',
          ];
        }
        return [
          'Reportedly strengthens eye health, soothes migraines.',
          'Placed beside bed against insomnia.',
        ];
      case 'alexandrite':
        if (locale == 'tr') {
          return [
            'Sistemik denge getirdiği, hormon seviyelerini düzenlemeye yardımcı olduğu söylenir.',
          ];
        }
        return [
          'Said to bring systemic balance, help regulate hormone levels.',
        ];
      case 'tourmaline':
        if (locale == 'tr') {
          return [
            'Solunum yollarını rahatlattığı, lenf drenajını canlandırdığı söylenir.',
          ];
        }
        return [
          'Said to relieve respiratory passages, stimulate lymph drainage.',
        ];
      default:
        return [
          'Traditional beliefs about physical benefits.',
        ];
    }
  }

  List<Map<String, String>> _getLocalizedFAQs(String stoneName) {
    try {
      final List<dynamic> faqsData = 'stone_details.$stoneName.faqs'.tr() as List<dynamic>;
      return faqsData.map((faq) => {
        'question': faq['question']?.toString() ?? '',
        'answer': faq['answer']?.toString() ?? '',
      }).toList();
    } catch (e) {
      // Fallback to English FAQs if translation fails
      final locale = EasyLocalization.of(StoneNavigationHelper.context!)?.currentLocale?.languageCode ?? 'en';
      return _getHardcodedFAQs(stoneName, locale);
    }
  }

  List<Map<String, String>> _getHardcodedFAQs(String stoneName, String locale) {
    switch (stoneName) {
      case 'emerald':
        if (locale == 'tr') {
          return [
            {'question': 'Zümrüt çatlaklıysa enerjisi azalır mı?', 'answer': 'Doğal desenin "toprak ruhu" taşıdığına inanıldığı için hayır.'},
            {'question': 'Kimler takmamalı?', 'answer': 'Şiddetli Satürn transiti yaşayanlar başka taşlarla dengeleyerek kullanır.'},
            {'question': 'Nasıl arındırılır?', 'answer': 'Ilık sabunlu su + tütsü; uzun süre tuzlu suda bekletme (çatlaklara zarar verebilir).'},
          ];
        }
        return [
          {'question': 'Does the energy of emerald decrease if it\'s cracked?', 'answer': 'No, because natural patterns are believed to carry the \'earth spirit\'.'},
          {'question': 'Who shouldn\'t wear it?', 'answer': 'Those experiencing intense Saturn transits should use it balanced with other stones.'},
          {'question': 'How to cleanse it?', 'answer': 'Warm soapy water + incense; avoid prolonged soaking in salt water (may damage cracks).'},
        ];
      case 'diamond':
        if (locale == 'tr') {
          return [
            {'question': 'Lab‑grown elmasın enerjisi eksik mi?', 'answer': 'Farklı yorumlar var; doğal prosesin "dünya belleğini" taşıdığı inancı yaygın.'},
            {'question': 'Elmas nazar değer mi?', 'answer': 'Parlak enerjisi sahiplik duygusunu tetikleyebilir; düzenli arındırma önerilir.'},
            {'question': 'Nasıl temizlenir?', 'answer': 'Ilık sabunlu su, yumuşak fırça; aşındırıcı temizlik kimyasallarından kaçın.'},
          ];
        }
        return [
          {'question': 'Does lab-grown diamond have less energy?', 'answer': 'Different opinions exist; the natural process is widely believed to carry \'earth memory\'.'},
          {'question': 'Does diamond attract evil eye?', 'answer': 'Its bright energy can trigger ownership feelings; regular cleansing is recommended.'},
          {'question': 'How to clean?', 'answer': 'Warm soapy water, soft brush; avoid abrasive cleaning chemicals.'},
        ];
      case 'ruby':
        if (locale == 'tr') {
          return [
            {'question': 'Yakut fazla ateş verir mi?', 'answer': 'Yüksek enerjisiyle uykusuzluk yapabilir; sakin bir taşla (akuamarin vb.) denge önerilir.'},
            {'question': 'Yıldız yakutun spiritüel artısı?', 'answer': 'Altı ışınlı asterizm "kaderin korunması" simgesi olarak kabul edilir.'},
          ];
        }
        return [
          {'question': 'Does ruby give too much fire?', 'answer': 'Its high energy can cause insomnia; balance with a calm stone (like aquamarine) is recommended.'},
          {'question': 'What\'s the spiritual benefit of star ruby?', 'answer': 'Six-rayed asterism is accepted as a symbol of \'destiny protection\'.'},
        ];
      case 'sapphire':
        if (locale == 'tr') {
          return [
            {'question': 'Safir kime iyi gelmez?', 'answer': 'Güçlü Satürn etkisi altında fazla soğuk enerji verebilir; astroloğa danışılabilir.'},
            {'question': 'Asterizm (yıldız) eşdeğer mi?', 'answer': 'Yıldız safir, sakinlik yerine koruma sembolizmi taşır; enerji odakları farklıdır.'},
          ];
        }
        return [
          {'question': 'Who doesn\'t benefit from sapphire?', 'answer': 'Can give too much cold energy under strong Saturn influence; consult an astrologer.'},
          {'question': 'Is asterism (star) equivalent?', 'answer': 'Star sapphire carries protection symbolism instead of calmness; energy focuses differ.'},
        ];
      case 'alexandrite':
        if (locale == 'tr') {
          return [
            {'question': 'Gece kırmızı olmuyorsa sahte mi?', 'answer': 'Işık kaynağı tayfı yetersiz olabilir; akkor lamba test et.'},
            {'question': 'Renk değişimi enerjiyi nasıl etkiler?', 'answer': 'Taşın "duygusal geçişler" için köprü olduğu kabul edilir, yani renk geçişi ne kadar dramatikse dönüşüm gücü o kadar yüksek denir.'},
          ];
        }
        return [
          {'question': 'Is it fake if it doesn\'t turn red at night?', 'answer': 'Light source spectrum may be insufficient; test with incandescent lamp.'},
          {'question': 'How does color change affect energy?', 'answer': 'The stone is accepted as a bridge for \'emotional transitions\', meaning the more dramatic the color transition, the higher the transformation power.'},
        ];
      case 'tourmaline':
        if (locale == 'tr') {
          return [
            {'question': 'Rengi solar mı?', 'answer': 'UV\'ye dirençli; fakat yüksek ısıyla lehim işlemlerinden koru.'},
            {'question': 'Paraíba yanına hangi taş yakışır?', 'answer': 'Aytaşı veya pırlanta, neon rengin ışıltısını bastırmadan vurgular.'},
          ];
        }
        return [
          {'question': 'Does the color fade?', 'answer': 'UV resistant; but protect from soldering operations with high heat.'},
          {'question': 'Which stone goes well with Paraíba?', 'answer': 'Moonstone or diamond emphasizes without suppressing the neon color\'s brilliance.'},
        ];
      default:
        return [];
    }
  }

  // Safe notifyListeners that checks if disposed
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