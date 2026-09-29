class AppConstants {
  AppConstants._();

  static const String apiBaseUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/query';

  static const String apiFormat = 'geojson';
  static const double defaultMinMagnitude = 4.5;
  static const String defaultOrderBy = 'time';
  static const int defaultLimit = 500;

  static const int defaultRangeInDays = 30;

  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgentPackageName = 'com.example.usgs_terremotos';
  static const double defaultMapZoom = 3.5;
  static const double detailMapZoom = 6.0;

  static const String appName = 'USGS Terremotos';
}
