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
      'alt': coord.alt,
      'apogee': orbit.apogee(),
      'perigee': orbit.perigee(),
      'period': orbit.period(),
      'inclination': rad2deg(orbit.inclination())
    };
  }

  Map<String, double> getServoAngles(double latitude, double longitude, double altitude){

    final Site myLocation =
    Site.fromLatLngAlt(latitude, longitude, altitude / 1000.0);

    /// Get the current date and time
    final dateTime = DateTime.now();

    /// Parse the TLE
    final TLE tleSGP4 = TLE(line0, line1, line2);

    ///Create a orbit object and print if is
    ///SGP4, for "near-Earth" objects, or SDP4 for "deep space" objects.
    final Orbit orbit = Orbit(tleSGP4);

    /// get the utc time in Julian Day
    ///  + 4/24 need it, diferent time zone (Cuba -4 hrs )
    final double utcTime = Julian.fromFullDate(dateTime.year, dateTime.month,
        dateTime.day, dateTime.hour, dateTime.minute)
        .getDate() +
        3.3 / 24.0;

    final Eci eciPos =
    orbit.getPosition((utcTime - orbit.epoch().getDate()) * MIN_PER_DAY);


    CoordTopo topo = myLocation.getLookAngle(eciPos);

    return {
      'az': rad2deg(topo.az),
      'el': rad2deg(topo.el)
    };
  }


  factory TLEModel.fromJson(Map<String, dynamic> json) => TLEModel(
    line0: json['tle0'],
    line1: json['tle1'],
    line2: json['tle2'],
    satelliteId: json['sat_id'],
    noradId: json['norad_cat_id'],
    updated: json['updated'],
  );

  Map<String, dynamic> toJson() => {
    'tle0': line0,
    'tle1': line1,
    'tle2': line2,
    'sat_id': satelliteId,
    'norad_cat_id': noradId,
    'updated': updated,
  };

}
