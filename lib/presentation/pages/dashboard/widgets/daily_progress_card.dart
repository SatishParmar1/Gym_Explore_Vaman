import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class DailyProgressCard extends StatelessWidget {
  final Map<String, double> progress;

  const DailyProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final calories = progress['calories'] ?? 0.0;
    final targetCalories = progress['target_calories'] ?? 2000.0;
    final water = progress['water'] ?? 0.0;
    final targetWater = progress['target_water'] ?? 8.0;
    final protein = progress['protein'] ?? 0.0;
    final targetProtein = progress['target_protein'] ?? 120.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S PROGRESS',
                style: GoogleFonts.sairaExtraCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '${((calories / targetCalories) * 100).toInt()}%',
                  style: GoogleFonts.sairaExtraCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProgressBar(
            label: 'CALORIES',
            current: calories,
            target: targetCalories,
            color: AppColors.calories,
            icon: Icons.local_fire_department,
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'WATER',
            current: water,
            target: targetWater,
            color: AppColors.water,
            icon: Icons.water_drop,
            unit: 'glasses',
          ),
          const SizedBox(height: 20),
          _ProgressBar(
            label: 'PROTEIN',
            current: protein,
            target: targetProtein,
            color: AppColors.protein,
            icon: Icons.egg_alt,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final IconData icon;
  final String? unit;

  const _ProgressBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.icon,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.sairaExtraCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${current.toInt()}',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      ' / ${target.toInt()}${unit != null ? ' $unit' : ''}',
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.sairaExtraCondensed(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
