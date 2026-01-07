import 'package:get_it/get_it.dart';

import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';
import '../services/supabase_realtime_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/workout_repository.dart';
import '../repositories/meal_repository.dart';
import '../repositories/gym_repository.dart';
import '../repositories/challenge_repository.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Backend providers for dependency injection.
/// 
/// This class sets up all backend services and repositories
/// using the GetIt service locator pattern.
/// 
/// Example:
/// ```dart
/// // Initialize providers
/// BackendProviders.setup();
/// 
/// // Access services anywhere
/// final userRepo = getIt<UserRepository>();
/// final user = await userRepo.getCurrentUser();
/// ```
class BackendProviders {
  BackendProviders._();

  static bool _isInitialized = false;

  /// Whether providers have been initialized
  static bool get isInitialized => _isInitialized;

  /// Setup all backend providers
  /// 
  /// Call this once after BackendConfig.initialize()
  static void setup() {
    if (_isInitialized) return;

    // Register services as singletons
    _registerServices();

    // Register repositories as factories (new instance each time)
    // or lazy singletons (single instance, created on first access)
    _registerRepositories();

    _isInitialized = true;
  }

  static void _registerServices() {
    // Auth service - singleton for consistent auth state
    getIt.registerLazySingleton<SupabaseAuthService>(
      () => SupabaseAuthService(),
    );

    // Database service - singleton for connection pooling
    getIt.registerLazySingleton<SupabaseDatabaseService>(
      () => SupabaseDatabaseService(),
    );

    // Storage service - singleton
    getIt.registerLazySingleton<SupabaseStorageService>(
      () => SupabaseStorageService(),
    );

    // Realtime service - singleton to manage subscriptions
    getIt.registerLazySingleton<SupabaseRealtimeService>(
      () => SupabaseRealtimeService(),
    );
  }

  static void _registerRepositories() {
    // User repository
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(
        database: getIt<SupabaseDatabaseService>(),
        storage: getIt<SupabaseStorageService>(),
        auth: getIt<SupabaseAuthService>(),
        realtime: getIt<SupabaseRealtimeService>(),
      ),
    );

    // Workout repository
    getIt.registerLazySingleton<WorkoutRepository>(
      () => WorkoutRepository(
        database: getIt<SupabaseDatabaseService>(),
        storage: getIt<SupabaseStorageService>(),
        auth: getIt<SupabaseAuthService>(),
        realtime: getIt<SupabaseRealtimeService>(),
      ),
    );

    // Meal repository
    getIt.registerLazySingleton<MealRepository>(
      () => MealRepository(
        database: getIt<SupabaseDatabaseService>(),
        storage: getIt<SupabaseStorageService>(),
        auth: getIt<SupabaseAuthService>(),
        realtime: getIt<SupabaseRealtimeService>(),
      ),
    );

    // Gym repository
    getIt.registerLazySingleton<GymRepository>(
      () => GymRepository(
        database: getIt<SupabaseDatabaseService>(),
        storage: getIt<SupabaseStorageService>(),
        auth: getIt<SupabaseAuthService>(),
        realtime: getIt<SupabaseRealtimeService>(),
      ),
    );

    // Challenge repository
    getIt.registerLazySingleton<ChallengeRepository>(
      () => ChallengeRepository(
        database: getIt<SupabaseDatabaseService>(),
        storage: getIt<SupabaseStorageService>(),
        auth: getIt<SupabaseAuthService>(),
        realtime: getIt<SupabaseRealtimeService>(),
      ),
    );
  }

  /// Reset all providers (useful for testing)
  static Future<void> reset() async {
    if (!_isInitialized) return;
    
    await getIt.reset();
    _isInitialized = false;
  }

  /// Get a registered service or repository
  static T get<T extends Object>() => getIt<T>();

  /// Check if a service is registered
  static bool isRegistered<T extends Object>() => getIt.isRegistered<T>();
}

/// Convenience getters for common services
extension BackendAccess on BackendProviders {
  /// Quick access to auth service
  static SupabaseAuthService get auth => getIt<SupabaseAuthService>();

  /// Quick access to database service
  static SupabaseDatabaseService get database => getIt<SupabaseDatabaseService>();

  /// Quick access to storage service
  static SupabaseStorageService get storage => getIt<SupabaseStorageService>();

  /// Quick access to realtime service
  static SupabaseRealtimeService get realtime => getIt<SupabaseRealtimeService>();

  /// Quick access to user repository
  static UserRepository get users => getIt<UserRepository>();

  /// Quick access to workout repository
  static WorkoutRepository get workouts => getIt<WorkoutRepository>();

  /// Quick access to meal repository
  static MealRepository get meals => getIt<MealRepository>();

  /// Quick access to gym repository
  static GymRepository get gyms => getIt<GymRepository>();

  /// Quick access to challenge repository
  static ChallengeRepository get challenges => getIt<ChallengeRepository>();
}
