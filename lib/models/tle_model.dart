import 'package:sgp4_sdp4/sgp4_sdp4.dart';

/// Entity that represents the `TLE`, with all of its properties and methods.
class TLEModel {
  /// Property that defines the TLE `line 0`, which contains its name.
  String line0;

  /// Property that defines the TLE `line 1`.
  String line1;

  /// Property that defines the TLE `line 2`.
  String line2;

  /// Property that defines the TLE `satellite id`.
  String satelliteId;

  /// Property that defines the TLE `NORAD id`.
  int noradId;

  /// Property that defines the `date` that the TLE has `updated`.
  String updated;

  TLEModel({
    required this.line0,
    required this.line1,
    required this.line2,
    required this.satelliteId,
    required this.noradId,
    required this.updated,
  });

  /// Reads the current [TLEModel] and returns a [Map] containing all extracted
  /// information.
  Map<String, double> read({ double displacement = 3.3 / 24.0 }) {
    final datetime = DateTime.now();
    final TLE tle = TLE(line0, line1, line2);
    final Orbit orbit = Orbit(tle);

    final utcTime = Julian.fromFullDate(datetime.year, datetime.month,
        datetime.day, datetime.hour, datetime.minute)
        .getDate()
        + displacement;

    final Eci eciPos =
    orbit.getPosition((utcTime - orbit.epoch().getDate()) * MIN_PER_DAY);

    final CoordGeo coord = eciPos.toGeo();
    if (coord.lon > PI) {
      coord.lon -= TWOPI;
    }

    return {
      'lat': rad2deg(coord.lat),
      'lng': rad2deg(coord.lon),
      'alt': rad2deg(coord.alt),
      'apogee': orbit.apogee(),
      'perigee': orbit.perigee(),
      'period': orbit.period(),
      'inclination': rad2deg(orbit.inclination())
    };
  }

  /// Converts the current [TLEModel] to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'tle0': line0,
      'tle1': line1,
      'tle2': line2,
      'sat_id': satelliteId,
      'norad_cat_id': noradId,
      'updated': updated,
    };
  }

  /// Gets a [TLEModel] from the given [map].
  factory TLEModel.fromMap(Map map) {
    return TLEModel(
      line0: map['tle0'],
      line1: map['tle1'],
      line2: map['tle2'],
      satelliteId: map['sat_id'],
      noradId: map['norad_cat_id'],
      updated: map['updated'],
    );
  }
}
