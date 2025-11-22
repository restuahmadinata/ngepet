/// Performance optimization configurations for the app
class PerformanceConfig {
  // Image caching configuration
  static const int imageCacheWidth = 400;
  static const int imageCacheHeight = 400;
  static const int imageMemCacheWidth = 300;
  static const int imageMemCacheHeight = 300;
  
  // List view optimization
  static const double listCacheExtent = 200.0;
  static const int maxListItems = 50; // Limit initial load
  
  // Animation durations (shorter = snappier feel)
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 300);
  
  // StreamBuilder configuration
  static const int streamBufferSize = 10;
  
  // Debounce configuration
  static const Duration searchDebounce = Duration(milliseconds: 300);
  
  // High refresh rate support
  static const bool enableHighRefreshRate = true;
}
