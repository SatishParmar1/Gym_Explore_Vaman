import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_realtime_service.dart';

/// Base repository providing common functionality.
/// 
/// All repositories should extend this class to get access
/// to shared services and utilities.
abstract class BaseRepository {
  final SupabaseDatabaseService database;
  final SupabaseStorageService storage;
  final SupabaseAuthService auth;
  final SupabaseRealtimeService realtime;

  BaseRepository({
    SupabaseDatabaseService? database,
    SupabaseStorageService? storage,
    SupabaseAuthService? auth,
    SupabaseRealtimeService? realtime,
  })  : database = database ?? SupabaseDatabaseService(),
        storage = storage ?? SupabaseStorageService(),
        auth = auth ?? SupabaseAuthService(),
        realtime = realtime ?? SupabaseRealtimeService();

  /// Get the current authenticated user's ID
  String? get currentUserId => auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => auth.isAuthenticated;

  /// Ensure user is authenticated before proceeding
  void requireAuth() {
    if (!isAuthenticated) {
      throw StateError('User must be authenticated to perform this action');
    }
  }
}

/// Pagination result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int? totalCount;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    this.totalCount,
    required this.hasMore,
  });

  /// Whether this is the first page
  bool get isFirstPage => page == 1;

  /// Whether there are items
  bool get hasItems => items.isNotEmpty;

  /// Total number of pages (if totalCount is available)
  int? get totalPages =>
      totalCount != null ? (totalCount! / pageSize).ceil() : null;
}

/// Query options for repository methods
class QueryOptions {
  final String? orderBy;
  final bool ascending;
  final int? limit;
  final int? offset;
  final Map<String, dynamic>? filters;

  const QueryOptions({
    this.orderBy,
    this.ascending = true,
    this.limit,
    this.offset,
    this.filters,
  });

  QueryOptions copyWith({
    String? orderBy,
    bool? ascending,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) {
    return QueryOptions(
      orderBy: orderBy ?? this.orderBy,
      ascending: ascending ?? this.ascending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      filters: filters ?? this.filters,
    );
  }

  /// Create options for pagination
  factory QueryOptions.paginated({
    required int page,
    int pageSize = 20,
    String? orderBy,
    bool ascending = true,
    Map<String, dynamic>? filters,
  }) {
    return QueryOptions(
      orderBy: orderBy,
      ascending: ascending,
      limit: pageSize,
      offset: (page - 1) * pageSize,
      filters: filters,
    );
  }
}
