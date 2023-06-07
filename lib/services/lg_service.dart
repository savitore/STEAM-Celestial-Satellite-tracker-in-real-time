import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/ssh_service.dart';

/// Service responsible for managing the data transfer between the app and the LG rig.
class LGService {
  SSHService get _sshService => GetIt.I<SSHService>();


  /// Property that defines the slave screen number that has the logos. Defaults to `5`.
  int screenAmount = 5;

  /// Property that defines the logo slave screen number according to the [screenAmount] property.
  int get logoScreen {
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most left screen.
    return (screenAmount / 2).floor() + 2;
  }

  /// Property that defines the balloon slave screen number according to the [screenAmount] property.
  int get balloonScreen {
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most right screen.
    return (screenAmount / 2).floor() + 1;
  }

  /// Setups the Google Earth in slave screens to refresh every 2 seconds.
  Future<void> setRefresh() async {
    final pw = _sshService.client.passwordOrKey;

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
    final pw = _sshService.client.passwordOrKey;

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
        // ignore: avoid_print
        print(e);
      }
    }

    await reboot();
  }

  /// Clears all `KMLs` from the Google Earth. The [keepLogos] keeps the logos after clearing (default to `true`).
  Future<void> clearKml({bool keepLogos = true}) async {

  }

  /// Relaunches the Liquid Galaxy system.
  Future<void> relaunch() async {
    final pw = _sshService.client.passwordOrKey;
    final user = _sshService.client.username;

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
    final pw = _sshService.client.passwordOrKey;

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
    final pw = _sshService.client.passwordOrKey;

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
