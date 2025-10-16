import 'package:flutter/material.dart';
import 'package:citizenship_app/screens/language_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _interpolateColor(Color start, Color end, double t) {
    return Color.lerp(start, end, t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Interpolate flag colors from vibrant to muted
          final blackColor = _interpolateColor(
            Colors.black,
            const Color(0xFF2B2B2B),
            _colorAnimation.value,
          );
          final redColor = _interpolateColor(
            const Color(0xFFDD0000),
            const Color(0xFF8B3A3A),
            _colorAnimation.value,
          );
          final goldColor = _interpolateColor(
            const Color(0xFFFFCC00),
            const Color(0xFFB8A066),
            _colorAnimation.value,
          );

          return Stack(
            children: [
              // German flag background with animated colors
              Column(
                children: [
                  Expanded(
                    child: Container(color: blackColor),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(color: redColor),
                    flex: 1,
                  ),
                  Expanded(
                    child: Container(color: goldColor),
                    flex: 1,
                  ),
                ],
              ),
              // Content overlay with slide animation
              Center(
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _colorAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Your German Journey Begins',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Master the Einbürgerungstest and embrace your future in Germany.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          MouseRegion(
                            onEnter: (_) => setState(() => _isHovering = true),
                            onExit: (_) => setState(() => _isHovering = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LanguageScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isHovering ? Colors.white : Colors.red,
                                  foregroundColor: _isHovering ? Colors.red : Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: _isHovering ? 8 : 4,
                                ),
                                child: const Text('BEGIN YOUR JOURNEY'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
