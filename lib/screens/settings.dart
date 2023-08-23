import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/help.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/lg_settings.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/snackbar.dart';

import '../services/lg_service.dart';
import '../utils/storage_keys.dart';
import '../widgets/confirm_dialog.dart';
import 'about.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool tools=false, lgConnected=false;
  bool _settingRefresh = false, _resetingRefresh = false, _clearingKml = false, _rebooting = false, _relaunching = false, _shuttingDown = false, _showingLogos=false;

  LGService get _lgService => GetIt.I<LGService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();
  final ScrollController _scrollController = ScrollController();
  bool _showTextInAppBar = false;
  late String dropDownValue;

  @override
  void initState() {
    checkLGConnection();
    _scrollController.addListener(_scrollListener);
    super.initState();
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

  Future<void> checkLGConnection() async{
    if(_localStorageService.hasItem(StorageKeys.lgConnection)){
      if(_localStorageService.getItem(StorageKeys.lgConnection)=="connected"){
        setState(() {
          lgConnected=true;
        });
      }
      else{
        setState(() {
          lgConnected=false;
        });
      }
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeColors.textPrimary,
        leading: IconButton(icon : const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context,"pop"); },),
        title: _showTextInAppBar ? const Text('Settings',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)) : const Text(''),
        bottom: _showTextInAppBar ? PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1,
          ),
        ) : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 20, 20),
                child: Text('Settings',overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 20, 15),
                child: _buildSection('INFO')
              ),
              ListTile(
                onTap: (){
                  Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const About()));
                  },
                  title: _buildTitle('About'),
                  trailing: const Icon(Icons.arrow_forward),
                  leading: _buildIcon(Icons.info_outline),
              ),
              _divider(),
              ListTile(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Help()));
                },
                title: _buildTitle('Help'),
                trailing: const Icon(Icons.arrow_forward),
                leading: _buildIcon(Icons.help_center_outlined),
              ),
              _divider(),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 20, 15),
                child: _buildSection('APP SETTINGS')
              ),
              ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> const LGSettings())
                  );
                  if(result=="pop"){
                    checkLGConnection();
                  }
                },
                title: _buildTitle('LG Connection'),
                leading: _buildIcon(Icons.travel_explore_rounded),
                trailing: const Icon(Icons.arrow_forward,),
                ),
              _divider(),
              ListTile(
                onTap: (){
                  setState(() {
                    tools=!tools;
                  });
                },
                title: Text('LG Tools',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28,fontWeight: tools ? FontWeight.bold : FontWeight.normal),overflow: TextOverflow.visible,),
                leading: _buildIcon(Icons.settings_input_antenna),
                trailing: tools ?
                     Icon(Icons.keyboard_arrow_up,color: ThemeColors.primaryColor,) :
                     const Icon(Icons.keyboard_arrow_down,)
              ),
              tools ? showTools() : _divider(),
              ListTile(
                  onTap: (){
                    Navigator.pop(context,"refresh");
                  },
                  title: Text('Synchronize data',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28,fontWeight: FontWeight.normal),overflow: TextOverflow.visible,),
                  leading: _buildIcon(Icons.sync),
              ),
              _divider(),
            ],
          ),
        ),
      )
    );
  }
  Widget _buildTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 28),overflow: TextOverflow.visible,);
  }
  Widget _buildIcon(IconData iconData){
    return Icon(iconData,size: 30,color: ThemeColors.primaryColor,);
  }
  Widget _buildSection(String title){
    return Text(title,style: TextStyle(color: ThemeColors.secondaryColor,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,fontSize: 22),);
  }
  Widget _divider(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.2,
      color: ThemeColors.dividerColor,
      margin: const EdgeInsets.only(left: 75),
    );
  }

  Widget showTools(){
    ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: ThemeColors.secondaryColor,foregroundColor: ThemeColors.backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
    ButtonStyle _style = ElevatedButton.styleFrom(backgroundColor: ThemeColors.backgroundColor,foregroundColor: ThemeColors.secondaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),side: BorderSide(color: ThemeColors.secondaryColor)));
    return Padding(
      padding: const EdgeInsets.only(right: 10,left: 5,top: 10),
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                checkLGConnection();
                if(!lgConnected){
                  errorTaskButton();
                }else{

                  if (_settingRefresh) {
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: 'Are you sure?',
                      message:
                      'The slaves solo KMLs will start to refresh each 2 seconds and all screens will be rebooted.',
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                      onConfirm: () async {
                        Navigator.of(context).pop();

                        setState(() {
                          _settingRefresh = true;
                        });

                        try {
                          await _lgService.setRefresh();
                        } finally {
                          setState(() {
                            _settingRefresh = false;
                          });
                        }
                      },
                      buttonText: 'Yes',
                    ),
                  );
                }
              },
              style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('SET SLAVES REFRESH'),
                const SizedBox(
                  width: 5,
                ),
                _settingRefresh
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor,),
                      )
                    : const Icon(Icons.av_timer_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: (){
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_resetingRefresh) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Are you sure?',
                    message:
                    'The slaves will stop refreshing and all screens will be rebooted.',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _resetingRefresh = true;
                      });

                      try {
                        await _lgService.resetRefresh();
                      } finally {
                        setState(() {
                          _resetingRefresh = false;
                        });
                      }
                    },
                    buttonText: 'Yes',
                  ),
                );
              }
            },
            style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('RESET SLAVES REFRESH'),
                const SizedBox(
                  width: 5,
                ),
                _resetingRefresh
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor),
                      )
                    : const Icon(Icons.timer_off_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_clearingKml) {
                  return;
                }

                setState(() {
                  _clearingKml = true;
                });

                try {
                  await _lgService.clearKml(keepLogos: false);
                } finally {
                  setState(() {
                    _clearingKml = false;
                  });
                }
              }
            },
            style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('CLEAR KML + LOGOS'),
                const SizedBox(
                  width: 5,
                ),
                _clearingKml
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor),
                      )
                    : const Icon(Icons.cleaning_services_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_showingLogos) {
                  return;
                }

                setState(() {
                  _showingLogos = true;
                });

                try {
                  await _lgService.setLogos();
                } finally {
                  setState(() {
                    _showingLogos = false;
                  });
                }

              }
            },
            style: _style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('SHOW LOGOS'),
                const SizedBox(
                  width: 5,
                ),
                _showingLogos
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.secondaryColor),
                )
                    : const Icon(Icons.smart_display_outlined)
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_relaunching) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Are you sure?',
                    message: 'All screens will be relaunched.',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _relaunching = true;
                      });

                      try {
                        await _lgService.relaunch();
                      } finally {
                        setState(() {
                          _relaunching = false;
                        });
                      }
                    },
                    buttonText: 'Relaunch',
                  ),
                );
              }
            },
            style: style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('RELAUNCH'),
                const SizedBox(
                  width: 5,
                ),
                _relaunching
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.backgroundColor),
                      )
                    : const Icon(Icons.reset_tv_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_rebooting) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Are you sure?',
                    message: 'The system will be fully rebooted.',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _rebooting = true;
                      });

                      try {
                        await _lgService.reboot();
                      } finally {
                        setState(() {
                          _rebooting = false;
                        });
                      }
                    },
                    buttonText: 'Reboot',
                  ),
                );
              }
            },
            style: style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('REBOOT'),
                const SizedBox(
                  width: 5,
                ),
                _rebooting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.backgroundColor),
                      )
                    : const Icon(Icons.restart_alt_rounded)
              ],
            ),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () async {
              checkLGConnection();
              if(!lgConnected){
                errorTaskButton();
              }else{

                if (_shuttingDown) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Are you sure?',
                    message: 'The system will shutdown.',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _shuttingDown = true;
                      });

                      try {
                        await _lgService.shutdown();
                      } finally {
                        setState(() {
                          _shuttingDown = false;
                        });
                      }
                    },
                    buttonText: 'Power Off',
                  ),
                );
              }
            },
            style: style,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonText('POWER OFF'),
                const SizedBox(
                  width: 5,
                ),
                _shuttingDown
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 3,color: ThemeColors.backgroundColor),
                      )
                    : const Icon(Icons.power_settings_new_rounded)
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buttonText(String text){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(
            overflow: TextOverflow.visible,
            fontSize: 18,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  void errorTaskButton(){
    showSnackbar(context, 'Connection failed.');
  }

}
