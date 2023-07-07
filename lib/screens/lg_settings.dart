import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

import '../models/lg_settings_entity.dart';
import '../services/lg_service.dart';
import '../services/lg_settings_service.dart';
import '../utils/snackbar.dart';

class LGSettings extends StatefulWidget {
  const LGSettings({Key? key}) : super(key: key);

  @override
  State<LGSettings> createState() => _LGSettingsState();
}

class _LGSettingsState extends State<LGSettings> with TickerProviderStateMixin {

  bool show = false;
  bool _connected = false;
  bool _loading = false,isAuthenticated=false;

  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();
  LGService get _lgService => GetIt.I<LGService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pwController = TextEditingController();
  final _screensController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNetworkState();
  }

  @override
  void dispose() {
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
                                hintText: 'password',
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
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '22',
                            ),
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Number of Screens'),
                          TextFormField(
                            controller: _screensController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '1 or 3 or 5',
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
                                  onPressed: (){
                                    _localStorageService.setItem('screen', _screensController.text.toString());
                                    _onConnect();
                                  },
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
        if(_localStorageService.hasItem('screen')){
          _screensController.text = _localStorageService.getItem('screen');
        }
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

    setState(() {
      _loading = true;
    });

    SSHClient? _client;
    try {
      if (_ipController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _portController.text.isEmpty) {
        return setState(() {
          _loading = false;
        });
      }

        setState(() {
          _loading = false;
        });
      final settings = _settingsService.getSettings();
      try{
        final socket = await SSHSocket.connect(settings.ip,settings.port);
        String? password;
        _client = SSHClient(
            socket,
            username: settings.username,
            onPasswordRequest: (){
              password = settings.password;
              return password;
            },
            keepAliveInterval: const Duration(seconds: 3600),
            onAuthenticated: (){
              setState(() {
                isAuthenticated=true;
              });
            }
        );
      }catch(e){
        print(e);
      }
        if (isAuthenticated) {
          setState(() {
            _connected=true;
          });
          _localStorageService.setItem('lgConnected', "connected");
          await _lgService.setLogos();
        }else{
          showSnackbar(context, 'Connection failed');
          _localStorageService.setItem('lgConnected', "not");
        }
    } on Exception catch (e) {
      print('error: $e');
    } catch (e) {
      print('$e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
