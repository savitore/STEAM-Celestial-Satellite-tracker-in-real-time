import 'package:steam_celestial_satellite_tracker_in_real_time/models/tle_model.dart';

import '../models/kml/line_entity.dart';
import '../models/kml/look_at_entity.dart';
import '../models/kml/orbit_entity.dart';
import '../models/kml/placemark_entity.dart';
import '../models/kml/point_entity.dart';
import '../models/kml/tour_entity.dart';
import '../models/satellite_model.dart';

class SatelliteService {

  /// Builds and returns a satellite `Placemark` entity according to the given
  /// [satellite], [tle], and more.
  PlacemarkEntity buildPlacemark(
    SatelliteModel satellite,
    TLEModel tle,
    bool balloon,
    double orbitPeriod, {
    LookAtEntity? lookAt,
    bool updatePosition = true,
  }) {
    LookAtEntity lookAtObj;

    if (lookAt == null) {
      final coord = tle.read();

      lookAtObj = LookAtEntity(
        lng: coord['lng']!,
        lat: coord['lat']!,
        altitude: coord['alt']!,
        range: '4000000',
        tilt: '60',
        heading: '0',
      );
    } else {
      lookAtObj = lookAt;
    }

    final point = PointEntity(
      lat: lookAtObj.lat,
      lng: lookAtObj.lng,
      altitude: lookAtObj.altitude,
    );


    final coordinates = satellite.getOrbitCoordinates(step: orbitPeriod, tle: tle);

    final tour = TourEntity(
      name: 'SimulationTour',
      placemarkId: 'p-${satellite.satId}',
      initialCoordinate: {
        'lat': point.lat,
        'lng': point.lng,
        'altitude': point.altitude,
      },
      coordinates: coordinates,
    );

    return PlacemarkEntity(
      id: satellite.satId!,
      name: '${satellite.name} (${satellite.status.toString().toUpperCase()})',
      lookAt: updatePosition ? lookAtObj : null,
      point: point,
      description: satellite.citation,
      balloonContent:
          balloon ? satellite.balloonContent() : '',
      icon: 'satellite.png',
      line: LineEntity(
        id: satellite.satId!,
        altitudeMode: 'absolute',
        coordinates: coordinates,
      ),
      tour: tour,
    );
  }

  /// Builds an `orbit` KML based on the given [satellite] and [tle].
  /// Returns a [String] that represents the `orbit` KML.
  String buildOrbit(SatelliteModel satellite, TLEModel tle, {LookAtEntity? lookAt})
  {

    LookAtEntity lookAtObj;

    if (lookAt == null) {
      final coord = tle.read();

      lookAtObj = LookAtEntity(
        lng: coord['lng']!,
        lat: coord['lat']!,
        altitude: coord['alt']!,
        range: '4000000',
        tilt: '60',
        heading: '0',
      );
    } else {
      lookAtObj = lookAt;
    }

    return OrbitEntity.buildOrbit(OrbitEntity.tag(lookAtObj));
  }

}
