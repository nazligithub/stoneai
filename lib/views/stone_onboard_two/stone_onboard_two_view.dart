import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'stone_onboard_two_viewmodel.dart';
import '../../../constants/crystal_colors.dart';
import '../../../constants/app_shadows.dart';

class StoneOnboardTwoView extends StatefulWidget {
  const StoneOnboardTwoView({super.key});

  @override
  State<StoneOnboardTwoView> createState() => _StoneOnboardTwoViewState();
}

class _StoneOnboardTwoViewState extends State<StoneOnboardTwoView>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _popupController;
  late Animation<double> _scanAnimation;
  late Animation<double> _popupAnimation;
  
  int _currentScanIndex = 0;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 1),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScanSequence();
    });
  }

  void _startAutoScanSequence() async {
    _isScanning = true;
    final viewModel = Provider.of<StoneOnboardTwoViewModel>(context, listen: false);
    
    while (_isScanning && mounted) {
      // Move scan frame to current stone position first
      if (!mounted) break;
      setState(() {
        // Frame moves to position but index stays same for this scan
      });
      
      // Wait for frame to move to position
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted || !_isScanning) break;
      
      // Reset and start scanning animation
      _scanController.reset();
      await _scanController.forward();
      if (!mounted || !_isScanning) break;
      
      // Show popup for current stone
      _popupController.reset();
      await _popupController.forward();
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
      
      // Check before reverse animation
      if (!mounted || !_isScanning) break;
      await _popupController.reverse();
      
      // Move to next stone
      if (!mounted || !_isScanning) break;
      setState(() {
        _currentScanIndex = (_currentScanIndex + 1) % viewModel.stones.length;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _isScanning = false;
    _scanController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoneOnboardTwoViewModel>(context);
    final screenSize = MediaQuery.of(context).size;
    final deviceHeight = screenSize.height;
    final deviceSizeRatio = _getDeviceSizeRatio(deviceHeight);

    return Scaffold(
      backgroundColor: CrystalColors.surface,
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
                          color: CrystalColors.surface,
                          borderRadius: BorderRadius.circular(30 * deviceSizeRatio),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30 * deviceSizeRatio),
                          child: Stack(
                            children: [
                              // Stone images with even spacing
                              // Stone 1
                              Positioned(
                                top: 80 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Image.asset(
                                    'assets/onboards/onboard_2/1.png',
                                    width: 90 * deviceSizeRatio,
                                    height: 90 * deviceSizeRatio,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Stone 2
                              Positioned(
                                top: 180 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Image.asset(
                                    'assets/onboards/onboard_2/2.png',
                                    width: 90 * deviceSizeRatio,
                                    height: 90 * deviceSizeRatio,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Stone 3
                              Positioned(
                                top: 280 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Image.asset(
                                    'assets/onboards/onboard_2/3.png',
                                    width: 90 * deviceSizeRatio,
                                    height: 90 * deviceSizeRatio,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Stone 4
                              Positioned(
                                top: 380 * deviceSizeRatio,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Image.asset(
                                    'assets/onboards/onboard_2/4.png',
                                    width: 90 * deviceSizeRatio,
                                    height: 90 * deviceSizeRatio,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Dynamic scan frame that moves to each stone
                              if (_currentScanIndex < viewModel.stones.length)
                                _buildMovingScanFrame(deviceSizeRatio, _currentScanIndex),
                              // Dynamic info popup in center of mockup
                              Center(
                                child: FadeTransition(
                                  opacity: _popupAnimation,
                                  child: Transform.translate(
                                    offset: Offset(0, 50 * (1 - _popupAnimation.value)),
                                    child: Container(
                                      width: 200 * deviceSizeRatio,
                                      padding: EdgeInsets.all(16 * deviceSizeRatio),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16 * deviceSizeRatio),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 12 * deviceSizeRatio,
                                            offset: Offset(0, 6 * deviceSizeRatio),
                                          ),
                                        ],
                                      ),
                                      child: _buildStoneInfo(_currentScanIndex, deviceSizeRatio),
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
                        color: CrystalColors.text,
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
                  onPressed: () => viewModel.onContinue(context),
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

  Widget _buildMovingScanFrame(double deviceSizeRatio, int stoneIndex) {
    // Define positions for each stone with even spacing
    List<double> stoneTops = [
      60 * deviceSizeRatio,   // Stone 1
      160 * deviceSizeRatio,   // Stone 2
      260 * deviceSizeRatio,  // Stone 3
      360 * deviceSizeRatio,  // Stone 4
    ];

    final currentTop = stoneTops[stoneIndex % stoneTops.length];
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      top: currentTop,
      left: 40 * deviceSizeRatio,
      right: 40 * deviceSizeRatio,
      child: Container(
        height: 110 * deviceSizeRatio,
        decoration: BoxDecoration(
          border: Border.all(
            color: CrystalColors.primaryLight,
            width: 3 * deviceSizeRatio,
          ),
          borderRadius: BorderRadius.circular(12 * deviceSizeRatio),
          boxShadow: [
            BoxShadow(
              color: CrystalColors.primaryLight.withValues(alpha: 0.3),
              blurRadius: 8 * deviceSizeRatio,
              spreadRadius: 2 * deviceSizeRatio,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Corner markers
            ..._buildFixedScanCorners(deviceSizeRatio),
            // Scan line animation
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * (110 * deviceSizeRatio - 3 * deviceSizeRatio),
                  left: 4 * deviceSizeRatio,
                  right: 4 * deviceSizeRatio,
                  child: Container(
                    height: 3 * deviceSizeRatio,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CrystalColors.primaryLight.withValues(alpha: 0.3),
                          CrystalColors.primaryLight,
                          CrystalColors.primaryLight.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2 * deviceSizeRatio),
                      boxShadow: [
                        BoxShadow(
                          color: CrystalColors.primaryLight.withValues(alpha: 0.5),
                          blurRadius: 4 * deviceSizeRatio,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoneInfo(int stoneIndex, double deviceSizeRatio) {
    final viewModel = Provider.of<StoneOnboardTwoViewModel>(context, listen: false);
    final stone = viewModel.stones[stoneIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.diamond,
              color: stone.color,
              size: 20 * deviceSizeRatio,
            ),
            SizedBox(width: 8 * deviceSizeRatio),
            Expanded(
              child: Text(
                stone.name,
                style: TextStyle(
                  fontSize: 16 * deviceSizeRatio,
                  fontWeight: FontWeight.bold,
                  color: stone.color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * deviceSizeRatio),
        Text(
          '${'onboard.step2.type_label'.tr()}: ${stone.type}',
          style: TextStyle(
            fontSize: 14 * deviceSizeRatio,
            color: stone.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4 * deviceSizeRatio),
        Text(
          '${'onboard.step2.status_label'.tr()}: ${stone.stoneStatus}',
          style: TextStyle(
            fontSize: 14 * deviceSizeRatio,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFixedScanCorners(double deviceSizeRatio) {
    final cornerSize = 20.0 * deviceSizeRatio;
    final cornerThickness = 3.0 * deviceSizeRatio;
    
    return [
      // Top left
      Positioned(
        top: 4 * deviceSizeRatio,
        left: 4 * deviceSizeRatio,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: CornerPainter(CornerPosition.topLeft, CrystalColors.primaryLight, cornerThickness),
          ),
        ),
      ),
      // Top right
      Positioned(
        top: 4 * deviceSizeRatio,
        right: 4 * deviceSizeRatio,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: CornerPainter(CornerPosition.topRight, CrystalColors.primaryLight, cornerThickness),
          ),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 4 * deviceSizeRatio,
        left: 4 * deviceSizeRatio,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: CornerPainter(CornerPosition.bottomLeft, CrystalColors.primaryLight, cornerThickness),
          ),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 4 * deviceSizeRatio,
        right: 4 * deviceSizeRatio,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(
            painter: CornerPainter(CornerPosition.bottomRight, CrystalColors.primaryLight, cornerThickness),
          ),
        ),
      ),
    ];
  }

  double _getDeviceSizeRatio(double screenHeight) {
    if (screenHeight <= 667) return 0.7;
    if (screenHeight <= 812) return 0.8;
    if (screenHeight <= 896) return 0.9;
    return 1.0;
  }
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class CornerPainter extends CustomPainter {
  final CornerPosition position;
  final Color color;
  final double thickness;

  CornerPainter(this.position, this.color, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cornerLength = size.width * 0.6;

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(cornerLength, 0);
        path.lineTo(0, 0);
        path.lineTo(0, cornerLength);
        break;
      case CornerPosition.topRight:
        path.moveTo(size.width - cornerLength, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, cornerLength);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, size.height - cornerLength);
        path.lineTo(0, size.height);
        path.lineTo(cornerLength, size.height);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width, size.height - cornerLength);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width - cornerLength, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}