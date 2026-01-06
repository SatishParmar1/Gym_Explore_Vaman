# FitSync - Gym Fitness App

A comprehensive gym and fitness tracking application built with Flutter, following MVVM architecture with BLoC state management.

## 🚀 Features (Based on JSON Specification)

### Core Features
- **Lazy Login Flow**: Guest mode with progressive onboarding
- **Live Gym Status**: Real-time gym occupancy tracking
- **Diet Tracking**: 
  - Voice-based meal logging
  - Indian food database (5000+ items)
  - Smart calorie swapper
  - Meal templates
  - Water tracker
- **Workout Logging**: 
  - Exercise library
  - Set tracking
  - Progress monitoring
- **Challenges**: Gamification with various challenge types
- **Social Features**: Gym-based social networking
- **Streaks & Rewards**: Daily streak tracking with milestones
- **AI Recommendations**: Personalized workout suggestions (Premium)

### Premium Features
- Unlimited logging
- AI recommendations
- Ghost camera & timelapse
- Form check AI
- Restaurant menu scanner
- Advanced analytics

## 📁 Project Structure (MVVM + BLoC)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # App-wide constants
│   │   └── app_colors.dart       # Color scheme
│   ├── theme/
│   │   └── app_theme.dart        # Material theme configuration
│   └── utils/
│       └── app_utils.dart        # Helper functions
│
├── data/
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── meal_model.dart
│   │   ├── workout_model.dart
│   │   ├── gym_model.dart
│   │   └── challenge_model.dart
│   ├── repositories/             # Data layer (TODO)
│   └── services/                 # API services (TODO)
│
├── presentation/
│   ├── blocs/                    # BLoC state management
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── dashboard/
│   │       ├── dashboard_bloc.dart
│   │       ├── dashboard_event.dart
│   │       └── dashboard_state.dart
│   │
│   └── pages/                    # UI screens
│       ├── splash/
│       │   └── splash_page.dart
│       └── dashboard/
│           ├── dashboard_page.dart
│           └── widgets/
│               ├── gym_status_card.dart
│               ├── quick_actions_bar.dart
│               ├── daily_progress_card.dart
│               └── streak_card.dart
│
└── main.dart                     # App entry point
```

## 🏗️ Architecture

### MVVM Pattern
- **Model**: Data models in `data/models/`
- **View**: UI screens in `presentation/pages/`
- **ViewModel**: BLoC classes in `presentation/blocs/`

### BLoC Pattern
- State management using flutter_bloc
- Separate Event, State, and BLoC files
- Clear separation of concerns

## 📦 Dependencies

### State Management
- `flutter_bloc` - BLoC pattern implementation
- `equatable` - Value equality

### Networking
- `dio` - HTTP client
- `pretty_dio_logger` - API logging

### Local Storage
- `shared_preferences` - Key-value storage

### Authentication
- `google_sign_in` - Google OAuth
- `firebase_core` - Firebase integration
- `firebase_auth` - Firebase authentication

### UI Components
- `google_fonts` - Custom fonts
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `lottie` - Lottie animations
- `fl_chart` - Charts and graphs

### Utilities
- `intl` - Internationalization
- `get_it` - Dependency injection
- `json_annotation` - JSON serialization
- `permission_handler` - Runtime permissions
- `image_picker` - Camera/gallery access
- `speech_to_text` - Voice input
- `url_launcher` - External URLs

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.0
- Dart SDK ^3.9.0

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd gymexplore
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 🎨 Design System

### Colors
- **Primary**: Purple (#6C5CE7)
- **Secondary**: Green (#00D9A3)
- **Gym Status Colors**:
  - Empty: Green (#00D9A3)
  - Moderate: Yellow (#FFBE0B)
  - Busy: Orange (#FF6B6B)
  - Packed: Dark Red (#8B0000)

### Typography
- Font Family: Poppins (via Google Fonts)

## 📱 Screens Implemented

### ✅ Completed
1. **Splash Screen**: Loading screen with app branding
2. **Dashboard**: 
   - Live gym status card
   - Quick action buttons (Meal, Workout, Photo, Water)
   - Daily progress bars (Calories, Water, Protein)
   - Streak counter
   - AI recommendations (Premium)
   - Bottom navigation (5 tabs)

### 🔜 TODO
3. **Diet Tracker**: Meal logging with voice input
4. **Workout Tracker**: Exercise logging
5. **Challenges**: View and join challenges
6. **Profile**: User profile and settings
7. **Login/Signup**: Authentication screens

## 🔑 Key Features Implementation Status

| Feature | Status |
|---------|--------|
| Splash Screen | ✅ Done |
| Dashboard UI | ✅ Done |
| Auth BLoC | ✅ Done |
| Dashboard BLoC | ✅ Done |
| Data Models | ✅ Done |
| Guest Mode | ✅ Done |
| Live Gym Status | ✅ UI Done |
| Quick Actions | ✅ UI Done |
| Progress Tracking | ✅ UI Done |
| Streak Counter | ✅ UI Done |
| Diet Logging | 🔜 TODO |
| Workout Logging | 🔜 TODO |
| Challenges | 🔜 TODO |
| Social Features | 🔜 TODO |
| Premium Features | 🔜 TODO |

## 🔧 Configuration

### API Base URL
Update in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://api.fitsync.com';
```

### Firebase Setup
1. Add `google-services.json` (Android) to `android/app/`
2. Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

## 📚 Next Steps

1. **Implement Repositories**: Create data repositories for API calls
2. **Add More BLoCs**: Diet, Workout, Challenge, Profile BLoCs
3. **Complete UI Screens**: Diet tracker, Workout logger, etc.
4. **API Integration**: Connect to backend services
5. **Firebase Setup**: Configure authentication
6. **Voice Input**: Implement speech-to-text for meal logging
7. **Camera Features**: Progress photos and ghost camera
8. **Premium Features**: Implement paywall and premium content

## 🤝 Contributing

This project follows:
- **Clean Architecture** principles
- **MVVM** pattern with **BLoC** state management
- **Material Design 3** guidelines
- **Flutter best practices**

## 📄 License

This project is private and confidential.

## 👥 Team

Development Phase 1 (MVP) - 12 weeks
- 2 Mobile Developers
- 2 Backend Developers
- 1 UI/UX Designer
- 1 QA Tester
- 1 Project Manager
