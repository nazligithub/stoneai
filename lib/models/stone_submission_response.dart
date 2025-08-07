class StoneSubmissionResponse {
  final bool success;
  final String message;
  final StoneSubmissionData? data;

  StoneSubmissionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoneSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return StoneSubmissionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? StoneSubmissionData.fromJson(json['data']) : null,
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

class StoneSubmissionData {
  final int id;
  final String userId;
  final int stoneId;
  final String status;
  final String scanType;
  final String locale;
  final String imageUrl;
  final String createdAt;
  final String completedAt;
  final int processingTimeMs;
  final DetailedStoneInfo stone;

  StoneSubmissionData({
    required this.id,
    required this.userId,
    required this.stoneId,
    required this.status,
    required this.scanType,
    required this.locale,
    required this.imageUrl,
    required this.createdAt,
    required this.completedAt,
    required this.processingTimeMs,
    required this.stone,
  });

  factory StoneSubmissionData.fromJson(Map<String, dynamic> json) {
    return StoneSubmissionData(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      stoneId: json['stone_id'] as int,
      status: json['status'] as String,
      scanType: json['scan_type'] as String,
      locale: json['locale'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: json['created_at'] as String,
      completedAt: json['completed_at'] as String,
      processingTimeMs: json['processing_time_ms'] as int,
      stone: DetailedStoneInfo.fromJson(json['stone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'stone_id': stoneId,
      'status': status,
      'scan_type': scanType,
      'locale': locale,
      'image_url': imageUrl,
      'created_at': createdAt,
      'completed_at': completedAt,
      'processing_time_ms': processingTimeMs,
      'stone': stone.toJson(),
    };
  }
}

class DetailedStoneInfo {
  final String name;
  final double confidence;
  final StoneProperties properties;
  final String elementChakra;
  final String zodiacCompatibility;
  final String spiritualTheme;
  final List<EnergyBenefit> energyBenefits;
  final PhysicalBeliefs physicalBeliefs;
  final CollectionTips collectionTips;
  final String identifiedAt;

  DetailedStoneInfo({
    required this.name,
    required this.confidence,
    required this.properties,
    required this.elementChakra,
    required this.zodiacCompatibility,
    required this.spiritualTheme,
    required this.energyBenefits,
    required this.physicalBeliefs,
    required this.collectionTips,
    required this.identifiedAt,
  });

  factory DetailedStoneInfo.fromJson(Map<String, dynamic> json) {
    return DetailedStoneInfo(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      properties: StoneProperties.fromJson(json['properties']),
      elementChakra: json['element_chakra'] as String,
      zodiacCompatibility: json['zodiac_compatibility'] as String,
      spiritualTheme: json['spiritual_theme'] as String,
      energyBenefits: (json['energy_benefits'] as List)
          .map((e) => EnergyBenefit.fromJson(e))
          .toList(),
      physicalBeliefs: PhysicalBeliefs.fromJson(json['physical_beliefs']),
      collectionTips: CollectionTips.fromJson(json['collection_tips']),
      identifiedAt: json['identified_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'properties': properties.toJson(),
      'element_chakra': elementChakra,
      'zodiac_compatibility': zodiacCompatibility,
      'spiritual_theme': spiritualTheme,
      'energy_benefits': energyBenefits.map((e) => e.toJson()).toList(),
      'physical_beliefs': physicalBeliefs.toJson(),
      'collection_tips': collectionTips.toJson(),
      'identified_at': identifiedAt,
    };
  }
}

class StoneProperties {
  final BasicStoneInfo basicInfo;
  final SpiritualStoneProperties spiritualProperties;
  final UsageGuide usageGuide;

  StoneProperties({
    required this.basicInfo,
    required this.spiritualProperties,
    required this.usageGuide,
  });

  factory StoneProperties.fromJson(Map<String, dynamic> json) {
    return StoneProperties(
      basicInfo: BasicStoneInfo.fromJson(json['basic_info']),
      spiritualProperties: SpiritualStoneProperties.fromJson(json['spiritual_properties']),
      usageGuide: UsageGuide.fromJson(json['usage_guide']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basic_info': basicInfo.toJson(),
      'spiritual_properties': spiritualProperties.toJson(),
      'usage_guide': usageGuide.toJson(),
    };
  }
}

class BasicStoneInfo {
  final String mineralFamily;
  final String hardness;
  final String colorVariations;
  final String crystalSystem;

  BasicStoneInfo({
    required this.mineralFamily,
    required this.hardness,
    required this.colorVariations,
    required this.crystalSystem,
  });

  factory BasicStoneInfo.fromJson(Map<String, dynamic> json) {
    return BasicStoneInfo(
      mineralFamily: json['mineral_family'] as String,
      hardness: json['hardness'] as String,
      colorVariations: json['color_variations'] as String,
      crystalSystem: json['crystal_system'] as String,
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

class SpiritualStoneProperties {
  final List<String> primaryChakras;
  final List<String> elements;
  final List<String> keyBenefits;

  SpiritualStoneProperties({
    required this.primaryChakras,
    required this.elements,
    required this.keyBenefits,
  });

  factory SpiritualStoneProperties.fromJson(Map<String, dynamic> json) {
    return SpiritualStoneProperties(
      primaryChakras: (json['primary_chakras'] as List).cast<String>(),
      elements: (json['elements'] as List).cast<String>(),
      keyBenefits: (json['key_benefits'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_chakras': primaryChakras,
      'elements': elements,
      'key_benefits': keyBenefits,
    };
  }
}

class UsageGuide {
  final String meditation;
  final String wearing;
  final String cleansing;

  UsageGuide({
    required this.meditation,
    required this.wearing,
    required this.cleansing,
  });

  factory UsageGuide.fromJson(Map<String, dynamic> json) {
    return UsageGuide(
      meditation: json['meditation'] as String,
      wearing: json['wearing'] as String,
      cleansing: json['cleansing'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meditation': meditation,
      'wearing': wearing,
      'cleansing': cleansing,
    };
  }
}

class EnergyBenefit {
  final String icon;
  final String title;
  final String description;

  EnergyBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory EnergyBenefit.fromJson(Map<String, dynamic> json) {
    return EnergyBenefit(
      icon: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
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

class PhysicalBeliefs {
  final String description;
  final String icon;

  PhysicalBeliefs({
    required this.description,
    required this.icon,
  });

  factory PhysicalBeliefs.fromJson(Map<String, dynamic> json) {
    return PhysicalBeliefs(
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

class CollectionTips {
  final String qualityIndicators;
  final String sources;
  final String valueFactors;

  CollectionTips({
    required this.qualityIndicators,
    required this.sources,
    required this.valueFactors,
  });

  factory CollectionTips.fromJson(Map<String, dynamic> json) {
    return CollectionTips(
      qualityIndicators: json['quality_indicators'] as String,
      sources: json['sources'] as String,
      valueFactors: json['value_factors'] as String,
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