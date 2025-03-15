/// **City Model**
class CityModel {
  final String name;
  final String code;

  CityModel({required this.name, required this.code});
}

/// **State Model with Cities**
class StateModel {
  final String name;
  final String code;
  final List<CityModel> cities;

  StateModel({
    required this.name,
    required this.code,
    required this.cities,
  });
}

/// **State and City Data Provider**
class StateCityDataProvider {
  /// **Static Data for States and Cities**
  static final List<StateModel> states = [
    StateModel(
      name: 'Maharashtra',
      code: 'MH',
      cities: [
        CityModel(name: 'Mumbai', code: 'BOM'),
        CityModel(name: 'Pune', code: 'PNQ'),
      ],
    ),
    StateModel(
      name: 'Karnataka',
      code: 'KA',
      cities: [
        CityModel(name: 'Bangalore', code: 'BLR'),
        CityModel(name: 'Mysore', code: 'MYS'),
      ],
    ),
    StateModel(
      name: 'Uttar Pradesh',
      code: 'UP',
      cities: [
        CityModel(name: 'Lucknow', code: 'LKO'),
        CityModel(name: 'Varanasi', code: 'VNS'),
      ],
    ),
    StateModel(
      name: 'Tamil Nadu',
      code: 'TN',
      cities: [
        CityModel(name: 'Chennai', code: 'CHN'),
        CityModel(name: 'Coimbatore', code: 'CBE'),
      ],
    ),
    StateModel(
      name: 'Delhi',
      code: 'DL',
      cities: [
        CityModel(name: 'New Delhi', code: 'NDL'),
        CityModel(name: 'South Delhi', code: 'SDL'),
      ],
    ),
  ];

  /// **Get City Names by State**
  static List<String> getCities(String stateName) {
    return states
        .firstWhere((state) => state.name == stateName,
        orElse: () => StateModel(name: '', code: '', cities: []))
        .cities
        .map((city) => city.name)
        .toList();
  }

  /// **Get State Code**
  static String getStateCode(String stateName) {
    return states
        .firstWhere((state) => state.name == stateName,
        orElse: () => StateModel(name: '', code: '', cities: []))
        .code;
  }

  /// **Get City Code**
  static String getCityCode(String stateName, String cityName) {
    return states
        .firstWhere((state) => state.name == stateName,
        orElse: () => StateModel(name: '', code: '', cities: []))
        .cities
        .firstWhere((city) => city.name == cityName,
        orElse: () => CityModel(name: '', code: ''))
        .code;
  }
}
