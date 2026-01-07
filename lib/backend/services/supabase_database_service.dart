import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';
import '../exceptions/backend_exception.dart';

/// Supabase Database Service
/// 
/// Provides a type-safe wrapper around Supabase database operations.
/// Supports CRUD operations, filtering, pagination, and real-time updates.
/// 
/// Example:
/// ```dart
/// final dbService = SupabaseDatabaseService();
/// 
/// // Fetch all users
/// final users = await dbService.fetchAll<UserModel>(
///   table: 'users',
///   fromJson: UserModel.fromJson,
/// );
/// 
/// // Insert a record
/// await dbService.insert(
///   table: 'workouts',
///   data: workout.toJson(),
/// );
/// ```
class SupabaseDatabaseService {
  SupabaseDatabaseService({SupabaseClient? client})
      : _client = client ?? BackendConfig.client;

  final SupabaseClient _client;

  /// Reference to the Supabase database
  SupabaseClient get db => _client;

  /// Fetch all records from a table with optional filtering
  Future<List<T>> fetchAll<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String? column,
    dynamic equalTo,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    try {
      PostgrestFilterBuilder query = _client.from(table).select();

      // Apply equality filter
      if (column != null && equalTo != null) {
        query = query.eq(column, equalTo);
      }

      // Apply additional filters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      // Build the final query with ordering and pagination
      PostgrestTransformBuilder finalQuery = query;

      // Apply ordering
      if (orderBy != null) {
        finalQuery = finalQuery.order(orderBy, ascending: ascending);
      }

      // Apply pagination
      if (limit != null) {
        if (offset != null) {
          finalQuery = finalQuery.range(offset, offset + limit - 1);
        } else {
          finalQuery = finalQuery.limit(limit);
        }
      }

      final response = await finalQuery;
      return (response as List).map((json) => fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch records: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Fetch a single record by ID
  Future<T?> fetchById<T>({
    required String table,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
    String idColumn = 'id',
  }) async {
    try {
      final response = await _client
          .from(table)
          .select()
          .eq(idColumn, id)
          .maybeSingle();

      if (response == null) return null;
      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Fetch a single record with custom query
  Future<T?> fetchOne<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    required String column,
    required dynamic value,
  }) async {
    try {
      final response = await _client
          .from(table)
          .select()
          .eq(column, value)
          .maybeSingle();

      if (response == null) return null;
      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Insert a new record
  Future<T> insert<T>({
    required String table,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _client
          .from(table)
          .insert(data)
          .select()
          .single();

      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to insert record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Insert multiple records
  Future<List<T>> insertMany<T>({
    required String table,
    required List<Map<String, dynamic>> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _client
          .from(table)
          .insert(data)
          .select();

      return (response as List).map((json) => fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to insert records: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update a record by ID
  Future<T> update<T>({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
    String idColumn = 'id',
  }) async {
    try {
      final response = await _client
          .from(table)
          .update(data)
          .eq(idColumn, id)
          .select()
          .single();

      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update records matching a filter
  Future<List<T>> updateWhere<T>({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _client
          .from(table)
          .update(data)
          .eq(column, value)
          .select();

      return (response as List).map((json) => fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to update records: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Upsert (insert or update) a record
  Future<T> upsert<T>({
    required String table,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
    String? onConflict,
  }) async {
    try {
      final response = await _client
          .from(table)
          .upsert(data, onConflict: onConflict)
          .select()
          .single();

      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to upsert record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a record by ID
  Future<void> delete({
    required String table,
    required String id,
    String idColumn = 'id',
  }) async {
    try {
      await _client.from(table).delete().eq(idColumn, id);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to delete record: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete records matching a filter
  Future<void> deleteWhere({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to delete records: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Count records in a table
  Future<int> count({
    required String table,
    String? column,
    dynamic equalTo,
  }) async {
    try {
      final response = await _client
          .from(table)
          .select()
          .count(CountOption.exact);

      if (column != null && equalTo != null) {
        final filteredResponse = await _client
            .from(table)
            .select()
            .eq(column, equalTo)
            .count(CountOption.exact);
        return filteredResponse.count;
      }

      return response.count;
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'Failed to count records: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Execute a raw SQL query via RPC
  Future<T> rpc<T>({
    required String functionName,
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _client.rpc(functionName, params: params);
      return fromJson(response);
    } on PostgrestException catch (e) {
      throw _mapDatabaseException(e);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        message: 'RPC call failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Map Supabase database exceptions to our custom exceptions
  DatabaseException _mapDatabaseException(PostgrestException e) {
    if (e.code == '23505') {
      return DatabaseException.duplicateEntry('record');
    }
    if (e.code == '23503') {
      return DatabaseException.constraintViolation(e.message);
    }
    if (e.code == 'PGRST116') {
      return DatabaseException.notFound('Record');
    }
    return DatabaseException(
      message: e.message,
      code: e.code,
      originalError: e,
    );
  }
}
