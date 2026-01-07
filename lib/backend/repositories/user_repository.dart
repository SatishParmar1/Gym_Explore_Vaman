import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_model.dart';
import '../config/supabase_config.dart';
import '../exceptions/backend_exception.dart';
import '../services/supabase_storage_service.dart';
import 'base_repository.dart';

/// Repository for user-related operations.
/// 
/// Handles user profile management, including:
/// - Creating and updating user profiles
/// - Profile image uploads
/// - User settings and preferences
/// 
/// Example:
/// ```dart
/// final userRepo = UserRepository();
/// 
/// // Get current user's profile
/// final user = await userRepo.getCurrentUser();
/// 
/// // Update profile
/// await userRepo.updateProfile(
///   name: 'John Doe',
///   weight: 75.5,
/// );
/// ```
class UserRepository extends BaseRepository {
  UserRepository({
    super.database,
    super.storage,
    super.auth,
    super.realtime,
  });

  static const String _table = SupabaseTables.users;
  static const String _profileImagesBucket = SupabaseBuckets.profileImages;

  /// Get the current authenticated user's profile
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated) return null;

    return await getUserById(currentUserId!);
  }

  /// Get a user by their ID
  Future<UserModel?> getUserById(String userId) async {
    return await database.fetchById<UserModel>(
      table: _table,
      id: userId,
      fromJson: UserModel.fromJson,
    );
  }

  /// Get a user by email
  Future<UserModel?> getUserByEmail(String email) async {
    return await database.fetchOne<UserModel>(
      table: _table,
      fromJson: UserModel.fromJson,
      column: 'email',
      value: email,
    );
  }

  /// Create a new user profile
  Future<UserModel> createUser({
    required String id,
    String? name,
    String? email,
    bool isGuest = false,
    Map<String, dynamic>? additionalData,
  }) async {
    final userData = {
      'id': id,
      'name': name,
      'email': email,
      'is_guest': isGuest,
      'created_at': DateTime.now().toIso8601String(),
      'last_login_at': DateTime.now().toIso8601String(),
      'current_streak': 0,
      'longest_streak': 0,
      'is_premium': false,
      ...?additionalData,
    };

    return await database.insert<UserModel>(
      table: _table,
      data: userData,
      fromJson: UserModel.fromJson,
    );
  }

  /// Create or update user profile (upsert)
  Future<UserModel> upsertUser(UserModel user) async {
    final userData = user.toJson();
    userData['last_login_at'] = DateTime.now().toIso8601String();

    return await database.upsert<UserModel>(
      table: _table,
      data: userData,
      fromJson: UserModel.fromJson,
      onConflict: 'id',
    );
  }

  /// Update the current user's profile
  Future<UserModel> updateCurrentUser({
    String? name,
    String? phone,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? targetWeight,
    String? goal,
    String? activityLevel,
    String? city,
    String? gymId,
  }) async {
    requireAuth();

    final updates = <String, dynamic>{};
    
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (age != null) updates['age'] = age;
    if (gender != null) updates['gender'] = gender;
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;
    if (targetWeight != null) updates['target_weight'] = targetWeight;
    if (goal != null) updates['goal'] = goal;
    if (activityLevel != null) updates['activity_level'] = activityLevel;
    if (city != null) updates['city'] = city;
    if (gymId != null) updates['gym_id'] = gymId;

    if (updates.isEmpty) {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw DatabaseException.notFound('User');
      }
      return currentUser;
    }

    return await database.update<UserModel>(
      table: _table,
      id: currentUserId!,
      data: updates,
      fromJson: UserModel.fromJson,
    );
  }

  /// Update user's profile image
  Future<String> updateProfileImage(File imageFile) async {
    requireAuth();

    final path = storage.generateFilePath(
      folder: 'users',
      userId: currentUserId!,
      originalFileName: 'profile.jpg',
    );

    final imageUrl = await storage.uploadFile(
      bucket: _profileImagesBucket,
      path: path,
      file: imageFile,
      allowedExtensions: SupabaseStorageService.imageExtensions,
    );

    // Update user record with new image URL
    await database.update<UserModel>(
      table: _table,
      id: currentUserId!,
      data: {'profile_image': imageUrl},
      fromJson: UserModel.fromJson,
    );

    return imageUrl;
  }

  /// Delete user's profile image
  Future<void> deleteProfileImage() async {
    requireAuth();

    final user = await getCurrentUser();
    if (user?.profileImage != null) {
      // Extract path from URL and delete
      try {
        await storage.deleteFile(
          bucket: _profileImagesBucket,
          path: 'users/$currentUserId/profile.jpg',
        );
      } catch (_) {
        // Ignore deletion errors
      }

      await database.update<UserModel>(
        table: _table,
        id: currentUserId!,
        data: {'profile_image': null},
        fromJson: UserModel.fromJson,
      );
    }
  }

  /// Update user's streak
  Future<UserModel> updateStreak({required int currentStreak}) async {
    requireAuth();

    final user = await getCurrentUser();
    final longestStreak = user != null && currentStreak > user.longestStreak
        ? currentStreak
        : user?.longestStreak ?? 0;

    return await database.update<UserModel>(
      table: _table,
      id: currentUserId!,
      data: {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
      },
      fromJson: UserModel.fromJson,
    );
  }

  /// Reset user's streak
  Future<UserModel> resetStreak() async {
    return await updateStreak(currentStreak: 0);
  }

  /// Increment user's streak
  Future<UserModel> incrementStreak() async {
    final user = await getCurrentUser();
    final newStreak = (user?.currentStreak ?? 0) + 1;
    return await updateStreak(currentStreak: newStreak);
  }

  /// Update premium status
  Future<UserModel> updatePremiumStatus({
    required bool isPremium,
    DateTime? expiryDate,
  }) async {
    requireAuth();

    return await database.update<UserModel>(
      table: _table,
      id: currentUserId!,
      data: {
        'is_premium': isPremium,
        'premium_expiry_date': expiryDate?.toIso8601String(),
      },
      fromJson: UserModel.fromJson,
    );
  }

  /// Update last login timestamp
  Future<void> updateLastLogin() async {
    if (!isAuthenticated) return;

    await database.update<UserModel>(
      table: _table,
      id: currentUserId!,
      data: {'last_login_at': DateTime.now().toIso8601String()},
      fromJson: UserModel.fromJson,
    );
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    requireAuth();

    // Delete profile image
    await deleteProfileImage();

    // Delete user record
    await database.delete(
      table: _table,
      id: currentUserId!,
    );

    // Sign out
    await auth.signOut();
  }

  /// Subscribe to real-time changes for current user
  RealtimeChannel subscribeToCurrentUser({
    void Function(UserModel user)? onUpdate,
  }) {
    requireAuth();

    return realtime.subscribeToRecord<UserModel>(
      table: _table,
      recordId: currentUserId!,
      fromJson: UserModel.fromJson,
      onUpdate: onUpdate,
    );
  }
}
