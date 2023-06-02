import 'package:flutter/material.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/lg_settings.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

import '../widgets/custom_page_route.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool val = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor,
      appBar: AppBar(
        elevation: 3,
        title: const Text('Settings'),
        backgroundColor: ThemeColors.primaryColor,
        foregroundColor: ThemeColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 20, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 20, 10),
                child: _buildSection('INFO')
              ),
              ListTile(
                  title: _buildTitle('About'),
                  leading: _buildIcon(Icons.info_outline),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 20, 10),
                child: _buildSection('APP SETTINGS')
              ),
              ListTile(
                leading: _buildIcon(Icons.dark_mode_outlined),
                title: _buildTitle('Dark Mode'),
                trailing: Switch(
                  activeColor: ThemeColors.primaryColor,
                  onChanged: (value){
                    setState(() {
                      val=value;
                    });
                  },
                  value: val,
                ),
              ),
              _divider(),
              ListTile(
                  title: _buildTitle('Bluetooth Connection'),
                  leading: _buildIcon(Icons.settings_bluetooth_outlined)
              ),
              _divider(),
              ListTile(
                onTap: (){
                  Navigator.of(context).push(
                      CustomPageRoute(child: const LGSettings())
                  );
                },
                title: _buildTitle('LG Connection'),
                leading: Image.asset('assets/lg.png',width: 20,height: 20,color: ThemeColors.primaryColor,),
              ),
              _divider(),
              ListTile(
                title: _buildTitle('LG Tools'),
                leading: _buildIcon(Icons.settings_input_antenna)
              ),
              _divider()
            ],
          ),
        ),
      )
    );
  }
  Widget _buildTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,);
  }
  Widget _buildIcon(IconData iconData){
    return Icon(iconData,size: 20,color: ThemeColors.primaryColor,);
  }
  Widget _buildSection(String title){
    return Text(title,style: TextStyle(color: ThemeColors.secondaryColor,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),);
  }
  Widget _divider(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.2,
      color: ThemeColors.dividerColor,
      margin: const EdgeInsets.only(left: 75),
    );
  }
}
