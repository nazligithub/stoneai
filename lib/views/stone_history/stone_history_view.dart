import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'stone_history_viewmodel.dart';
import '../../viewmodels/stone_app_provider.dart';
import '../../constants/crystal_colors.dart';
import '../../widgets/stone_grid_item.dart';
import '../../services/stone_camera_service.dart';
import '../../constants/app_shadows.dart';

class StoneHistoryView extends StatelessWidget {
  const StoneHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoneHistoryViewModel()..loadHistory(),
      child: const _RockHistoryViewContent(),
    );
  }
}

class _RockHistoryViewContent extends StatefulWidget {
  const _RockHistoryViewContent();

  @override
  State<_RockHistoryViewContent> createState() =>
      _RockHistoryViewContentState();
}

class _RockHistoryViewContentState extends State<_RockHistoryViewContent>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for scroll to top requests and tab selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
      appProvider.addListener(_handleScrollToTop);
      appProvider.addListener(_handleTabSelection);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload history when app resumes
      if (mounted) {
        context.read<StoneHistoryViewModel>().loadHistory();
      }
    }
  }

  void _handleScrollToTop() {
    if (!mounted) return;

    final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
    if (appProvider.historyScrollToTopRequested &&
        _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTabSelection() {
    if (!mounted) return;

    final appProvider = Provider.of<StoneAppProvider>(context, listen: false);
    if (appProvider.historyTabSelected) {
      // Reload history when tab is selected
      debugPrint('StoneHistoryView: History tab selected - reloading history');
      context.read<StoneHistoryViewModel>().loadHistory();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StoneHistoryViewModel, StoneAppProvider>(
      builder: (context, historyViewModel, appProvider, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: CrystalColors.backgroundLight,
            body: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    backgroundColor: CrystalColors.backgroundLight,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 76,
                    titleSpacing: 20,
                    leading: null,
                    automaticallyImplyLeading: false,
                    title: Text(
                      'history.title'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: CrystalColors.textPrimary,
                      ),
                    ),
                  ),

                  if (historyViewModel.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: CrystalColors.primaryBlue,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else if (historyViewModel.hasError)
                    SliverFillRemaining(
                      child: _buildErrorState(historyViewModel),
                    )
                  else if (historyViewModel.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else ...[
                    _buildHistoryContent(historyViewModel),
                    const SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: 100,
                      ), // Space for bottom nav
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(StoneHistoryViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: CrystalColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: GoogleFonts.poppins(
                color: CrystalColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: CrystalColors.crystalTabGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: viewModel.loadHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text('history.error.try_again'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CrystalColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CrystalColors.primaryLight.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 64,
                color: CrystalColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'history.empty.title'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CrystalColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'history.empty.subtitle'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CrystalColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: CrystalColors.crystalTabGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppShadows.softShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: () => StoneCameraService.instance.openNativeCamera(
                  context: context,
                ),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text('history.empty.start_identifying'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(StoneHistoryViewModel viewModel) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final stone = viewModel.allHistory[index];
          return StoneGridItem(
            stone: stone,
            onTap: () => viewModel.navigateToStoneDetail(stone.id),
          );
        }, childCount: viewModel.allHistory.length),
      ),
    );
  }
}
