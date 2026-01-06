import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/diet/diet_bloc.dart';
import '../../blocs/workout/workout_bloc.dart';
import 'widgets/gym_status_card.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/streak_card.dart';
import '../diet/diet_page.dart';
import '../workout/workout_page.dart';
import '../../../core/constants/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return BlocProvider(
          create: (context) => DietBloc(),
          child: const DietPage(),
        );
      case 2:
        return BlocProvider(
          create: (context) => WorkoutBloc(),
          child: const WorkoutPage(),
        );
      case 3:
        return _buildChallengesTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'LOADING...',
                  style: GoogleFonts.sairaExtraCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DashboardError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SOMETHING WENT WRONG',
                    style: GoogleFonts.sairaExtraCondensed(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DashboardBloc>().add(DashboardLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'RETRY',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(DashboardRefreshRequested());
              await Future.delayed(const Duration(seconds: 1));
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeHeader(),
                  const SizedBox(height: 20),

                  // Streak Counter
                  StreakCard(currentStreak: state.currentStreak),
                  const SizedBox(height: 20),

                  // Gym Status Card
                  if (state.gymStatus != null)
                    GymStatusCard(gymStatus: state.gymStatus!),
                  const SizedBox(height: 20),

                  // Quick Actions
                  const QuickActionsBar(),
                  const SizedBox(height: 20),

                  // Daily Progress
                  DailyProgressCard(progress: state.dailyProgress),
                  const SizedBox(height: 20),

                  // AI Recommendations (Premium)
                  if (state.aiRecommendations.isNotEmpty) ...[
                    Text(
                      'AI SPOTTER',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.aiRecommendations.map((rec) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.psychology,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: GoogleFonts.barlow(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }

        return Center(
          child: Text(
            'Welcome to FitSync!',
            style: GoogleFonts.sairaExtraCondensed(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final greeting = _getGreeting();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting.toUpperCase(),
              style: GoogleFonts.barlow(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state is AuthGuestMode ? 'CHAMPION' : 'CHAMPION',
              style: GoogleFonts.sairaExtraCondensed(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LET\'S CRUSH IT TODAY',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildChallengesTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.streakGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CHALLENGES',
              style: GoogleFonts.sairaExtraCondensed(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Text(
                'COMING SOON',
                style: GoogleFonts.sairaExtraCondensed(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Compete with fellow gym members\nand win exciting prizes',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlow(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Avatar with glow
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.fireGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state is AuthGuestMode ? 'GUEST USER' : 'FITSYNC MEMBER',
                style: GoogleFonts.sairaExtraCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  'LEVEL 1 • BEGINNER',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (state is AuthGuestMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to login
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: Text(
                      'SIGN IN TO SYNC DATA',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'EDIT PROFILE',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.fitness_center,
                title: 'MY GYM',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.workspace_premium,
                title: 'PREMIUM MEMBERSHIP',
                subtitle: 'Unlock all features',
                isPremium: true,
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'NOTIFICATIONS',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'SETTINGS',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline,
                title: 'HELP & SUPPORT',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              if (state is! AuthGuestMode)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: Handle logout
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      'LOG OUT',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isPremium = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.surfaceLight.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isPremium ? AppColors.accent : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.sairaExtraCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'FITSYNC';
      case 1:
        return 'DIET TRACKER';
      case 2:
        return 'WORKOUT';
      case 3:
        return 'CHALLENGES';
      case 4:
        return 'PROFILE';
      default:
        return 'FITSYNC';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.fireGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _getAppBarTitle(),
              style: GoogleFonts.sairaExtraCondensed(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedIndex == 0)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthGuestMode) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.fireGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate to login
                      },
                      icon: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                      label: Text(
                        'SIGN IN',
                        style: GoogleFonts.sairaExtraCondensed(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.fireGradient,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 4; // Go to profile
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surface,
                        child: Icon(Icons.person, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, color: AppColors.textMuted),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.restaurant_outlined, color: AppColors.textMuted),
              selectedIcon: const Icon(Icons.restaurant, color: AppColors.primary),
              label: 'Diet',
            ),
            NavigationDestination(
              icon: const Icon(Icons.fitness_center_outlined, color: AppColors.textMuted),
              selectedIcon: const Icon(Icons.fitness_center, color: AppColors.primary),
              label: 'Workout',
            ),
            NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined, color: AppColors.textMuted),
              selectedIcon: const Icon(Icons.emoji_events, color: AppColors.accent),
              label: 'Challenges',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, color: AppColors.textMuted),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
