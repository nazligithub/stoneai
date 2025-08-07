import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'stone_discover_viewmodel.dart';
import '../../constants/crystal_colors.dart';
import '../../widgets/stone_card.dart';

class StoneDiscoverView extends StatelessWidget {
  const StoneDiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneDiscoverViewModel()..loadDiscoverData(),
      child: const _StoneDiscoverViewContent(),
    );
  }
}

class _StoneDiscoverViewContent extends StatelessWidget {
  const _StoneDiscoverViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<StoneDiscoverViewModel>(
      builder: (context, discoverViewModel, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: CrystalColors.backgroundLight,
            body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header with subtitle
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'discover.subtitle'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: CrystalColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Content
                if (discoverViewModel.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (discoverViewModel.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: CrystalColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            discoverViewModel.error ?? 'discover.error'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: CrystalColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final stone = discoverViewModel.allStones[index];
                          return StoneCard(
                            stone: stone,
                            onTap: () => discoverViewModel.navigateToStoneDetail(stone.id),
                          );
                        },
                        childCount: discoverViewModel.allStones.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}