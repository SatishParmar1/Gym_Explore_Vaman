import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';

/// Supabase Realtime Service
/// 
/// Provides real-time subscription functionality for:
/// - Table changes (INSERT, UPDATE, DELETE)
/// - Broadcast messages
/// - Presence tracking
/// 
/// Example:
/// ```dart
/// final realtimeService = SupabaseRealtimeService();
/// 
/// // Subscribe to workout changes
/// final subscription = realtimeService.subscribeToTable<WorkoutModel>(
///   table: 'workouts',
///   fromJson: WorkoutModel.fromJson,
///   userId: currentUser.id,
///   onInsert: (workout) => print('New workout: ${workout.workoutName}'),
///   onUpdate: (workout) => print('Updated: ${workout.workoutName}'),
/// );
/// 
/// // Don't forget to unsubscribe when done
/// subscription.cancel();
/// ```
class SupabaseRealtimeService {
  SupabaseRealtimeService({SupabaseClient? client})
      : _client = client ?? BackendConfig.client;

  final SupabaseClient _client;

  final Map<String, RealtimeChannel> _channels = {};

  /// Subscribe to changes on a specific table
  RealtimeChannel subscribeToTable<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String? userId,
    String? filterColumn,
    String? filterValue,
    void Function(T record)? onInsert,
    void Function(T newRecord, T? oldRecord)? onUpdate,
    void Function(T record)? onDelete,
    void Function(String event, T? newRecord, T? oldRecord)? onAny,
  }) {
    final channelName = _generateChannelName(table, userId);
    
    // Clean up existing channel if any
    if (_channels.containsKey(channelName)) {
      _channels[channelName]!.unsubscribe();
    }

    var channelBuilder = _client.channel(channelName);

    // Build the filter
    PostgresChangeFilter? filter;
    if (filterColumn != null && filterValue != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: filterColumn,
        value: filterValue,
      );
    } else if (userId != null) {
      filter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      );
    }

    channelBuilder = channelBuilder.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: filter,
      callback: (payload) {
        _handlePayload(
          payload: payload,
          fromJson: fromJson,
          onInsert: onInsert,
          onUpdate: onUpdate,
          onDelete: onDelete,
          onAny: onAny,
        );
      },
    );

    final channel = channelBuilder.subscribe();
    _channels[channelName] = channel;

    return channel;
  }

  /// Subscribe to a specific record's changes
  RealtimeChannel subscribeToRecord<T>({
    required String table,
    required String recordId,
    required T Function(Map<String, dynamic>) fromJson,
    String idColumn = 'id',
    void Function(T record)? onUpdate,
    void Function(T record)? onDelete,
  }) {
    return subscribeToTable<T>(
      table: table,
      fromJson: fromJson,
      filterColumn: idColumn,
      filterValue: recordId,
      onUpdate: (newRecord, _) => onUpdate?.call(newRecord),
      onDelete: onDelete,
    );
  }

  /// Subscribe to user-specific data changes
  RealtimeChannel subscribeToUserData<T>({
    required String table,
    required String userId,
    required T Function(Map<String, dynamic>) fromJson,
    void Function(T record)? onInsert,
    void Function(T newRecord, T? oldRecord)? onUpdate,
    void Function(T record)? onDelete,
  }) {
    return subscribeToTable<T>(
      table: table,
      fromJson: fromJson,
      filterColumn: 'user_id',
      filterValue: userId,
      onInsert: onInsert,
      onUpdate: onUpdate,
      onDelete: onDelete,
    );
  }

  /// Create a broadcast channel for sending/receiving messages
  RealtimeChannel createBroadcastChannel({
    required String channelName,
    required void Function(Map<String, dynamic> payload) onMessage,
    String event = 'message',
  }) {
    final channel = _client.channel(channelName).onBroadcast(
      event: event,
      callback: (payload) => onMessage(payload),
    ).subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  /// Send a broadcast message
  Future<void> sendBroadcast({
    required String channelName,
    required Map<String, dynamic> payload,
    String event = 'message',
  }) async {
    final channel = _channels[channelName];
    if (channel == null) {
      throw StateError('Channel $channelName not found. Subscribe first.');
    }

    await channel.sendBroadcastMessage(
      event: event,
      payload: payload,
    );
  }

  /// Create a presence channel for tracking online users
  RealtimeChannel createPresenceChannel({
    required String channelName,
    required Map<String, dynamic> userInfo,
    void Function(List<Map<String, dynamic>> onlineUsers)? onSync,
    void Function(Map<String, dynamic> newPresence)? onJoin,
    void Function(Map<String, dynamic> leftPresence)? onLeave,
  }) {
    final channel = _client.channel(channelName)
        .onPresenceSync((payload) {
          if (onSync != null) {
            final presenceChannel = _channels[channelName];
            if (presenceChannel != null) {
              final presences = presenceChannel.presenceState();
              final users = <Map<String, dynamic>>[];
              for (final presence in presences) {
                // Access presences list from each state
                for (final p in presence.presences) {
                  users.add(p.payload);
                }
              }
              onSync(users);
            }
          }
        })
        .onPresenceJoin((payload) {
          if (onJoin != null && payload.newPresences.isNotEmpty) {
            onJoin(payload.newPresences.first.payload);
          }
        })
        .onPresenceLeave((payload) {
          if (onLeave != null && payload.leftPresences.isNotEmpty) {
            onLeave(payload.leftPresences.first.payload);
          }
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _channels[channelName]?.track(userInfo);
          }
        });

    _channels[channelName] = channel;
    return channel;
  }

  /// Unsubscribe from a specific channel
  Future<void> unsubscribe(String channelName) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await channel.unsubscribe();
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    for (final channel in _channels.values) {
      await channel.unsubscribe();
    }
    _channels.clear();
  }

  /// Get active channel count
  int get activeChannelCount => _channels.length;

  /// Check if a channel is active
  bool isChannelActive(String channelName) => _channels.containsKey(channelName);

  void _handlePayload<T>({
    required PostgresChangePayload payload,
    required T Function(Map<String, dynamic>) fromJson,
    void Function(T record)? onInsert,
    void Function(T newRecord, T? oldRecord)? onUpdate,
    void Function(T record)? onDelete,
    void Function(String event, T? newRecord, T? oldRecord)? onAny,
  }) {
    T? newRecord;
    T? oldRecord;

    if (payload.newRecord.isNotEmpty) {
      newRecord = fromJson(payload.newRecord);
    }
    if (payload.oldRecord.isNotEmpty) {
      oldRecord = fromJson(payload.oldRecord);
    }

    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        if (newRecord != null) onInsert?.call(newRecord);
        break;
      case PostgresChangeEvent.update:
        if (newRecord != null) onUpdate?.call(newRecord, oldRecord);
        break;
      case PostgresChangeEvent.delete:
        if (oldRecord != null) onDelete?.call(oldRecord);
        break;
      default:
        break;
    }

    onAny?.call(
      payload.eventType.toString(),
      newRecord,
      oldRecord,
    );
  }

  String _generateChannelName(String table, String? userId) {
    if (userId != null) {
      return '${table}_$userId';
    }
    return table;
  }
}
