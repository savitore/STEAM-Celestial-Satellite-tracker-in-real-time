import 'package:flutter/material.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

class LGSettings extends StatefulWidget {
  const LGSettings({Key? key}) : super(key: key);

  @override
  State<LGSettings> createState() => _LGSettingsState();
}

class _LGSettingsState extends State<LGSettings> {

  bool show = false;
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
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Password'),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            obscureText: !show,
                            maxLines: 1,
                            decoration: InputDecoration(
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
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 50,),
                          _getTitle('Port'),
                          TextFormField(
                            keyboardType: TextInputType.text,
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
                                  onPressed: () {
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50)))),
                                  child: Row(
                                    children: const [
                                      SizedBox(width: 5,),
                                      Text('CONNECT',style: TextStyle(fontSize: 20),),
                                      SizedBox(width: 5,),
                                      Icon(Icons.connected_tv,size: 25,)
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
    return const Text('Connected?', style: TextStyle(color: Colors.red,fontSize: 24));
  }

  Widget _getTitle(String title){
    return Text(title,style: TextStyle(color: ThemeColors.textSecondary,fontSize: 20));
  }

}
