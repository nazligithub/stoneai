class StoneListResponse {
  final bool success;
  final String message;
  final StoneListData? data;

  StoneListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoneListResponse.fromJson(Map<String, dynamic> json) {
    return StoneListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? StoneListData.fromJson(json['data']) : null,
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

class StoneListData {
  final List<StoneListItem> stones;

  StoneListData({
    required this.stones,
  });

  factory StoneListData.fromJson(Map<String, dynamic> json) {
    return StoneListData(
      stones: (json['stones'] as List)
          .map((e) => StoneListItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stones': stones.map((e) => e.toJson()).toList(),
    };
  }
}

class StoneListItem {
  final int id;
  final String name;
  final String elementChakra;
  final String zodiacCompatibility;
  final String spiritualTheme;

  StoneListItem({
    required this.id,
    required this.name,
    required this.elementChakra,
    required this.zodiacCompatibility,
    required this.spiritualTheme,
  });

  factory StoneListItem.fromJson(Map<String, dynamic> json) {
    return StoneListItem(
      id: json['id'] as int,
      name: json['name'] as String,
      elementChakra: json['element_chakra'] as String,
      zodiacCompatibility: json['zodiac_compatibility'] as String,
      spiritualTheme: json['spiritual_theme'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'element_chakra': elementChakra,
      'zodiac_compatibility': zodiacCompatibility,
      'spiritual_theme': spiritualTheme,
    };
  }
}