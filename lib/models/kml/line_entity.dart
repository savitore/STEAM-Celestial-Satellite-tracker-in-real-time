/// Class that defines the `line` entity, which contains its properties and
/// methods.
class LineEntity {
  /// Property that defines the line `id`.
  String id;

  /// Property that defines the line `coordinates` list.
  List<Map<String, double>> coordinates;

  /// Property that defines the line `draw order`.
  double drawOrder;

  /// Property that defines the line `altitude mode`.
  /// Defaults to `relativeToGround`.
  String altitudeMode;

  LineEntity({
    required this.id,
    required this.coordinates,
    this.drawOrder = 0,
    this.altitudeMode = 'relativeToGround',
  });

  /// Property that defines the line `tag` according to its current properties.
  String get tag => '''
      <Polygon id="$id">
        <extrude>0</extrude>
        <altitudeMode>$altitudeMode</altitudeMode>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              $linearCoordinates
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    ''';

  /// Property that defines the line `linear coordinates` according to its
  /// current [coordinates].
  String get linearCoordinates {
    String coords = coordinates
        .map((coord) => '${coord['lng']},${coord['lat']},${coord['altitude']}')
        .join(' ');

    return coords;
  }

  /// Returns a [Map] from the current [LineEntity].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coordinates': coordinates,
      'altitudeMode': altitudeMode,
      'drawOrder': drawOrder,
    };
  }

  /// Returns a [LineEntity] from the given [map].
  factory LineEntity.fromMap(Map<String, dynamic> map) {
    return LineEntity(
      id: map['id'],
      coordinates: map['coordinates'],
      altitudeMode: map['altitudeMode'],
      drawOrder: map['drawOrder'],
    );
  }
}
