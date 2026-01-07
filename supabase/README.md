# Supabase Backend Setup

This document explains how to set up and configure the Supabase backend for FitSync/GymExplore.

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in:
   - Project name: `gymexplore` (or your preferred name)
   - Database password: (save this securely)
   - Region: Choose closest to your users
4. Wait for the project to be created (2-3 minutes)

## 2. Get Your API Keys

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon public key**: Used for client-side operations

## 3. Configure the Flutter App

1. Copy `.env.example` to `.env`:


2. Edit `.env` with your Supabase credentials:
   ```
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. **Important**: Add `.env` to `.gitignore` to keep credentials secure!

## 4. Set Up the Database

1. Go to **SQL Editor** in your Supabase Dashboard
2. Open the file `supabase/migrations/001_initial_schema.sql`
3. Copy and paste the entire contents into the SQL Editor
4. Click "Run" to execute

This will create all necessary:
- Tables (users, workouts, meals, gyms, challenges, etc.)
- Row Level Security policies
- Indexes for performance
- Triggers for auto-updating timestamps
- Functions for user creation

## 5. Set Up Storage Buckets

1. Go to **Storage** in your Supabase Dashboard
2. Create the following buckets:

| Bucket Name | Public | Description |
|-------------|--------|-------------|
| profile-images | Yes | User profile pictures |
| workout-images | No | Workout photos |
| meal-images | No | Meal photos |
| gym-images | Yes | Gym photos |
| exercise-videos | Yes | Exercise demonstration videos |

3. For each bucket, configure policies:

**For public buckets (profile-images, gym-images, exercise-videos):**
```sql
-- Allow public read access
CREATE POLICY "Public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- Allow authenticated users to upload their own files
CREATE POLICY "User upload access" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

**For private buckets (workout-images, meal-images):**
```sql
-- Allow users to access their own files
CREATE POLICY "User access own files" ON storage.objects
FOR ALL USING (
  bucket_id = 'workout-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## 6. Configure Authentication

### Email Authentication (Default)
Email auth is enabled by default. Configure in **Authentication** → **Providers** → **Email**.

### Google OAuth (Optional)
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials
3. In Supabase: **Authentication** → **Providers** → **Google**
4. Add your Client ID and Secret

### Apple OAuth (Optional, for iOS)
1. Configure in Apple Developer Portal
2. In Supabase: **Authentication** → **Providers** → **Apple**
3. Add your credentials

## 7. URL Configuration (for OAuth)

In **Authentication** → **URL Configuration**:

1. **Site URL**: Your app's deep link URL
   - Development: `http://localhost:3000`
   - Production: Your actual app URL

2. **Redirect URLs**: Add:
   - `io.supabase.gymexplore://login-callback/`
   - `io.supabase.gymexplore://reset-password/`

## 8. Android Setup

In `android/app/build.gradle.kts`, add:

```kotlin
android {
    defaultConfig {
        manifestPlaceholders["appAuthRedirectScheme"] = "io.supabase.gymexplore"
    }
}
```

## 9. iOS Setup

In `ios/Runner/Info.plist`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.gymexplore</string>
        </array>
    </dict>
</array>
```

## 10. Verify Setup

Run the app and check:
1. ✅ App initializes without errors
2. ✅ Auth state changes are detected
3. ✅ Can sign up with email
4. ✅ Can sign in with email
5. ✅ User profile is created in database
6. ✅ Can upload profile image

## Folder Structure

```
lib/backend/
├── backend.dart              # Main export file
├── config/
│   ├── backend_config.dart   # Initialization
│   └── supabase_config.dart  # Configuration & constants
├── services/
│   ├── supabase_auth_service.dart     # Authentication
│   ├── supabase_database_service.dart # Database operations
│   ├── supabase_storage_service.dart  # File storage
│   └── supabase_realtime_service.dart # Real-time subscriptions
├── repositories/
│   ├── base_repository.dart      # Base class
│   ├── user_repository.dart      # User operations
│   ├── workout_repository.dart   # Workout operations
│   ├── meal_repository.dart      # Meal operations
│   ├── gym_repository.dart       # Gym operations
│   └── challenge_repository.dart # Challenge operations
├── providers/
│   └── backend_providers.dart    # Dependency injection
└── exceptions/
    └── backend_exception.dart    # Custom exceptions
```

## Usage Examples

### Initialize Backend
```dart
import 'package:gymexplore/backend/backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await BackendConfig.initialize();
  
  // Setup dependency injection
  BackendProviders.setup();
  
  runApp(MyApp());
}
```

### Authentication
```dart
final authService = getIt<SupabaseAuthService>();

// Sign up
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign in
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Listen to auth changes
authService.authStateChanges.listen((state) {
  print('Auth state: ${state.event}');
});
```

### Database Operations
```dart
final userRepo = getIt<UserRepository>();
final workoutRepo = getIt<WorkoutRepository>();

// Get current user
final user = await userRepo.getCurrentUser();

// Log a workout
final workout = await workoutRepo.logWorkout(
  workoutName: 'Morning Run',
  workoutType: 'cardio',
  exercises: [],
  duration: 30,
  caloriesBurned: 250,
);

// Get workout history
final history = await workoutRepo.getWorkoutHistory(page: 1);
```

### Real-time Subscriptions
```dart
final workoutRepo = getIt<WorkoutRepository>();

// Subscribe to workout updates
final subscription = workoutRepo.subscribeToWorkouts(
  onInsert: (workout) => print('New workout!'),
  onUpdate: (newWorkout, oldWorkout) => print('Workout updated'),
);

// Don't forget to unsubscribe when done
subscription.unsubscribe();
```

## Troubleshooting

### "BackendConfig has not been initialized"
Make sure to call `BackendConfig.initialize()` before accessing any backend services.

### "User must be authenticated"
The operation requires authentication. Check `authService.isAuthenticated` first.

### "RLS policy violation"
Your Row Level Security policies might be blocking the operation. Check your policies in the Supabase Dashboard.

### "Storage upload failed"
1. Check bucket exists
2. Check storage policies
3. Check file size limits
4. Check allowed file types
