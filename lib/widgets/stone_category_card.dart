import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/crystal_colors.dart';

class StoneCategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;
  final bool isSelected;

  const StoneCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? CrystalColors.crystalTabGradient
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? null 
              : Border.all(
                  color: CrystalColors.primaryBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? CrystalColors.primaryBlue.withValues(alpha: 0.3)
                  : CrystalColors.stoneGray.withValues(alpha: 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2)
                    : CrystalColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: isSelected 
                    ? Colors.white
                    : CrystalColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white
                    : CrystalColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'igneous':
        return Icons.whatshot;
      case 'sedimentary':
        return Icons.layers;
      case 'metamorphic':
        return Icons.change_circle;
      case 'minerals':
        return Icons.diamond;
      case 'crystals':
        return Icons.auto_awesome;
      case 'gemstones':
        return Icons.star;
      default:
        return Icons.diamond;
    }
  }
}