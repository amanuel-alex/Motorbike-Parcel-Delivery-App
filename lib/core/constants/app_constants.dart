class AppConstants {
  static const Map<String, Map<String, double>> zonePrices = {
    'Bole': {'Arada': 150.0, 'Kirkos': 120.0, 'Yeka': 180.0},
    'Arada': {'Bole': 155.0, 'Kirkos': 100.0, 'Yeka': 130.0},
    'Kirkos': {'Bole': 110.0, 'Arada': 95.0, 'Yeka': 160.0},
  };

  static const List<String> availableZones = [
    'Bole',
    'Arada',
    'Kirkos',
    'Yeka',
  ];

  static const double baseSameZonePrice = 80.0;
}
