import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';
import '../exceptions/backend_exception.dart';

/// Supabase Storage Service
/// 
/// Provides file storage functionality including:
/// - File uploads (from file, bytes, or path)
/// - File downloads
/// - Signed URLs for temporary access
/// - File deletion
/// 
/// Example:
/// ```dart
/// final storageService = SupabaseStorageService();
/// 
/// // Upload a file
/// final url = await storageService.uploadFile(
///   bucket: 'profile-images',
///   path: 'users/user123/avatar.jpg',
///   file: imageFile,
/// );
/// 
/// // Get signed URL
/// final signedUrl = await storageService.getSignedUrl(
///   bucket: 'profile-images',
///   path: 'users/user123/avatar.jpg',
/// );
/// ```
class SupabaseStorageService {
  SupabaseStorageService({SupabaseClient? client})
      : _client = client ?? BackendConfig.client;

  final SupabaseClient _client;

  SupabaseStorageClient get _storage => _client.storage;

  /// Maximum file size in bytes (10MB default)
  static const int defaultMaxFileSize = 10 * 1024 * 1024;

  /// Allowed image extensions
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

  /// Allowed video extensions
  static const List<String> videoExtensions = ['mp4', 'mov', 'avi', 'webm'];

  /// Upload a file from a File object
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
    FileOptions? fileOptions,
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Validate file size
      final fileSize = await file.length();
      final maxSize = maxFileSize ?? defaultMaxFileSize;
      if (fileSize > maxSize) {
        throw AppStorageException.fileTooLarge(maxSize);
      }

      // Validate file extension
      if (allowedExtensions != null) {
        final extension = path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          throw AppStorageException.invalidFileType(allowedExtensions);
        }
      }

      final bytes = await file.readAsBytes();
      return await _uploadBytes(
        bucket: bucket,
        path: path,
        bytes: bytes,
        fileOptions: fileOptions,
      );
    } catch (e) {
      if (e is AppStorageException) rethrow;
      throw AppStorageException.uploadFailed(path);
    }
  }

  /// Upload a file from bytes
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    FileOptions? fileOptions,
    int? maxFileSize,
  }) async {
    try {
      // Validate file size
      final maxSize = maxFileSize ?? defaultMaxFileSize;
      if (bytes.length > maxSize) {
        throw AppStorageException.fileTooLarge(maxSize);
      }

      return await _uploadBytes(
        bucket: bucket,
        path: path,
        bytes: bytes,
        fileOptions: fileOptions,
      );
    } catch (e) {
      if (e is AppStorageException) rethrow;
      throw AppStorageException.uploadFailed(path);
    }
  }

  Future<String> _uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    FileOptions? fileOptions,
  }) async {
    try {
      await _storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: fileOptions ?? const FileOptions(upsert: true),
          );

      return getPublicUrl(bucket: bucket, path: path);
    } on StorageException catch (e) {
      throw AppStorageException(
        message: e.message,
        originalError: e,
      );
    }
  }

  /// Get public URL for a file
  String getPublicUrl({
    required String bucket,
    required String path,
    TransformOptions? transform,
  }) {
    return _storage.from(bucket).getPublicUrl(
          path,
          transform: transform,
        );
  }

  /// Get a signed (temporary) URL for a file
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    Duration expiresIn = const Duration(hours: 1),
    TransformOptions? transform,
  }) async {
    try {
      return await _storage.from(bucket).createSignedUrl(
            path,
            expiresIn.inSeconds,
            transform: transform,
          );
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to get signed URL',
        originalError: e,
      );
    }
  }

  /// Download a file as bytes
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      return await _storage.from(bucket).download(path);
    } catch (e) {
      throw AppStorageException.downloadFailed(path);
    }
  }

  /// Delete a file
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _storage.from(bucket).remove([path]);
    } catch (e) {
      throw AppStorageException.deleteFailed(path);
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await _storage.from(bucket).remove(paths);
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to delete files',
        originalError: e,
      );
    }
  }

  /// List files in a bucket/folder
  Future<List<FileObject>> listFiles({
    required String bucket,
    String path = '',
    SearchOptions? searchOptions,
  }) async {
    try {
      return await _storage.from(bucket).list(
            path: path,
            searchOptions: searchOptions ?? const SearchOptions(),
          );
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to list files',
        originalError: e,
      );
    }
  }

  /// Move/rename a file
  Future<void> moveFile({
    required String bucket,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await _storage.from(bucket).move(fromPath, toPath);
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to move file',
        originalError: e,
      );
    }
  }

  /// Copy a file
  Future<void> copyFile({
    required String bucket,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await _storage.from(bucket).copy(fromPath, toPath);
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to copy file',
        originalError: e,
      );
    }
  }

  /// Generate a unique file path with timestamp
  String generateFilePath({
    required String folder,
    required String userId,
    required String originalFileName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return '$folder/$userId/${timestamp}_${originalFileName.replaceAll(' ', '_')}.$extension';
  }

  /// Get image URL with transformations
  String getImageUrl({
    required String bucket,
    required String path,
    int? width,
    int? height,
    int? quality,
  }) {
    return getPublicUrl(
      bucket: bucket,
      path: path,
      transform: TransformOptions(
        width: width,
        height: height,
        quality: quality,
      ),
    );
  }
}
