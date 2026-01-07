// Backend Module
//
// This module provides a centralized backend layer using Supabase.
// It follows clean architecture principles with separation of concerns.
//
// Structure:
// - `config/` - Configuration and initialization
// - `services/` - Supabase service wrappers (auth, database, storage)
// - `repositories/` - Data access layer with business logic
// - `providers/` - Dependency injection providers
//
// Usage:
//   import 'package:gymexplore/backend/backend.dart';
//
//   // Initialize backend
//   await BackendConfig.initialize();
//
//   // Access services
//   final user = await Backend.auth.signIn(email, password);

// Configuration
export 'config/backend_config.dart';
export 'config/supabase_config.dart';

// Services
export 'services/supabase_auth_service.dart';
export 'services/supabase_database_service.dart';
export 'services/supabase_storage_service.dart';
export 'services/supabase_realtime_service.dart';

// Repositories
export 'repositories/base_repository.dart';
export 'repositories/user_repository.dart';
export 'repositories/workout_repository.dart';
export 'repositories/meal_repository.dart';
export 'repositories/gym_repository.dart';
export 'repositories/challenge_repository.dart';

// Providers
export 'providers/backend_providers.dart';

// Exceptions
export 'exceptions/backend_exception.dart';
