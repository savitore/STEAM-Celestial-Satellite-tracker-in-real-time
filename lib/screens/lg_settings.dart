import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

import '../models/lg_settings_entity.dart';
import '../models/ssh_entity.dart';
import '../services/lg_settings_service.dart';
import '../services/ssh_service.dart';
import '../utils/snackbar.dart';

class LGSettings extends StatefulWidget {
  const LGSettings({Key? key}) : super(key: key);

  @override
  State<LGSettings> createState() => _LGSettingsState();
}

class _LGSettingsState extends State<LGSettings> with TickerProviderStateMixin {

  bool show = false;
  Timer? _timer;
  bool _connected = false;
  bool _loading = false;
  bool _canceled = false;

  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();
  SSHService get _sshService => GetIt.I<SSHService>();
  // LGService get _lgService => GetIt.I<LGService>();

  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNetworkState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pop(context);
                },
            ),
            title: const Text('LG Settings'),
            foregroundColor: ThemeColors.backgroundColor,
            elevation: 3,
            backgroundColor: ThemeColors.primaryColor,
          ),
          backgroundColor: ThemeColors.backgroundColor,
          body: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Status: ',style: TextStyle(fontSize: 24,color: ThemeColors.textPrimary),),
                              _getConnection()
                            ],
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Username'),
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'username',
                            ),
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Password'),
                          TextFormField(
                            controller: _pwController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            obscureText: !show,
                            maxLines: 1,
                            decoration: InputDecoration(
                                hintText: 'p@ssw0rd',
                                suffix: InkWell(
                                    onTap: (){
                                      setState(() {
                                        show=!show;
                                      });
                                    },
                                    child: Text(show ? 'HIDE' : 'SHOW')
                                )
                            ),
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('IP Address'),
                          TextFormField(
                            controller: _ipController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '192.168.10.21',
                            ),
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Port'),
                          TextFormField(
                            controller: _portController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '22',
                            ),
                          ),
                          const SizedBox(height: 50,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 170,
                                child: ElevatedButton(
                                  onPressed: _onConnect,
                                  style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50)))),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5,),
                                      const Text('CONNECT',style: TextStyle(fontSize: 20),),
                                      const SizedBox(width: 5,),
                                      _loading ?
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.backgroundColor,),
                                      ) :
                                      const Icon(Icons.connected_tv,size: 25,)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
            ),
          ),
    );
  }

  Widget _getConnection(){
    return Text(_connected ? 'Connected' : 'Disconnected', style: TextStyle(color: _connected ? ThemeColors.success : ThemeColors.alert,fontSize: 24));
  }

  Widget _getTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textSecondary,fontSize: 20));
  }

  /// Initializes and sets the network connection form.
  void _initNetworkState() async {
    try {
      final settings = _settingsService.getSettings();

      setState(() {
        _usernameController.text = settings.username;
        _portController.text = settings.port.toString();
        _pwController.text = settings.password;
      });

      if (settings.ip.isNotEmpty) {
        setState(() {
          _ipController.text = settings.ip;
        });

        _checkConnection();
        return;
      }

      final ips = await NetworkInterface.list(type: InternetAddressType.IPv4);

      if (ips.isEmpty || ips.first.addresses.isEmpty) {
        return;
      }

      setState(() {
        _ipController.text = ips.first.addresses.first.address;
      });

      _checkConnection();
    } on Exception {
      setState(() {
        _ipController.text = '';
      });
    }
  }

  /// Checks and sets the connection status according to the form info.
  Future<void> _checkConnection() async {
    _timer?.cancel();

    setState(() {
      _timer = null;
      _loading = true;
      _canceled = false;
    });

    _setSSH();

    try {
      if (_ipController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _portController.text.isEmpty) {
        return setState(() {
          _loading = false;
        });
      }

      final timer = Timer(const Duration(seconds: 5), () {
        showSnackbar(context, 'Connection failed');

        setState(() {
          _loading = false;
          _connected = false;
          _canceled = true;
        });
      });

      setState(() {
        _timer = timer;
      });

      final result = await _sshService.connect();
      _timer?.cancel();

      if (!_canceled) {
        setState(() {
          _connected = result == 'session_connected';
        });

        // if (result == 'session_connected') {
        //   await _lgService.setLogos();
        // }
      }
    } on Exception catch (e) {
      // ignore: avoid_print
      print('$e');
      if (!_canceled) {
        setState(() {
          _connected = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Sets the SSH client info based into the form.
  void _setSSH() {
    _sshService.setClient(SSHEntity(
      host: _ipController.text,
      passwordOrKey: _pwController.text,
      port: int.parse(_portController.text),
      username: _usernameController.text,
    ));
  }

  /// Connects to the a machine according to the form info.
  void _onConnect() async {
    setState(() {
      _loading = true;
    });

    await _settingsService.setSettings(
      LGSettingsEntity(
          ip: _ipController.text,
          password: _pwController.text,
          port: int.parse(_portController.text),
          username: _usernameController.text),
    );

    await _checkConnection();

    setState(() {
      _loading = false;
    });
  }

}
