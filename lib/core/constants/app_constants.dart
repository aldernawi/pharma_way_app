class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://pharmaway.ly/api';
  static const String storageUrl = 'https://pharmaway.ly';
  
  // App Info
  static const String appName = 'Pharma Way';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 50;
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Image Placeholders
  static const String productPlaceholder = 'images/product-placeholder.png';
  static const String companyPlaceholder = 'images/company-logo.png';
  static const String brandPlaceholder = 'images/brand-placeholder.png';
  
  // WhatsApp Support
  static const String supportWhatsApp = '218914638888';
  static const String supportMessage = 'مرحباً، أحتاج مساعدة في تطبيق Pharma Way';
}
