import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration loaded from environment variables.
/// 
/// Uses flutter_dotenv to load configuration from .env file.
/// Make sure to add .env to .gitignore to keep credentials secure.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key for client-side operations
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Supabase service role key (for server-side/admin operations only)
  /// This should NEVER be exposed to the client in production
  static String get serviceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  /// Validate that required configuration is present
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;

  /// Configuration validation with detailed error messages
  static void validate() {
    final errors = <String>[];
    
    if (url.isEmpty) {
      errors.add('SUPABASE_URL is not set');
    }
    if (anonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY is not set');
    }
    
    if (errors.isNotEmpty) {
      throw StateError(
        'Supabase configuration is invalid:\n${errors.join('\n')}\n'
        'Please check your .env file.',
      );
    }
  }
}

/// Database table names used throughout the app.
/// 
/// Centralizing table names prevents typos and makes refactoring easier.
class SupabaseTables {
  SupabaseTables._();

  static const String users = 'users';
  static const String workouts = 'workouts';
  static const String exercises = 'exercises';
  static const String exerciseLogs = 'exercise_logs';
  static const String sets = 'sets';
  static const String meals = 'meals';
  static const String mealItems = 'meal_items';
  static const String gyms = 'gyms';
  static const String challenges = 'challenges';
  static const String challengeParticipants = 'challenge_participants';
  static const String userProgress = 'user_progress';
  static const String userStreaks = 'user_streaks';
  static const String notifications = 'notifications';
}

/// Storage bucket names
class SupabaseBuckets {
  SupabaseBuckets._();

  static const String profileImages = 'profile-images';
  static const String workoutImages = 'workout-images';
  static const String mealImages = 'meal-images';
  static const String gymImages = 'gym-images';
  static const String exerciseVideos = 'exercise-videos';
}
