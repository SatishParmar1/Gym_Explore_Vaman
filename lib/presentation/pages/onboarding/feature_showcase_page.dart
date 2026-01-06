import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard/dashboard_page.dart';

class FeatureShowcasePage extends StatefulWidget {
  const FeatureShowcasePage({super.key});

  @override
  State<FeatureShowcasePage> createState() => _FeatureShowcasePageState();
}

class _FeatureShowcasePageState extends State<FeatureShowcasePage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  int _currentPage = 0;

  final List<FeatureItem> _features = [
    FeatureItem(
      icon: Icons.fitness_center,
      title: 'TRACK YOUR\nWORKOUTS',
      subtitle: 'Log sets, reps & weights with ease',
      description: 'AI-powered progressive overload suggestions',
      color: AppColors.primary,
      gradient: AppColors.fireGradient,
    ),
    FeatureItem(
      icon: Icons.restaurant_menu,
      title: 'FUEL YOUR\nGAINS',
      subtitle: 'Indian food database with 5000+ items',
      description: 'Voice logging • Smart calorie swapper',
      color: AppColors.success,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FeatureItem(
      icon: Icons.location_on,
      title: 'LIVE GYM\nSTATUS',
      subtitle: 'Know when your gym is empty',
      description: 'Equipment queue • Rush hour predictions',
      color: AppColors.info,
      gradient: const LinearGradient(
        colors: [Color(0xFF03A9F4), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FeatureItem(
      icon: Icons.emoji_events,
      title: 'COMPETE &\nWIN',
      subtitle: 'City leaderboards & gym challenges',
      description: '21-day transformation • Buddy challenges',
      color: AppColors.accent,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    FeatureItem(
      icon: Icons.camera_alt,
      title: 'PROGRESS\nPHOTOS',
      subtitle: 'Ghost camera overlay for comparison',
      description: 'Weekly rewind • Timelapse generator',
      color: AppColors.primaryLight,
      gradient: const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
            ),
          ),

          // Animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with skip button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'FITSYNC',
                            style: GoogleFonts.sairaExtraCondensed(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      // Skip button
                      TextButton(
                        onPressed: _navigateToDashboard,
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.barlow(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Feature cards
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      return _buildFeatureCard(_features[index], index);
                    },
                  ),
                ),

                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _features.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom action
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _navigateToDashboard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'START TRAINING',
                                style: GoogleFonts.sairaExtraCondensed(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward, size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Terms text
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Feature icon with animated glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: feature.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: feature.color.withOpacity(0.3 + _pulseController.value * 0.2),
                      blurRadius: 30 + _pulseController.value * 20,
                      spreadRadius: 5 + _pulseController.value * 5,
                    ),
                  ],
                ),
                child: Icon(
                  feature.icon,
                  size: 70,
                  color: Colors.white,
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            feature.title,
            style: GoogleFonts.sairaExtraCondensed(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 0.95,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            feature.subtitle,
            style: GoogleFonts.barlow(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description with icon chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Text(
              feature.description,
              style: GoogleFonts.barlow(
                fontSize: 14,
                color: feature.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Feature quick stats
          _buildFeatureStats(index),
        ],
      ),
    );
  }

  Widget _buildFeatureStats(int index) {
    final stats = [
      [
        ('500+', 'Exercises'),
        ('AI', 'Powered'),
        ('∞', 'Workouts'),
      ],
      [
        ('5000+', 'Indian Foods'),
        ('3 sec', 'Voice Log'),
        ('Smart', 'Swap'),
      ],
      [
        ('Live', 'Updates'),
        ('24/7', 'Status'),
        ('Rush', 'Predict'),
      ],
      [
        ('City', 'Ranks'),
        ('21', 'Day Challenge'),
        ('₹1L+', 'Prizes'),
      ],
      [
        ('Ghost', 'Overlay'),
        ('Weekly', 'Rewind'),
        ('Time', 'Lapse'),
      ],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats[index].map((stat) {
        return Column(
          children: [
            Text(
              stat.$1,
              style: GoogleFonts.sairaExtraCondensed(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              stat.$2,
              style: GoogleFonts.barlow(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Gradient gradient;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.gradient,
  });
}

// Custom painter for grid pattern background
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceLight.withOpacity(0.1)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
