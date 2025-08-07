import 'dart:convert';
import 'package:flutter/foundation.dart';

class StoneScanResponse {
  final bool success;
  final String message;
  final StoneScanData? data;

  StoneScanResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoneScanResponse.fromJson(Map<String, dynamic> json) {
    return StoneScanResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? StoneScanData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class StoneScanData {
  final int submissionId;
  final String imageUrl;
  final StoneDetails stone;
  final int processingTimeMs;

  StoneScanData({
    required this.submissionId,
    required this.imageUrl,
    required this.stone,
    required this.processingTimeMs,
  });

  factory StoneScanData.fromJson(Map<String, dynamic> json) {
    return StoneScanData(
      submissionId: json['submission_id'] as int,
      imageUrl: json['image_url'] as String,
      stone: StoneDetails.fromJson(json['stone']),
      processingTimeMs: json['processing_time_ms'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'image_url': imageUrl,
      'stone': stone.toJson(),
      'processing_time_ms': processingTimeMs,
    };
  }
}

class StoneDetails {
  final String name;
  final double confidence;
  final BasicInfo basicInfo;
  final SpiritualProperties spiritual;
  final PhysicalProperties physical;
  final CollectionInfo collection;
  final List<FAQ> faqs;
  final String? htmlContent; // Added to store HTML content from API
  final String? description; // Added to store description if exists
  final String? energyBenefits; // Added for energy_benefits field
  final String? physicalBeliefs; // Added for physical_beliefs field  
  final String? collectionTips; // Added for collection_tips field
  final String? localities; // Added for localities field

  StoneDetails({
    required this.name,
    required this.confidence,
    required this.basicInfo,
    required this.spiritual,
    required this.physical,
    required this.collection,
    required this.faqs,
    this.htmlContent,
    this.description,
    this.energyBenefits,
    this.physicalBeliefs,
    this.collectionTips,
    this.localities,
  });

  factory StoneDetails.fromJson(Map<String, dynamic> json) {
    try {
      return StoneDetails(
        name: _parseStringField(json['name'], 'Unknown Stone'),
        confidence: _parseConfidence(json['confidence']),
        basicInfo: _parseBasicInfo(json['basic_info']),
        spiritual: _parseSpiritualProperties(json['spiritual']),
        physical: _parsePhysicalProperties(json['physical']),
        collection: _parseCollectionInfo(json['collection']),
        faqs: _parseFAQs(json['faqs']),
        htmlContent: json['html_content'] as String?,
        description: json['description'] as String?,
        energyBenefits: json['energy_benefits'] as String?,
        physicalBeliefs: json['physical_beliefs'] as String?,
        collectionTips: json['collection_tips'] as String?,
        localities: json['localities'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing StoneDetails: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  static String _parseStringField(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is String) {
      // Clean up the string - remove trailing punctuation and extra spaces
      String cleaned = value.trim();
      cleaned = cleaned.replaceAll(RegExp(r'[,.]$'), ''); // Remove trailing comma or period
      return cleaned.isNotEmpty ? cleaned : fallback;
    }
    return value.toString();
  }

  static double _parseConfidence(dynamic confidence) {
    if (confidence == null) return 0.0;
    if (confidence is num) {
      double conf = confidence.toDouble();
      // Normalize confidence to 0-1 range if it's > 1
      if (conf > 1.0) {
        conf = conf / 100.0; // Convert percentage to decimal
      }
      return conf.clamp(0.0, 1.0);
    }
    if (confidence is String) {
      try {
        double conf = double.parse(confidence);
        if (conf > 1.0) conf = conf / 100.0;
        return conf.clamp(0.0, 1.0);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static BasicInfo _parseBasicInfo(dynamic basicInfo) {
    if (basicInfo == null) {
      return BasicInfo(
        mineralFamily: 'Unknown',
        hardness: 'Unknown',
        colorVariations: 'Various',
        crystalSystem: 'Unknown',
      );
    }
    
    if (basicInfo is String) {
      try {
        final Map<String, dynamic> basicInfoMap = jsonDecode(basicInfo);
        return BasicInfo.fromJson(basicInfoMap);
      } catch (e) {
        return BasicInfo(
          mineralFamily: 'Unknown',
          hardness: 'Unknown', 
          colorVariations: 'Various',
          crystalSystem: 'Unknown',
        );
      }
    } else if (basicInfo is Map<String, dynamic>) {
      return BasicInfo.fromJson(basicInfo);
    } else {
      return BasicInfo(
        mineralFamily: 'Unknown',
        hardness: 'Unknown',
        colorVariations: 'Various', 
        crystalSystem: 'Unknown',
      );
    }
  }

  static SpiritualProperties _parseSpiritualProperties(dynamic spiritual) {
    if (spiritual == null) {
      return SpiritualProperties(
        elementChakra: 'Unknown',
        zodiacCompatibility: 'Universal',
        spiritualTheme: 'Balance and harmony',
        benefits: [],
      );
    }
    
    if (spiritual is String) {
      try {
        final Map<String, dynamic> spiritualMap = jsonDecode(spiritual);
        return SpiritualProperties.fromJson(spiritualMap);
      } catch (e) {
        // If it's just a plain string, treat it as spiritual theme
        return SpiritualProperties(
          elementChakra: 'Unknown',
          zodiacCompatibility: 'Universal',
          spiritualTheme: spiritual,
          benefits: [],
        );
      }
    } else if (spiritual is Map<String, dynamic>) {
      return SpiritualProperties.fromJson(spiritual);
    } else {
      return SpiritualProperties(
        elementChakra: 'Unknown',
        zodiacCompatibility: 'Universal',
        spiritualTheme: 'Balance and harmony',
        benefits: [],
      );
    }
  }

  static List<FAQ> _parseFAQs(dynamic faqs) {
    if (faqs == null) return [];
    if (faqs is List) {
      return faqs.map((e) {
        try {
          if (e is Map<String, dynamic>) {
            return FAQ.fromJson(e);
          } else {
            return FAQ(question: 'Question', answer: e.toString());
          }
        } catch (error) {
          return FAQ(question: 'Question', answer: 'No answer available');
        }
      }).toList();
    }
    return [];
  }

  static PhysicalProperties _parsePhysicalProperties(dynamic physical) {
    if (physical is String) {
      // Parse JSON string
      try {
        final Map<String, dynamic> physicalMap = jsonDecode(physical);
        return PhysicalProperties.fromJson(physicalMap);
      } catch (e) {
        // Fallback to default if parsing fails
        return PhysicalProperties(description: physical, icon: '🩺');
      }
    } else if (physical is Map<String, dynamic>) {
      return PhysicalProperties.fromJson(physical);
    } else {
      return PhysicalProperties(description: 'No description available', icon: '🩺');
    }
  }

  static CollectionInfo _parseCollectionInfo(dynamic collection) {
    if (collection is String) {
      // Parse JSON string
      try {
        final Map<String, dynamic> collectionMap = jsonDecode(collection);
        return CollectionInfo.fromJson(collectionMap);
      } catch (e) {
        // Fallback to default if parsing fails
        return CollectionInfo(
          qualityIndicators: collection,
          sources: '',
          valueFactors: '',
        );
      }
    } else if (collection is Map<String, dynamic>) {
      return CollectionInfo.fromJson(collection);
    } else {
      return CollectionInfo(
        qualityIndicators: 'No information available',
        sources: '',
        valueFactors: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'basic_info': basicInfo.toJson(),
      'spiritual': spiritual.toJson(),
      'physical': physical.toJson(),
      'collection': collection.toJson(),
      'faqs': faqs.map((e) => e.toJson()).toList(),
      if (htmlContent != null) 'html_content': htmlContent,
      if (description != null) 'description': description,
      if (energyBenefits != null) 'energy_benefits': energyBenefits,
      if (physicalBeliefs != null) 'physical_beliefs': physicalBeliefs,
      if (collectionTips != null) 'collection_tips': collectionTips,
      if (localities != null) 'localities': localities,
    };
  }
}

class BasicInfo {
  final String mineralFamily;
  final String hardness;
  final String colorVariations;
  final String crystalSystem;

  BasicInfo({
    required this.mineralFamily,
    required this.hardness,
    required this.colorVariations,
    required this.crystalSystem,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      mineralFamily: (json['mineral_family'] as String?) ?? 'Unknown',
      hardness: (json['hardness'] as String?) ?? 'Unknown',
      colorVariations: (json['color_variations'] as String?) ?? 'Various',
      crystalSystem: (json['crystal_system'] as String?) ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mineral_family': mineralFamily,
      'hardness': hardness,
      'color_variations': colorVariations,
      'crystal_system': crystalSystem,
    };
  }
}

class SpiritualProperties {
  final String elementChakra;
  final String zodiacCompatibility;
  final String spiritualTheme;
  final List<SpiritualBenefit> benefits;

  SpiritualProperties({
    required this.elementChakra,
    required this.zodiacCompatibility,
    required this.spiritualTheme,
    required this.benefits,
  });

  factory SpiritualProperties.fromJson(Map<String, dynamic> json) {
    return SpiritualProperties(
      elementChakra: (json['element_chakra'] as String?) ?? 'Unknown',
      zodiacCompatibility: (json['zodiac_compatibility'] as String?) ?? 'Universal',
      spiritualTheme: (json['spiritual_theme'] as String?) ?? 'Balance and harmony',
      benefits: _parseBenefits(json['benefits']),
    );
  }

  static List<SpiritualBenefit> _parseBenefits(dynamic benefits) {
    if (benefits == null) return [];
    
    if (benefits is String) {
      // If benefits is a String, create a single benefit item
      return [
        SpiritualBenefit(
          icon: '✨',
          title: 'Benefits',
          description: benefits,
        )
      ];
    } else if (benefits is List) {
      return benefits.map((e) {
        try {
          if (e is Map<String, dynamic>) {
            return SpiritualBenefit.fromJson(e);
          } else if (e is String) {
            return SpiritualBenefit(
              icon: '✨',
              title: 'Benefit',
              description: e,
            );
          } else {
            return SpiritualBenefit(
              icon: '✨',
              title: 'Benefit',
              description: e.toString(),
            );
          }
        } catch (error) {
          return SpiritualBenefit(
            icon: '✨',
            title: 'Benefit',
            description: 'Benefit information available',
          );
        }
      }).toList();
    } else {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'element_chakra': elementChakra,
      'zodiac_compatibility': zodiacCompatibility,
      'spiritual_theme': spiritualTheme,
      'benefits': benefits.map((e) => e.toJson()).toList(),
    };
  }
}

class SpiritualBenefit {
  final String icon;
  final String title;
  final String description;

  SpiritualBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory SpiritualBenefit.fromJson(Map<String, dynamic> json) {
    return SpiritualBenefit(
      icon: (json['icon'] as String?) ?? '✨',
      title: (json['title'] as String?) ?? 'Benefit',
      description: (json['description'] as String?) ?? 'No description available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
    };
  }
}

class PhysicalProperties {
  final String description;
  final String icon;

  PhysicalProperties({
    required this.description,
    required this.icon,
  });

  factory PhysicalProperties.fromJson(Map<String, dynamic> json) {
    return PhysicalProperties(
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'icon': icon,
    };
  }
}

class CollectionInfo {
  final String qualityIndicators;
  final String sources;
  final String valueFactors;

  CollectionInfo({
    required this.qualityIndicators,
    required this.sources,
    required this.valueFactors,
  });

  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    return CollectionInfo(
      qualityIndicators: (json['quality_indicators'] as String?) ?? '',
      sources: (json['sources'] as String?) ?? '',
      valueFactors: (json['value_factors'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality_indicators': qualityIndicators,
      'sources': sources,
      'value_factors': valueFactors,
    };
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      question: (json['question'] as String?) ?? 'Question',
      answer: (json['answer'] as String?) ?? 'No answer available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}