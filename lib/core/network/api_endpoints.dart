class ApiEndpoints {
  // Base
  static const String baseUrl = 'https://pharmaway.ly/api';
  
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String profile = '/profile';
  
  // Products
  static const String products = '/products';
  static String productById(int id) => '/products/$id';
  static const String productSearch = '/products/search';
  static String productsByCategory(int categoryId) => '/products/category/$categoryId';
  static String productsByBrand(int brandId) => '/products/brand/$brandId';
  
  // Companies
  static const String companies = '/pharmaceutical-companies';
  static String companyById(int id) => '/pharmaceutical-companies/$id';
  static const String topCompanies = '/pharmaceutical-companies/top';
  static String companyStatistics(int id) => '/pharmaceutical-companies/$id/statistics';
  static String companyProducts(int companyId) => '/pharmaceutical-companies/$companyId/products';
  
  // Brands (new endpoints)
  static String brandById(int id) => '/brands/$id';
  static String brandProducts(int brandId) => '/brands/$brandId/products';
  
  // Categories & Brands
  static const String categories = '/categories';
  static const String brands = '/brands';
  
  // Cart & Orders
  static const String checkout = '/cart/checkout';
  static const String orders = '/orders';
  static String orderById(int id) => '/orders/$id';
  static String markOrderDelivered(int id) => '/orders/$id/mark-delivered';
  
  // Advertisements
  static const String advertisements = '/advertisements';
  static const String goldenAds = '/advertisements/golden';
  static const String silverAds = '/advertisements/silver';
  static const String activeAds = '/advertisements/active';
  
  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';
  static const String subscriptionStatus = '/subscriptions/status';
  
  // Dashboard
  static const String pharmacyDashboard = '/dashboard/pharmacy-admin';
  static const String systemHealth = '/dashboard/system-health';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/mark-as-read';
  static const String markAllNotificationsRead = '/notifications/mark-all-as-read';
  
  // Favorites
  static const String favorites = '/favorites';
  static String favoriteCheck(int productId) => '/favorites/check/$productId';
}
