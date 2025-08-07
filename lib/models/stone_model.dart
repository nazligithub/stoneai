class StoneModel {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String description;
  final String imageUrl;
  final double hardness;
  final String color;
  final String luster;
  final String formation;
  final bool isPopular;
  final List<String>? uses;
  final String? origin;
  final double? density;
  final String? crystalSystem;
  final List<String>? zodiacSigns;
  final String? element;
  final String? chakra;

  StoneModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.hardness,
    required this.color,
    required this.luster,
    required this.formation,
    this.isPopular = false,
    this.uses,
    this.origin,
    this.density,
    this.crystalSystem,
    this.zodiacSigns,
    this.element,
    this.chakra,
  });

  factory StoneModel.fromJson(Map<String, dynamic> json) {
    return StoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      hardness: (json['hardness'] as num).toDouble(),
      color: json['color'] as String,
      luster: json['luster'] as String,
      formation: json['formation'] as String,
      isPopular: json['is_popular'] as bool? ?? false,
      uses: json['uses'] != null ? List<String>.from(json['uses']) : null,
      origin: json['origin'] as String?,
      density: json['density'] != null ? (json['density'] as num).toDouble() : null,
      crystalSystem: json['crystal_system'] as String?,
      zodiacSigns: json['zodiac_signs'] != null ? List<String>.from(json['zodiac_signs']) : null,
      element: json['element'] as String?,
      chakra: json['chakra'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'hardness': hardness,
      'color': color,
      'luster': luster,
      'formation': formation,
      'is_popular': isPopular,
      'uses': uses,
      'origin': origin,
      'density': density,
      'crystal_system': crystalSystem,
      'zodiac_signs': zodiacSigns,
      'element': element,
      'chakra': chakra,
    };
  }

  StoneModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? category,
    String? description,
    String? imageUrl,
    double? hardness,
    String? color,
    String? luster,
    String? formation,
    bool? isPopular,
    List<String>? uses,
    String? origin,
    double? density,
    String? crystalSystem,
    List<String>? zodiacSigns,
    String? element,
    String? chakra,
  }) {
    return StoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      hardness: hardness ?? this.hardness,
      color: color ?? this.color,
      luster: luster ?? this.luster,
      formation: formation ?? this.formation,
      isPopular: isPopular ?? this.isPopular,
      uses: uses ?? this.uses,
      origin: origin ?? this.origin,
      density: density ?? this.density,
      crystalSystem: crystalSystem ?? this.crystalSystem,
      zodiacSigns: zodiacSigns ?? this.zodiacSigns,
      element: element ?? this.element,
      chakra: chakra ?? this.chakra,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoneModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StoneModel(id: $id, name: $name, category: $category)';
  }
}