import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/ssh_service.dart';

import '../models/kml/kml_entity.dart';
import '../models/kml/look_at_entity.dart';
import '../models/kml/screen_overlay_entity.dart';
import 'file_service.dart';
import 'lg_settings_service.dart';

/// Service responsible for managing the data transfer between the app and the LG rig.
class LGService {

  SSHService get _sshService => GetIt.I<SSHService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();
  FileService get _fileService => GetIt.I<FileService>();
  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();

  final String _url = 'http://lg1:81';


  /// Property that defines the slave screen number that has the logos. Defaults to `5`.
  int screenAmount = 3;

  /// Property that defines the logo slave screen number according to the [screenAmount] property.
  int get logoScreen {
    int screenAmount = int.parse(getScreenAmount()!);
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most left screen.
    return (screenAmount / 2).floor() + 2;
  }

  /// Property that defines the balloon slave screen number according to the [screenAmount] property.
  int get balloonScreen {
    int screenAmount = int.parse(getScreenAmount()!);
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most right screen.
    return (screenAmount / 2).floor() + 1;
  }

  /// Sets the logos KML into the Liquid Galaxy rig.
  Future<void> setLogos({String name = 'SCST-logos', String content = '<name>Logos</name>'}) async {
    final screenOverlay = ScreenOverlayEntity.logos();

    final kml = KMLEntity(
      name: name,
      content: content,
      screenOverlay: screenOverlay.tag,
    );

    try {
      await sendKMLToSlave(logoScreen, kml.body);
    } catch (e) {
      print(e);
    }
  }

  /// Gets the Liquid Galaxy rig screen amount. Returns a [String] that represents the screen amount.
  String? getScreenAmount()  {
    String numberOfScreen = _localStorageService.getItem('screen');
    screenAmount = int.parse(numberOfScreen);

    return numberOfScreen;
  }

  /// Sends a the given [kml] to the Liquid Galaxy system.
  Future<void> sendKml(KMLEntity kml,
      {List<Map<String, String>> images = const []}) async {
    final fileName = '${kml.name}.kml';

    await clearKml();

    for (var img in images) {
      final image = await _fileService.createImage(img['name']!, img['path']!);
      await _sshService.upload(image,'image');
    }

    final kmlFile = await _fileService.createFile(fileName, kml.body);
    await _sshService.upload(kmlFile,'sendKml');

    await _sshService
        .execute('echo "$_url/$fileName" > /var/www/html/kmls.txt');
  }

  /// Sends and starts a `tour` into the Google Earth.
  Future<void> sendTour(String tourKml, String tourName) async {
    final fileName = '$tourName.kml';

    final kmlFile = await _fileService.createFile(fileName, tourKml);
    await _sshService.upload(kmlFile,'sendTour');

    await _sshService
        .execute('echo "\n$_url/$fileName" >> /var/www/html/kmls.txt');
  }

  /// Uses the [query] method to play some tour in Google Earth according to the given [tourName].
  Future<void> startTour(String tourName) async {
    await query('playtour=$tourName');
  }

  /// Uses the [query] method to stop all tours in Google Earth.
  Future<void> stopTour() async {
    await query('exittour=true');
  }

  /// Sends a KML [content] to the given slave [screen].
  Future<void> sendKMLToSlave(int screen, String content) async {
    try {
      await _sshService
          .execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Puts the given [content] into the `/tmp/query.txt` file.
  Future<void> query(String content) async {
    await _sshService.execute('echo "$content" > /tmp/query.txt');
  }

  /// Uses the [query] method to fly to some place in Google Earth according to the given [lookAt].
  Future<void> flyTo(LookAtEntity lookAt) async {
    await query('flytoview=${lookAt.linearTag}');
  }

  /// Setups the Google Earth in slave screens to refresh every 2 seconds.
  Future<void> setRefresh() async {
    final pw = _settingsService.getSettings().password;
    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }

    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo $pw | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo $pw | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $pw ssh -t lg$i \'{{cmd}}\'';

      try {
        await _sshService.execute(query.replaceAll('{{cmd}}', clearCmd));
        await _sshService.execute(query.replaceAll('{{cmd}}', cmd));
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  /// Setups the Google Earth in slave screens to stop refreshing.
  Future<void> resetRefresh() async {
    final pw = _settingsService.getSettings().password;
    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }

    const search =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

    final clear =
        'echo $pw | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= screenAmount; i++) {
      final cmd = clear.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $pw ssh -t lg$i \'$cmd\'';

      try {
        await _sshService.execute(query);
      } catch (e) {
        print(e);
      }
    }

    await reboot();
  }

  /// Clears all `KMLs` from the Google Earth. The [keepLogos] keeps the logos after clearing (default to `true`).
  Future<void> clearKml({bool keepLogos = true}) async {
    String query =
        'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';

    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }
    for (var i = 2; i <= screenAmount; i++) {
      String blankKml = KMLEntity.generateBlank('slave_$i');
      query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
    }

    if (keepLogos) {
      final kml = KMLEntity(
        name: 'SVT-logos',
        content: '<name>Logos</name>',
        screenOverlay: ScreenOverlayEntity.logos().tag,
      );

      query +=
      " && echo '${kml.body}' > /var/www/html/kml/slave_$logoScreen.kml";
    }

    await _sshService.execute(query);
  }

  /// Relaunches the Liquid Galaxy system.
  Future<void> relaunch() async {
    final pw = _settingsService.getSettings().password;
    final user = _settingsService.getSettings().username;
    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }
    print(pw+" "+user+" "+screenAmount.toString());
    for (var i = screenAmount; i >= 1; i--) {
      try {
        final relaunchCommand = """RELAUNCH_CMD="\\
if [ -f /etc/init/lxdm.conf ]; then
  export SERVICE=lxdm
elif [ -f /etc/init/lightdm.conf ]; then
  export SERVICE=lightdm
else
  exit 1
fi
if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
  echo $pw | sudo -S service \\\${SERVICE} start
else
  echo $pw | sudo -S service \\\${SERVICE} restart
fi
" && sshpass -p $pw ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _sshService
            .execute('"/home/$user/bin/lg-relaunch" > /home/$user/log.txt');
        await _sshService.execute(relaunchCommand);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  /// Reboots the Liquid Galaxy system.
  Future<void> reboot() async {
    final pw = _settingsService.getSettings().password;
    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }

    for (var i = screenAmount; i >= 1; i--) {
      try {
        await _sshService
            .execute('sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S reboot"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  /// Shuts down the Liquid Galaxy system.
  Future<void> shutdown() async {
    final pw = _settingsService.getSettings().password;
    final result = await getScreenAmount();
    if (result != null) {
      screenAmount = int.parse(result);
    }

    for (var i = screenAmount; i >= 1; i--) {
      try {
        await _sshService.execute(
            'sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S poweroff"');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }



}
