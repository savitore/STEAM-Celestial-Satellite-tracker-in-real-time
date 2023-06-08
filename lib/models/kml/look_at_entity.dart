/// Class that defines the `look at` entity, which contains its properties and
/// methods.
class LookAtEntity {
  /// Property that defines the look at `longitude`.
  double lng;

  /// Property that defines the look at `latitude`.
  double lat;

  /// Property that defines the look at `altitude`.
  double altitude;

  /// Property that defines the look at `range`.
  String range;

  /// Property that defines the look at `tilt`.
  String tilt;

  /// Property that defines the look at `heading`.
  String heading;

  /// Property that defines the look at `altitude mode`.
  ///
  /// Defaults to `relativeToGround`.
  String altitudeMode;

  LookAtEntity(
      {required this.lng,
      required this.lat,
      required this.range,
      required this.tilt,
      required this.heading,
      this.altitude = 0,
      this.altitudeMode = 'relativeToGround'});

  /// Property that defines the look at `tag` according to its current
  /// properties.
  String get tag => '''
      <LookAt>
        <longitude>$lng</longitude>
        <latitude>$lat</latitude>
        <altitude>$altitude</altitude>
        <range>$range</range>
        <tilt>$tilt</tilt>
        <heading>$heading</heading>
        <gx:altitudeMode>$altitudeMode</gx:altitudeMode>
      </LookAt>
    ''';

  /// Property that defines the look at `linear string` according to its current
  /// properties.
  String get linearTag =>
      '<LookAt><longitude>$lng</longitude><latitude>$lat</latitude><altitude>$altitude</altitude><range>$range</range><tilt>$tilt</tilt><heading>$heading</heading><gx:altitudeMode>$altitudeMode</gx:altitudeMode></LookAt>';

  /// Returns a [Map] from the current [LookAtEntity].
  toMap() {
    return {
      'lng': lng,
      'lat': lat,
      'altitude': altitude,
      'range': range,
      'tilt': tilt,
      'heading': heading,
      'altitudeMode': altitudeMode
    };
  }

  /// Returns a [LookAtEntity] from the given [map].
  factory LookAtEntity.fromMap(Map<String, dynamic> map) {
    return LookAtEntity(
        lng: map['lng'],
        lat: map['lat'],
        altitude: map['altitude'],
        range: map['range'],
        tilt: map['tilt'],
        heading: map['heading'],
        altitudeMode: map['altitudeMode']);
  }
}
