class AppConstants {
  // App Info
  static const String appName = 'FitSync';
  static const String appVersion = '2.0';
  
  // API
  static const String baseUrl = 'https://api.fitsync.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserToken = 'user_token';
  static const String keyIsGuest = 'is_guest';
  static const String keyGuestSessionCount = 'guest_session_count';
  static const String keyIsPremium = 'is_premium';
  
  // Premium
  static const int premiumPriceINR = 399;
  static const double premiumPriceUSD = 4.99;
  static const int trialDurationDays = 14;
  
  // Free Tier Limits
  static const int freeMealLogsPerDay = 3;
  static const int freeWorkoutLogsPerDay = 1;
  
  // Guest Mode
  static const int guestModeSessionTrigger = 5;
  
  // Notifications
  static const int maxNotificationsPerDay = 4;
  
  // Streaks
  static const List<int> streakMilestones = [3, 7, 14, 21, 30, 60, 100];
}
