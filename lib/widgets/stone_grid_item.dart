import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stone_model.dart';
import '../constants/crystal_colors.dart';

class StoneGridItem extends StatelessWidget {
  final StoneModel stone;
  final VoidCallback onTap;
  final bool showFavorite;

  const StoneGridItem({
    super.key,
    required this.stone,
    required this.onTap,
    this.showFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.stoneGray.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          _getStoneColor(stone.color).withValues(alpha: 0.3),
                          _getStoneColor(stone.color).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: stone.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              stone.imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            )
                          : stone.imageUrl.startsWith('http')
                              ? Image.network(
                                  stone.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: _getStoneColor(stone.color),
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                )
                              : _buildImagePlaceholder(),
                    ),
                  ),
                  if (stone.isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CrystalColors.amberGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Popular',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (showFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: CrystalColors.rubyRed,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content container
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stone.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CrystalColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stone.category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: CrystalColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStoneColor(stone.color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStoneIcon(stone.category),
          size: 32,
          color: _getStoneColor(stone.color),
        ),
      ),
    );
  }

  Color _getStoneColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'clear':
      case 'white':
      case 'colorless to various colors':
        return CrystalColors.crystalWhite;
      case 'purple':
        return Colors.purple;
      case 'blue':
      case 'blue (most common), various colors':
        return CrystalColors.primaryBlue;
      case 'green':
      case 'green to red':
        return CrystalColors.gemGreen;
      case 'red':
        return CrystalColors.rubyRed;
      case 'yellow':
      case 'gold':
        return CrystalColors.amberGold;
      case 'brown':
        return CrystalColors.rockBrown;
      case 'gray':
      case 'grey':
        return CrystalColors.stoneGray;
      case 'wide variety of colors':
        return Colors.deepPurple;
      default:
        return CrystalColors.primaryBlue;
    }
  }

  IconData _getStoneIcon(String category) {
    switch (category.toLowerCase()) {
      case 'igneous':
        return Icons.whatshot;
      case 'sedimentary':
        return Icons.layers;
      case 'metamorphic':
        return Icons.change_circle;
      case 'silicate':
        return Icons.diamond;
      case 'gemstones':
        return Icons.diamond_outlined;
      case 'minerals':
        return Icons.category;
      case 'crystals':
        return Icons.auto_awesome;
      default:
        return Icons.diamond;
    }
  }
}