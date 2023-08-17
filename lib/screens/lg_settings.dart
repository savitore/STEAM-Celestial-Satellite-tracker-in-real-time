import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

import '../models/lg_settings_model.dart';
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
  bool _loading = false,isAuthenticated=false;

  LGSettingsService get _settingsService => GetIt.I<LGSettingsService>();
  LGService get _lgService => GetIt.I<LGService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pwController = TextEditingController();
  final _screensController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _showTextInAppBar = false;

  @override
  void initState() {
    super.initState();
    _initNetworkState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 45) {
      setState(() {
        _showTextInAppBar = true;
      });
    } else {
      setState(() {
        _showTextInAppBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundCardColor,
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pop(context, "pop");
                },
            ),
            foregroundColor: ThemeColors.textPrimary,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: _showTextInAppBar ? const Text('LG Settings',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)) : const Text(''),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LG Settings',overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40),),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Status: ',style: TextStyle(fontSize: 30,color: ThemeColors.textPrimary),),
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
                          const SizedBox(height: 30,),
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
                                    child: Text(show ? 'HIDE' : 'SHOW',style: const TextStyle(fontSize: 18),)
                                )
                            ),
                          ),
                          const SizedBox(height: 30,),
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
                          const SizedBox(height: 30,),
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
                          const SizedBox(height: 30,),
                          _getTitle('Number of Screens'),
                          TextFormField(
                            controller: _screensController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
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
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    _localStorageService.setItem('screen', _screensController.text.toString());
                                    _localStorageService.setItem('lgConnected', "not");
                                    _onConnect();
                                    Timer(const Duration(seconds: 3), () async {
                                      if (isAuthenticated) {
                                        await _lgService.setLogos();
                                      }else{
                                        showSnackbar(context, 'Connection failed');
                                      }
                                      setState(() {
                                        _loading=false;
                                      });
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50)))),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5,),
                                      const Text('CONNECT',style: TextStyle(fontSize: 20),),
                                      const SizedBox(width: 10,),
                                      _loading ?
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.backgroundColor,),
                                      ) :
                                      const Icon(Icons.cast_connected_outlined,size: 25,)
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
    if(isAuthenticated){
      setState(() {
        _loading=false;
      });
    }
    return Text(isAuthenticated ? 'Connected' : 'Disconnected', style: TextStyle(color: isAuthenticated ? ThemeColors.success : ThemeColors.alert,fontSize: 30));
  }

  Widget _getTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textSecondary,fontSize: 20));
  }

  /// Initializes and sets the network connection form.
  void _initNetworkState() async {
      final settings = _settingsService.getSettings();

      setState(() {
        _usernameController.text = settings.username;
        _portController.text = settings.port.toString();
        _pwController.text = settings.password;
        _ipController.text = settings.ip;
        if(_localStorageService.hasItem('screen')){
          _screensController.text = _localStorageService.getItem('screen');
        }
      });

      _onConnect();
      Timer(const Duration(seconds: 3), () async {
        if (isAuthenticated) {
          await _lgService.setLogos();
        }else{
          showSnackbar(context, 'Connection failed');
          _localStorageService.setItem('lgConnected', "not");
        }
        setState(() {
          _loading=false;
        });
      });
  }

  /// Checks and sets the connection status according to the form info.
  Future<void> _checkConnection() async {

    SSHClient? _client;

    try {

      if (_ipController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _pwController.text.isEmpty ||
          _screensController.text.isEmpty ||
          _portController.text.isEmpty)
      {
        showSnackbar(context, 'Please enter all details');
      }


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
                _localStorageService.setItem('lgConnected', "connected");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Connected successfully.',
                    style: TextStyle(color: ThemeColors.snackBarTextColor),
                  ),
                  backgroundColor: ThemeColors.success,
                ));
              });
            }
        );
      }catch(e){
        if (kDebugMode) {
          print(e);
        }
      }

    } on Exception catch (e) {
      if (kDebugMode) {
        print('error: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$e');
      }
    }
  }

  /// Connects to the a machine according to the form info.
  void _onConnect() async {

    setState(() {
      isAuthenticated=false;
      _loading=true;
    });

    await _settingsService.setSettings(
      LGSettingsEntity(
          ip: _ipController.text,
          password: _pwController.text,
          port: int.parse(_portController.text),
          username: _usernameController.text),
    );

    await _checkConnection();
  }

}
