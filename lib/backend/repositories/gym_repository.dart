import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/gym_model.dart';
import '../config/supabase_config.dart';
import 'base_repository.dart';

/// Repository for gym-related operations.
/// 
/// Handles gym discovery and management, including:
/// - Searching nearby gyms
/// - Gym details and amenities
/// - User gym membership
/// 
/// Example:
/// ```dart
/// final gymRepo = GymRepository();
/// 
/// // Search gyms by city
/// final gyms = await gymRepo.searchGyms(city: 'Mumbai');
/// 
/// // Get gym details
/// final gym = await gymRepo.getGymById('gym123');
/// ```
class GymRepository extends BaseRepository {
  GymRepository({
    super.database,
    super.storage,
    super.auth,
    super.realtime,
  });

  static const String _table = SupabaseTables.gyms;

  /// Get all gyms
  Future<List<GymModel>> getAllGyms({
    QueryOptions options = const QueryOptions(),
  }) async {
    return await database.fetchAll<GymModel>(
      table: _table,
      fromJson: GymModel.fromJson,
      orderBy: options.orderBy ?? 'name',
      ascending: options.ascending,
      limit: options.limit,
      offset: options.offset,
      filters: options.filters,
    );
  }

  /// Get paginated gym list
  Future<PaginatedResult<GymModel>> getGyms({
    int page = 1,
    int pageSize = 20,
    String? city,
    bool? isPartner,
  }) async {
    final filters = <String, dynamic>{};
    if (city != null) filters['city'] = city;
    if (isPartner != null) {
      filters['is_partner'] = isPartner;
    }

    var gyms = await getAllGyms(
      options: QueryOptions.paginated(
        page: page,
        pageSize: pageSize + 1,
        orderBy: 'name',
        filters: filters,
      ),
    );

    final hasMore = gyms.length > pageSize;
    if (hasMore) {
      gyms = gyms.take(pageSize).toList();
    }

    return PaginatedResult(
      items: gyms,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  /// Get a specific gym by ID
  Future<GymModel?> getGymById(String gymId) async {
    return await database.fetchById<GymModel>(
      table: _table,
      id: gymId,
      fromJson: GymModel.fromJson,
    );
  }

  /// Search gyms by name or city
  Future<List<GymModel>> searchGyms({
    String? query,
    String? city,
    List<String>? amenities,
  }) async {
    var gyms = await getAllGyms();

    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      gyms = gyms.where((g) {
        return g.name.toLowerCase().contains(lowerQuery) ||
            g.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (city != null) {
      gyms = gyms.where((g) => g.city.toLowerCase() == city.toLowerCase()).toList();
    }

    if (amenities != null && amenities.isNotEmpty) {
      gyms = gyms.where((g) {
        final gymAmenities = g.amenities ?? [];
        return amenities.every((a) => gymAmenities.contains(a));
      }).toList();
    }

    return gyms;
  }

  /// Get gyms by city
  Future<List<GymModel>> getGymsByCity(String city) async {
    return await database.fetchAll<GymModel>(
      table: _table,
      fromJson: GymModel.fromJson,
      column: 'city',
      equalTo: city,
      orderBy: 'name',
    );
  }

  /// Get partner gyms
  Future<List<GymModel>> getPartnerGyms({int limit = 10}) async {
    return await database.fetchAll<GymModel>(
      table: _table,
      fromJson: GymModel.fromJson,
      column: 'is_partner',
      equalTo: true,
      orderBy: 'name',
      limit: limit,
    );
  }

  /// Get available cities
  Future<List<String>> getAvailableCities() async {
    final gyms = await getAllGyms();
    final cities = gyms.map((g) => g.city).toSet().toList();
    cities.sort();
    return cities;
  }

  /// Get gym count by city
  Future<Map<String, int>> getGymCountByCity() async {
    final gyms = await getAllGyms();
    final counts = <String, int>{};
    
    for (final gym in gyms) {
      counts[gym.city] = (counts[gym.city] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Set user's preferred gym
  Future<void> setUserGym(String gymId) async {
    requireAuth();

    await database.update(
      table: SupabaseTables.users,
      id: currentUserId!,
      data: {'gym_id': gymId},
      fromJson: (json) => json,
    );
  }

  /// Get user's current gym
  Future<GymModel?> getUserGym() async {
    requireAuth();

    final userData = await database.fetchById(
      table: SupabaseTables.users,
      id: currentUserId!,
      fromJson: (json) => json,
    );

    if (userData == null || userData['gym_id'] == null) {
      return null;
    }

    return await getGymById(userData['gym_id']);
  }

  /// Subscribe to gym updates
  RealtimeChannel subscribeToGym({
    required String gymId,
    void Function(GymModel gym)? onUpdate,
  }) {
    return realtime.subscribeToRecord<GymModel>(
      table: _table,
      recordId: gymId,
      fromJson: GymModel.fromJson,
      onUpdate: onUpdate,
    );
  }
}
