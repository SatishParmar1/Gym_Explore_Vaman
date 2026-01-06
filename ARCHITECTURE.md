# Architecture Documentation

## Overview

FitSync follows **MVVM (Model-View-ViewModel)** architecture pattern with **BLoC (Business Logic Component)** for state management. This ensures:
- Clear separation of concerns
- Testability
- Maintainability
- Scalability

## Architecture Layers

### 1. Presentation Layer (`presentation/`)
Handles UI and user interactions.

#### Components:
- **Pages**: Full-screen UI views
- **Widgets**: Reusable UI components
- **BLoCs**: Business logic and state management

#### Example Flow:
```
User Action → Event → BLoC → State → UI Update
```

### 2. Domain Layer (Future)
Business logic and use cases (to be implemented).

#### Will contain:
- Use cases
- Business rules
- Domain models

### 3. Data Layer (`data/`)
Handles data operations.

#### Components:
- **Models**: Data structures with JSON serialization
- **Repositories**: Abstract data sources
- **Services**: API clients, local storage

## BLoC Pattern

### Why BLoC?
- Predictable state management
- Easy testing
- Separation of business logic from UI
- Reactive programming with streams

### BLoC Structure

Each BLoC has three files:

#### 1. Events (`*_event.dart`)
User actions or system events:
```dart
abstract class AuthEvent extends Equatable {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  // ...
}
```

#### 2. States (`*_state.dart`)
UI states:
```dart
abstract class AuthState extends Equatable {}

class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
}
class AuthError extends AuthState {
  final String message;
}
```

#### 3. BLoC (`*_bloc.dart`)
Business logic:
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Business logic here
    emit(AuthAuthenticated(user: user));
  }
}
```

## Data Flow

### User Login Example:

```
1. User taps "Login" button
   ↓
2. UI dispatches AuthLoginRequested event
   ↓
3. AuthBloc receives event
   ↓
4. AuthBloc emits AuthLoading state
   ↓
5. UI shows loading indicator
   ↓
6. AuthBloc calls Repository
   ↓
7. Repository calls API Service
   ↓
8. Service returns data
   ↓
9. Repository processes data
   ↓
10. AuthBloc emits AuthAuthenticated state
   ↓
11. UI navigates to Dashboard
```

## Models

### Data Models
Located in `data/models/`, these represent API responses and database entities.

```dart
@JsonSerializable()
class UserModel extends Equatable {
  final String? id;
  final String? name;
  // ...

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

### Key Features:
- Immutable (using `const` constructors)
- Equatable for value comparison
- JSON serialization with `json_serializable`
- `copyWith` method for updates

## Dependency Injection

### Using GetIt (Service Locator Pattern)

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Singletons
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());

  // Factories
  getIt.registerFactory<AuthRepository>(() => AuthRepository(
    apiService: getIt<ApiService>(),
  ));

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    repository: getIt<AuthRepository>(),
  ));
}
```

## State Management Best Practices

### 1. Immutable States
Always use immutable state objects:
```dart
class DashboardLoaded extends DashboardState {
  final UserModel user;
  final int streak;

  const DashboardLoaded({
    required this.user,
    required this.streak,
  });
}
```

### 2. Event Naming
- Use past tense: `LoginRequested`, `DataFetched`
- Be specific: `DashboardRefreshRequested` not `Refresh`

### 3. State Naming
- Use present tense: `Loading`, `Loaded`, `Error`
- Describe UI state clearly

### 4. BLoC Responsibilities
- One BLoC per feature
- Keep BLoCs focused
- Don't share BLoCs across unrelated features

## Error Handling

### Strategy:
```dart
try {
  final data = await repository.fetchData();
  emit(DataLoaded(data: data));
} catch (e) {
  if (e is NetworkException) {
    emit(DataError(message: 'No internet connection'));
  } else if (e is ServerException) {
    emit(DataError(message: 'Server error. Please try again.'));
  } else {
    emit(DataError(message: 'Something went wrong'));
  }
}
```

### Error States:
- Always provide user-friendly messages
- Include retry mechanisms
- Log errors for debugging

## Testing Strategy

### Unit Tests
Test BLoC logic:
```dart
blocTest<AuthBloc, AuthState>(
  'emits [Loading, Authenticated] when login succeeds',
  build: () => AuthBloc(),
  act: (bloc) => bloc.add(AuthLoginRequested(email: 'test@test.com')),
  expect: () => [
    AuthLoading(),
    AuthAuthenticated(user: mockUser),
  ],
);
```

### Widget Tests
Test UI components:
```dart
testWidgets('Dashboard shows gym status', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Live Gym Status'), findsOneWidget);
});
```

### Integration Tests
Test complete flows:
```dart
testWidgets('User can log in', (tester) async {
  // Test complete login flow
});
```

## Performance Optimization

### 1. BLoC Optimization
- Close BLoCs when not needed
- Use `BlocProvider.value` for existing BLoCs
- Avoid creating new BLoCs in build methods

### 2. Widget Optimization
- Use `const` constructors
- Implement `shouldRebuild` in BlocBuilder
- Use `BlocSelector` for granular rebuilds

### 3. State Optimization
```dart
BlocBuilder<DashboardBloc, DashboardState>(
  buildWhen: (previous, current) {
    // Only rebuild if relevant data changed
    return previous.streak != current.streak;
  },
  builder: (context, state) {
    return StreakWidget(streak: state.streak);
  },
)
```

## Navigation

### Using Named Routes:
```dart
// Define routes
class AppRoutes {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const diet = '/diet';
  // ...
}

// Navigate
Navigator.pushNamed(context, AppRoutes.dashboard);
```

### Using Go Router (Recommended):
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardPage(),
    ),
  ],
);
```

## Best Practices

### 1. Code Organization
- One class per file
- Group related files in folders
- Use meaningful names

### 2. BLoC Guidelines
- Keep BLoCs simple and focused
- Don't emit states in other states
- Always close streams
- Handle all possible states in UI

### 3. Model Guidelines
- Make models immutable
- Use value objects for complex types
- Validate data in constructors

### 4. UI Guidelines
- Separate widgets into files when > 100 lines
- Use composition over inheritance
- Extract reusable widgets

### 5. Testing Guidelines
- Test all BLoC logic
- Test critical UI paths
- Mock external dependencies

## Future Enhancements

### 1. Clean Architecture
Add domain layer with:
- Use cases
- Entities
- Repository interfaces

### 2. Advanced State Management
Consider:
- Riverpod (alternative to BLoC)
- Redux
- MobX

### 3. Offline-First
Implement:
- Local database (Drift/Isar)
- Sync mechanism
- Conflict resolution

### 4. Real-time Updates
Add:
- WebSocket support
- Firebase Realtime Database
- Push notifications

## Resources

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)

## Conclusion

This architecture provides:
- ✅ Separation of concerns
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability
- ✅ Clear data flow
- ✅ Predictable state management

Follow these patterns consistently for a robust, maintainable codebase.
