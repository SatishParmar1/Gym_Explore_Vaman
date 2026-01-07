/// Base exception class for all backend errors.
/// 
/// Provides a unified exception handling approach across the backend layer.
class BackendException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const BackendException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'BackendException: $message (code: $code)';
}

/// Exception thrown when authentication fails.
class AppAuthException extends BackendException {
  const AppAuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AppAuthException.invalidCredentials() => const AppAuthException(
        message: 'Invalid email or password',
        code: 'invalid_credentials',
      );

  factory AppAuthException.userNotFound() => const AppAuthException(
        message: 'User not found',
        code: 'user_not_found',
      );

  factory AppAuthException.emailAlreadyInUse() => const AppAuthException(
        message: 'Email is already registered',
        code: 'email_already_in_use',
      );

  factory AppAuthException.weakPassword() => const AppAuthException(
        message: 'Password is too weak',
        code: 'weak_password',
      );

  factory AppAuthException.sessionExpired() => const AppAuthException(
        message: 'Your session has expired. Please sign in again.',
        code: 'session_expired',
      );

  factory AppAuthException.notAuthenticated() => const AppAuthException(
        message: 'You must be signed in to perform this action',
        code: 'not_authenticated',
      );
}

/// Exception thrown when a database operation fails.
class DatabaseException extends BackendException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory DatabaseException.notFound(String resource) => DatabaseException(
        message: '$resource not found',
        code: 'not_found',
      );

  factory DatabaseException.duplicateEntry(String field) => DatabaseException(
        message: 'A record with this $field already exists',
        code: 'duplicate_entry',
      );

  factory DatabaseException.constraintViolation(String constraint) =>
      DatabaseException(
        message: 'Database constraint violation: $constraint',
        code: 'constraint_violation',
      );

  factory DatabaseException.queryFailed(String query, dynamic error) =>
      DatabaseException(
        message: 'Database query failed',
        code: 'query_failed',
        originalError: error,
      );
}

/// Exception thrown when a storage operation fails.
class AppStorageException extends BackendException {
  const AppStorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AppStorageException.uploadFailed(String filename) => AppStorageException(
        message: 'Failed to upload file: $filename',
        code: 'upload_failed',
      );

  factory AppStorageException.downloadFailed(String path) => AppStorageException(
        message: 'Failed to download file from: $path',
        code: 'download_failed',
      );

  factory AppStorageException.deleteFailed(String path) => AppStorageException(
        message: 'Failed to delete file: $path',
        code: 'delete_failed',
      );

  factory AppStorageException.fileTooLarge(int maxSize) => AppStorageException(
        message: 'File exceeds maximum size of ${maxSize ~/ (1024 * 1024)}MB',
        code: 'file_too_large',
      );

  factory AppStorageException.invalidFileType(List<String> allowedTypes) =>
      AppStorageException(
        message: 'Invalid file type. Allowed types: ${allowedTypes.join(', ')}',
        code: 'invalid_file_type',
      );
}

/// Exception thrown for network-related errors.
class NetworkException extends BackendException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection. Please check your network.',
        code: 'no_connection',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Request timed out. Please try again.',
        code: 'timeout',
      );

  factory NetworkException.serverError() => const NetworkException(
        message: 'Server error. Please try again later.',
        code: 'server_error',
      );
}
