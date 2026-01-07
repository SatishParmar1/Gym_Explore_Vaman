import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Main backend configuration class.
/// 
/// Initializes all backend services and provides access to the Supabase client.
/// Call [initialize] before using any backend services.
class BackendConfig {
  BackendConfig._();

  static bool _isInitialized = false;
  static late SupabaseClient _supabaseClient;

  /// Whether the backend has been initialized
  static bool get isInitialized => _isInitialized;

  /// The Supabase client instance
  static SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'BackendConfig has not been initialized. '
        'Call BackendConfig.initialize() first.',
      );
    }
    return _supabaseClient;
  }

  /// Initialize the backend with Supabase
  /// 
  /// This should be called once at app startup, before using any backend services.
  /// 
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await BackendConfig.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize({
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool enableLogging = false,
  }) async {
    if (_isInitialized) {
      return;
    }

    // Load environment variables
    await dotenv.load(fileName: '.env');

    final url = supabaseUrl ?? SupabaseConfig.url;
    final anonKey = supabaseAnonKey ?? SupabaseConfig.anonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase URL and Anon Key must be provided. '
        'Check your .env file or pass them directly.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: enableLogging,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _supabaseClient = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Reset the backend configuration (useful for testing)
  static void reset() {
    _isInitialized = false;
  }
}
