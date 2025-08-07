import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stone_onboard_one_viewmodel.dart';
import '../../../constants/crystal_colors.dart';
import '../../../constants/app_shadows.dart';

class StoneOnboardOneView extends StatefulWidget {
  const StoneOnboardOneView({super.key});

  @override
  State<StoneOnboardOneView> createState() => _StoneOnboardOneViewState();
}

class _StoneOnboardOneViewState extends State<StoneOnboardOneView>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _popupController;
  late Animation<double> _scanAnimation;
  late Animation<double> _popupAnimation;
  late Animation<Offset> _topPopupSlideAnimation;
  late Animation<Offset> _bottomPopupSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _popupController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    _popupAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOut,
    ));

    _topPopupSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOut,
    ));

    _bottomPopupSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOut,
    ));

    // Start animation sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _scanController.forward();
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _popupController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoneOnboardOneViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final deviceHeight = screenSize.height;
    final deviceSizeRatio = _getDeviceSizeRatio(deviceHeight);

    return Scaffold(
      backgroundColor: CrystalColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // iPhone mockup
                  Container(
                    width: 300 * deviceSizeRatio,
                    height: 600 * deviceSizeRatio,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40 * deviceSizeRatio),
                      boxShadow: AppShadows.elevatedShadow,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15 * deviceSizeRatio),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CrystalColors.backgroundLight,
                          borderRadius: BorderRadius.circular(30 * deviceSizeRatio),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30 * deviceSizeRatio),
                          child: Stack(
                            children: [
                              // Stone image - full cover
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/onboards/onboard_1/1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Scanner frame - centered
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SizedBox(
                                    width: 180 * deviceSizeRatio,
                                    height: 180 * deviceSizeRatio,
                                    child: Stack(
                                      children: [
                                        // Corner markers
                                        ..._buildCorners(deviceSizeRatio),
                                        // Scan line
                                        AnimatedBuilder(
                                          animation: _scanAnimation,
                                          builder: (context, child) {
                                            return Positioned(
                                              top: _scanAnimation.value * 180 * deviceSizeRatio,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 2,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Top popup
                              Positioned(
                                top: 100 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: SlideTransition(
                                  position: _topPopupSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _popupAnimation,
                                    child: Center(
                                      child: _PopupWidget(
                                        title: viewModel.detectedStone,
                                        isWarning: false,
                                        deviceSizeRatio: deviceSizeRatio,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom popup
                              Positioned(
                                bottom: 100 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: SlideTransition(
                                  position: _bottomPopupSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _popupAnimation,
                                    child: Center(
                                      child: _PopupWidget(
                                        title: viewModel.stoneStatus,
                                        isWarning: false,
                                        deviceSizeRatio: deviceSizeRatio,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title and subtitle below mockup
                  Text(
                    viewModel.title,
                    style: TextStyle(
                      fontSize: 22 * deviceSizeRatio,
                      fontWeight: FontWeight.bold,
                      color: CrystalColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      viewModel.subtitle,
                      style: TextStyle(
                        fontSize: 14 * deviceSizeRatio,
                        color: CrystalColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: CrystalColors.crystalTabGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: viewModel.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    viewModel.buttonTitle,
                    style: TextStyle(
                      fontSize: 18 * deviceSizeRatio,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  double _getDeviceSizeRatio(double screenHeight) {
    if (screenHeight <= 667) return 0.7; // iPhone SE, 8
    if (screenHeight <= 812) return 0.8; // iPhone X, 11 Pro
    if (screenHeight <= 896) return 0.9; // iPhone 11 Pro Max
    return 1.0; // iPhone 12 Pro Max and larger
  }

  List<Widget> _buildCorners(double deviceSizeRatio) {
    final cornerSize = 20.0 * deviceSizeRatio;
    return [
      // Top left
      Positioned(
        top: 0,
        left: 0,
        child: CustomPaint(
          size: Size(cornerSize, cornerSize),
          painter: CornerPainter(CornerPosition.topLeft),
        ),
      ),
      // Top right
      Positioned(
        top: 0,
        right: 0,
        child: CustomPaint(
          size: Size(cornerSize, cornerSize),
          painter: CornerPainter(CornerPosition.topRight),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 0,
        left: 0,
        child: CustomPaint(
          size: Size(cornerSize, cornerSize),
          painter: CornerPainter(CornerPosition.bottomLeft),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 0,
        right: 0,
        child: CustomPaint(
          size: Size(cornerSize, cornerSize),
          painter: CornerPainter(CornerPosition.bottomRight),
        ),
      ),
    ];
  }
}

class _PopupWidget extends StatelessWidget {
  final String title;
  final bool isWarning;
  final double deviceSizeRatio;

  const _PopupWidget({
    required this.title,
    required this.isWarning,
    required this.deviceSizeRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * deviceSizeRatio,
        vertical: 10 * deviceSizeRatio,
      ),
      constraints: BoxConstraints(
        minWidth: 180 * deviceSizeRatio,
        maxWidth: 220 * deviceSizeRatio,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * deviceSizeRatio),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4 * deviceSizeRatio,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.warning_amber_rounded,
            color: isWarning ? Colors.red : Colors.orange,
            size: 20 * deviceSizeRatio,
          ),
          SizedBox(width: 8 * deviceSizeRatio),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14 * deviceSizeRatio,
                fontWeight: FontWeight.w600,
                color: isWarning ? Colors.red : Colors.orange,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class CornerPainter extends CustomPainter {
  final CornerPosition position;

  CornerPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(size.width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
      case CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}