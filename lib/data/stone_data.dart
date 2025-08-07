import '../models/stone_model.dart';

class StoneData {
  static StoneModel? getRockById(String id) {
    final stones = getExploreStones();
    try {
      return stones.firstWhere((stone) => stone.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<StoneModel> getExploreStones() {
    return [
      StoneModel(
        id: 'emerald',
        name: 'Emerald',
        scientificName: 'Beryl (Be₃Al₂(SiO₃)₆)',
        category: 'Precious Gemstone',
        description: 'A precious green gemstone known for its vibrant color and spiritual properties.',
        imageUrl: 'assets/explore_photos/zumrut.png',
        hardness: 7.5,
        color: 'green',
        luster: 'Vitreous',
        formation: 'Hydrothermal',
        isPopular: true,
        element: 'Earth',
        chakra: 'Heart',
        zodiacSigns: ['Taurus', 'Gemini'],
      ),
      StoneModel(
        id: 'diamond',
        name: 'Diamond',
        scientificName: 'Carbon (C)',
        category: 'Precious Gemstone',
        description: 'The hardest natural substance, symbolizing purity and strength.',
        imageUrl: 'assets/explore_photos/elmas.png',
        hardness: 10.0,
        color: 'colorless to various colors',
        luster: 'Adamantine',
        formation: 'High pressure',
        isPopular: true,
        element: 'Fire',
        chakra: 'Crown',
        zodiacSigns: ['Aries', 'Leo'],
      ),
      StoneModel(
        id: 'ruby',
        name: 'Ruby',
        scientificName: 'Corundum (Al₂O₃)',
        category: 'Precious Gemstone',
        description: 'A red variety of corundum known for passion and vitality.',
        imageUrl: 'assets/explore_photos/yakut.png',
        hardness: 9.0,
        color: 'red',
        luster: 'Vitreous',
        formation: 'Metamorphic',
        isPopular: true,
        element: 'Fire',
        chakra: 'Root',
        zodiacSigns: ['Cancer', 'Leo', 'Scorpio'],
      ),
      StoneModel(
        id: 'sapphire',
        name: 'Sapphire',
        scientificName: 'Corundum (Al₂O₃)',
        category: 'Precious Gemstone',
        description: 'A precious gemstone known for wisdom and mental clarity.',
        imageUrl: 'assets/explore_photos/safir.png',
        hardness: 9.0,
        color: 'blue (most common), various colors',
        luster: 'Vitreous',
        formation: 'Metamorphic',
        isPopular: true,
        element: 'Water',
        chakra: 'Throat',
        zodiacSigns: ['Virgo', 'Libra', 'Sagittarius'],
      ),
      StoneModel(
        id: 'alexandrite',
        name: 'Alexandrite',
        scientificName: 'Chrysoberyl (BeAl₂O₄)',
        category: 'Rare Gemstone',
        description: 'A color-changing gemstone symbolizing balance and transformation.',
        imageUrl: 'assets/explore_photos/alexandrite.png',
        hardness: 8.5,
        color: 'green to red',
        luster: 'Vitreous',
        formation: 'Metamorphic',
        isPopular: true,
        element: 'Air',
        chakra: 'Heart',
        zodiacSigns: ['Gemini', 'Cancer'],
      ),
      StoneModel(
        id: 'tourmaline',
        name: 'Paraíba Tourmaline',
        scientificName: 'Tourmaline Group',
        category: 'Rare Gemstone',
        description: 'A vibrant blue-green tourmaline known for its electric vitality.',
        imageUrl: 'assets/explore_photos/turmalinpng.png',
        hardness: 7.0,
        color: 'wide variety of colors',
        luster: 'Vitreous',
        formation: 'Pegmatitic',
        isPopular: true,
        element: 'Water',
        chakra: 'Throat',
        zodiacSigns: ['Libra', 'Scorpio'],
      ),
    ];
  }
}