import 'package:intl/intl.dart';

class AppUtils {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Number Formatting
  static String formatNumber(num number) {
    return NumberFormat('#,##0').format(number);
  }

  static String formatDecimal(num number, {int decimalPlaces = 1}) {
    return number.toStringAsFixed(decimalPlaces);
  }

  // Calorie Calculations
  static double calculateBMI(double weight, double height) {
    // height in cm, weight in kg
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static int calculateTDEE({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
    double multiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'lightly_active':
        multiplier = 1.375;
        break;
      case 'moderately_active':
        multiplier = 1.55;
        break;
      case 'very_active':
        multiplier = 1.725;
        break;
      case 'extra_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }

    return (bmr * multiplier).round();
  }

  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // Streak Calculation
  static int calculateStreak(List<DateTime> logDates) {
    if (logDates.isEmpty) return 0;

    logDates.sort((a, b) => b.compareTo(a));
    int streak = 1;
    DateTime currentDate = logDates[0];

    for (int i = 1; i < logDates.length; i++) {
      final diff = currentDate.difference(logDates[i]).inDays;
      if (diff == 1) {
        streak++;
        currentDate = logDates[i];
      } else if (diff > 1) {
        break;
      }
    }

    return streak;
  }
}
