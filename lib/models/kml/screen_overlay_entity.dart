/// Class that defines the `screen overlay` entity, which contains its
/// properties and methods.
class ScreenOverlayEntity {
  /// Property that defines the screen overlay `name`.
  String name;

  /// Property that defines the screen overlay `icon url`.
  String icon;

  /// Property that defines the screen overlay `overlayX`.
  double overlayX;

  /// Property that defines the screen overlay `overlayY`.
  double overlayY;

  /// Property that defines the screen overlay `screenX`.
  double screenX;

  /// Property that defines the screen overlay `screenY`.
  double screenY;

  /// Property that defines the screen overlay `sizeX`.
  double sizeX;

  /// Property that defines the screen overlay `sizeY`.
  double sizeY;

  ScreenOverlayEntity({
    required this.name,
    this.icon = '',
    required this.overlayX,
    required this.overlayY,
    required this.screenX,
    required this.screenY,
    required this.sizeX,
    required this.sizeY,
  });

  /// Property that defines the screen overlay `tag` according to its current
  /// properties.
  String get tag => '''
      <ScreenOverlay>
        <name>$name</name>
        <Icon>
          <href>$icon</href>
        </Icon>
        <color>ffffffff</color>
        <overlayXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
        <screenXY x="$screenX" y="$screenY" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="$sizeX" y="$sizeY" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
    ''';

  /// Generates a [ScreenOverlayEntity] with the logos data in it.
  factory ScreenOverlayEntity.logos() {
    return ScreenOverlayEntity(
      name: 'LogoCST',
      icon: 'https://github.com/savitore/STEAM-Celestial-Satellite-tracker-in-real-time/blob/8e3d132fc18d08f0f39b624e7cdb96e00a56fc0b/assets/mainLogo.jpg?raw=true',
      overlayX: 0,
      overlayY: 1,
      screenX: 0.02,
      screenY: 0.95,
      sizeX: 500,
      sizeY: 500,
    );
  }
}
