import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_info_cubit.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_info_state.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/tle_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/compass.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/zoomed_screen.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/services/local_storage_service.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/snackbar.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/storage_keys.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/kml/kml_entity.dart';
import '../models/kml/look_at_entity.dart';
import '../models/kml/placemark_entity.dart';
import '../repositories/countries_iso.dart';
import '../services/lg_service.dart';
import '../services/satellite_service.dart';
import '../utils/colors.dart';
import '../widgets/date.dart';
import '../widgets/shimmer.dart';

class SatelliteInfo extends StatefulWidget {
  final SatelliteModel satelliteModel;
  const SatelliteInfo(this.satelliteModel, {super.key});

  @override
  State<SatelliteInfo> createState() => _SatelliteInfoState();
}

class _SatelliteInfoState extends State<SatelliteInfo> {

  SatelliteService get _satelliteService => GetIt.I<SatelliteService>();
  LGService get _lgService => GetIt.I<LGService>();
  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();

  bool tleExists = false, lgConnected=false, _satelliteBalloonVisible = true,_viewingLG=false,_orbit=false, _simulate=false, websiteDialog=true,checkbox=false;
  late TLEModel tleModel;
  double _orbitPeriod=3;

  PlacemarkEntity? _satellitePlacemark;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothConnection? _connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => _connection != null && _connection!.isConnected;
  BluetoothDevice? _device;
  int? _deviceState;
  bool isDisconnecting = false,_btConnected=false,_btDataSent=false;
  bool _isButtonUnavailable = false, _isConnecting=false;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  String _location='',latitude='',longitude='',altitude='',satAltitude='';
  String btReceived='', _btDataToSend='';

  final double _height1=10 ,_height2=30;

  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    checkLGConnection();
    _determinePosition();
    checkWebsiteDialog();
    super.initState();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      _connection?.dispose();
      _connection = null;
    }
    btReceived='';
    super.dispose();
  }


  //check if lg is connected
  void checkLGConnection() {
    if(_localStorageService.hasItem('lgConnected')){
      if(_localStorageService.getItem('lgConnected')=="connected"){
        setState(() {
          lgConnected=true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => SatelliteInfoCubit(widget.satelliteModel.noradCatId.toString() !='null' ? widget.satelliteModel.noradCatId! : 0),
        child: Scaffold(
          backgroundColor: ThemeColors.backgroundCardColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: ThemeColors.textPrimary,
            elevation: 0,
            leading: IconButton(icon : const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context); },),
          ),
          body: SafeArea(
            child: BlocConsumer<SatelliteInfoCubit, SatelliteInfoState>(
              listener: (context,state){
                if(state is SatelliteErrorState){
                  showSnackbar(context, state.error);
                }
              },
              builder: (context,state){
                if(state is SatelliteLoadingState){
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerEffect().shimmer(Container(
                              height: 15,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey))),
                          const SizedBox(height: 10,),
                          ShimmerEffect().shimmer(Container(
                              height: 15,
                              width: 150,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey))),
                          divider(),
                          const SizedBox(height: 20,),
                          widget.satelliteModel.image.toString().isEmpty ? Container() :
                              ShimmerEffect().shimmer(Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey))),
                          const SizedBox(height: 20,),
                          shimmerTile(),
                          shimmerTile(),
                          shimmerTile(),
                          shimmerTile(),
                          shimmerTile(),
                          ShimmerEffect().shimmer(Container(
                              height: 15,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey))),
                          const SizedBox(height: 10),
                          ShimmerEffect().shimmer(Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey))),
                          const SizedBox(height: 30),
                          shimmerTile(),
                          shimmerTile(),
                          shimmerTile(),
                        ],
                      ),
                    ),
                  );
                }
                else if(state is SatelliteLoadedState){
                  checkTLE(state.tle);
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.satelliteModel.name.toString(),overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40),),
                          const SizedBox(height: 20,),
                          _buildSatelliteStatus(),
                          const SizedBox(height: 20),
                          _buildSatelliteImage(),
                          _buildViewButtons(context,state.TLE),
                          _buildVisualisingInLG(),
                          _buildTitle('Satellite ID', widget.satelliteModel.satId.toString()),
                          _buildTitle('NORAD ID', widget.satelliteModel.noradCatId.toString()),
                          _buildTitle('NORAD Follow ID', widget.satelliteModel.noradFollowId.toString()),
                          _buildTitle('Alternate names', widget.satelliteModel.names.toString()),
                          _buildDate('Launch date', widget.satelliteModel.launched.toString()),
                          _buildDate('Deploy date', widget.satelliteModel.deployed.toString()),
                          _buildDate('Decay date', widget.satelliteModel.decayed.toString()),
                          _buildCountry(widget.satelliteModel.countries.toString()),
                          _buildTitle('Operator', widget.satelliteModel.operator.toString()),
                          _buildWebsite(widget.satelliteModel.website.toString()),
                          _buildTLE(state.tle),
                          _buildDate('Updated', widget.satelliteModel.updated.toString()),
                          _buildAdditional(),
                        ],
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text("An error occurred!",style: TextStyle(color: ThemeColors.textPrimary),),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text){
    return Text(text,style: TextStyle(fontSize: 22,color: ThemeColors.textSecondary),overflow: TextOverflow.ellipsis,);
  }
  Widget _paragraph(String text){
    return Text(text,style: TextStyle(fontSize: 25,color: ThemeColors.textPrimary),overflow: TextOverflow.visible,);
  }

  Widget _buildTitle(String title, String info){
    if(info.isEmpty || info == 'null' ){
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        SizedBox(height: _height1),
        _paragraph(info),
        SizedBox(height: _height2)
      ],
    );
  }

  Widget _buildWebsite(String web){
    return web.isEmpty || web == 'null'
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title('Website'),
              SizedBox(height: _height1),
              InkWell(
                  onTap: () {
                    if (widget.satelliteModel.websiteValid()) {
                      if (websiteDialog) {
                        showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                                  builder: (context, _setState) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 0,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Open Link',
                                          style: TextStyle(
                                              color: ThemeColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                    backgroundColor:
                                        ThemeColors.backgroundColor,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                            text: TextSpan(
                                                text:
                                                    'You will be redirected to ',
                                                style: TextStyle(
                                                    color: ThemeColors
                                                        .textSecondary,
                                                    fontSize: 18),
                                                children: [
                                              TextSpan(
                                                text: widget
                                                    .satelliteModel.website
                                                    .toString(),
                                                style: TextStyle(
                                                    color:
                                                        ThemeColors.textPrimary,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ])),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: ThemeColors
                                                        .primaryColor,
                                                    fontSize: 17),
                                              ),
                                              onPressed: () {
                                                if (checkbox) {
                                                  _localStorageService.setItem(
                                                      StorageKeys.website,
                                                      false);
                                                  setState(() {
                                                    websiteDialog = false;
                                                  });
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: ThemeColors
                                                        .primaryColor,
                                                    fontSize: 17),
                                              ),
                                              onPressed: () {
                                                if (checkbox) {
                                                  _localStorageService.setItem(
                                                      StorageKeys.website,
                                                      false);
                                                  setState(() {
                                                    websiteDialog = false;
                                                  });
                                                }
                                                Navigator.of(context).pop();
                                                _openLink();
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                                checkColor:
                                                    ThemeColors.backgroundColor,
                                                activeColor:
                                                    ThemeColors.primaryColor,
                                                value: checkbox,
                                                onChanged: (bool? value) {
                                                  _setState(() {
                                                    checkbox = value!;
                                                  });
                                                }),
                                            Text(
                                              'Do not show again',
                                              style: TextStyle(
                                                  color:
                                                      ThemeColors.textPrimary,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                      } else {
                        _openLink();
                      }
                    }
                  },
                  child: Text(
                    web,
                    style: TextStyle(
                        color: ThemeColors.textPrimary,
                        fontSize: 25,
                        fontWeight: widget.satelliteModel.websiteValid()
                            ? FontWeight.w500
                            : FontWeight.normal),
                    overflow: TextOverflow.visible,
                  )),
              SizedBox(height: _height2)
            ],
          );
  }

  Widget _buildDate(String title, String date){
    if(date.isEmpty || date == 'null' ){
      return Container();
    }
    date = parseDateHourString(date);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        SizedBox(height: _height1),
        _paragraph(date),
        SizedBox(height: _height2)
      ],
    );
  }

  Widget _buildSatelliteImage() {
    final image = widget.satelliteModel.image;
    return image.toString().isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoomedScreen(
                            image:
                                'https://db-satnogs.freetls.fastly.net/media/$image'),
                      ),
                    );
                  },
                  child: Image.network(
                    'https://db-satnogs.freetls.fastly.net/media/$image',
                    // width: 180,
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildTLE(List<String> tle){
    if(tleExists){
      tleModel = TLEModel(line0: tle[0], line1: tle[1], line2: tle[2], satelliteId: widget.satelliteModel.satId!, noradId: widget.satelliteModel.noradCatId!, updated: widget.satelliteModel.updated!);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Latest Two-Line Element (TLE)'),
          SizedBox(height: _height1),
          _paragraph('${tle[0]}\n${tle[1]}\n${tle[2]}'),
          SizedBox(height: _height2)
        ],
      );
    }
    return Container();
  }

  Widget _buildAdditional(){
    if(tleExists){
      final tleStats = tleModel.read();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _title('Additional Information'),
              const SizedBox(width: 10,),
              Tooltip(
                message: 'Orbit Period: The amount of time to complete one revolution around the Earth. \nApogee: The point where the satellite is farthest from Earth. \nPerigee: The point where the satellite is closest to Earth. \nInclination: It is the angle between orbital and equitorial plane. ',
                textStyle: const TextStyle(color: Colors.white,fontSize: 20),
                // decoration: BoxDecoration(color: ThemeColors.backgroundColor,borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                child: Icon(Icons.info_outline,color: ThemeColors.primaryColor,size: 22,),
              )
            ],
          ),
          SizedBox(height: _height1!+10),
          RichText(
              text: TextSpan(
                  text: 'Orbit Period: ',
                  style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),
                  children: [
                    TextSpan(
                      text: (tleStats['period']!/60)?.toStringAsFixed(2),
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                    ),
                    TextSpan(
                        text: ' minutes',
                        style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                    )
                  ]
              ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Apogee: ',
                style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),
                children: [
                  TextSpan(
                      text: (tleStats['apogee'])?.toStringAsFixed(2),
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  ),
                  TextSpan(
                      text: ' km',
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  )
                ]
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Perigee: ',
                style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),
                children: [
                  TextSpan(
                      text: (tleStats['perigee'])?.toStringAsFixed(2),
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  ),
                  TextSpan(
                      text: ' km',
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  )
                ]
            ),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Inclination: ',
                style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),
                children: [
                  TextSpan(
                      text: (tleStats['inclination'])?.toStringAsFixed(2),
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  ),
                  TextSpan(
                      text: ' °',
                      style: TextStyle(color: ThemeColors.textPrimary,fontSize: 25)
                  )
                ]
            ),
          ),
          SizedBox(height: _height2),
        ],
      );
    }
    return Container();
  }

  Widget _buildCountry(String countries){
    if(countries.isEmpty || countries == 'null' ){
      return Container();
    }
    String title = 'Country of Origin';
    if(countries.contains(',')){
      title = 'Countries of Origin';
      return _buildTitle(title, countries.toString());
    }
      List iso = ISO().iso;
      String code = '';
      for (int j = 0; j < iso.length; j++) {
        Map<String, String> data = iso[j];
          if (data['Name'] == countries) {
            code = data['Code']!;
          }
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(title),
          SizedBox(height: _height1),
          Row(
            children: [
              _paragraph(countries.toString()),
              const SizedBox(width: 5,),
              CountryFlag.fromCountryCode(
                code,
                height: 36,
                width: 24,
              ),
            ],
          ),
          SizedBox(height: _height2)
        ],
      );
  }

  Widget _buildSatelliteStatus() {
    final statusData = _getStatusData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                statusData['icon'],
                color: statusData['color'],
              ),
            ),
            Text(
              statusData['title'],
              style: TextStyle(
                color: statusData['color'],
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Text(
          statusData['description'],
          style: TextStyle(
            color: ThemeColors.textPrimary,
            fontSize: 16,
          ),
          overflow: TextOverflow.visible,
        ),
        divider(),
      ],
    );
  }

  Widget _buildViewButtons(BuildContext context, String TLE){
    return tleExists ?
    Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width*0.5-20,
              child: ElevatedButton(
                  onPressed: (){
                    btInit();
                    if(_bluetoothState==BluetoothState.STATE_ON){
                      getPairedDevices();
                    }
                    showModalBottomSheet(
                      isDismissible: true,
                      enableDrag: false,
                      backgroundColor: ThemeColors.backgroundColor,
                      context: context,
                      builder: (_context) => StatefulBuilder(
                          builder: (BuildContext _context, StateSetter _setState){
                            return btConnection(context,_setState,TLE);
                          }),
                      isScrollControlled: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30)
                      ),
                        side: BorderSide(color: ThemeColors.primaryColor)
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Image.asset('assets/3d.png',width: 28,height: 28,color: ThemeColors.primaryColor,)),
                      const SizedBox(width: 10),
                      Flexible(child: Text('VIEW IN 3D',style: TextStyle(color: ThemeColors.primaryColor,fontSize: 18,letterSpacing: 1,overflow: TextOverflow.visible))),
                    ],
                  )
              ),
            ),
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width*0.5-20,
              child: ElevatedButton(
                  onPressed: (){
                    if(_viewingLG){
                      _lgService.clearKml();
                      setState(() {
                        _viewingLG=false;
                        _simulate=false;
                        _orbit=false;
                        _orbitPeriod=3;
                        _satelliteBalloonVisible=true;
                      });
                    }
                    else {
                      viewSatelliteLG(context, widget.satelliteModel,
                          _satelliteBalloonVisible);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: !_viewingLG  ? ThemeColors.backgroundColor : ThemeColors.primaryColor,
                      foregroundColor: _viewingLG  ? ThemeColors.backgroundColor : ThemeColors.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30)
                          ),
                          side: BorderSide(color: ThemeColors.primaryColor)
                      ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Icon(Icons.travel_explore_rounded,color: _viewingLG  ? ThemeColors.backgroundColor : ThemeColors.primaryColor,size: 26,)),
                      const SizedBox(width: 10),
                      Flexible(child: Text(_viewingLG ? 'STOP VIEWING' : 'VIEW IN LG',style: const TextStyle(fontSize: 18,letterSpacing: 1),overflow: TextOverflow.visible,)),
                    ],
                  )
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ) :
    Column(
      children: [
        SizedBox(
          height: 60,
          width: MediaQuery.of(context).size.width-40,
          child: ElevatedButton(
            onPressed: null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                  ),
              ),
              child: Text('No TLE information available',overflow: TextOverflow.visible,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 18),),
              )
          ),
        const SizedBox(height: 20,)
      ],
    );
  }

  Widget btConnection(BuildContext context, StateSetter _setState, String tle){
    if(_bluetoothState == BluetoothState.STATE_ON){
      getPairedDevices();
    }
    // if(_location!="granted"){
    //   return Padding(
    //     padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('Please grant location permission in order to view in 3D.',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,),
    //         const SizedBox(height: 20,),
    //         SizedBox(
    //           height: 45,
    //           child: ElevatedButton(
    //               onPressed: (){
    //                 _determinePosition();
    //               },
    //               style: ElevatedButton.styleFrom(
    //                   backgroundColor: ThemeColors.primaryColor,foregroundColor: ThemeColors.backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
    //               ),
    //               child: const Text('Request Permission',style: TextStyle(fontSize: 20),)
    //           ),
    //         )
    //       ],
    //     ),
    //   );
    // }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child:
      _bluetoothState == BluetoothState.STATE_ON ?
       Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Select a Device',style: TextStyle(color: ThemeColors.primaryColor,fontWeight: FontWeight.bold,fontSize: 30),overflow: TextOverflow.visible,),
            ],
          ),
          const SizedBox(height: 20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     Expanded(
          //       child: Text(
          //         'Enable Bluetooth',
          //         style: TextStyle(
          //           color: ThemeColors.textPrimary,
          //           fontSize: 22,
          //         ),
          //       ),
          //     ),
          //     Switch(
          //       value: _bluetoothState.isEnabled,
          //       onChanged: (bool value) {
          //         future() async {
          //           if (value) {
          //             await FlutterBluetoothSerial.instance
          //                 .requestEnable();
          //           } else {
          //             await FlutterBluetoothSerial.instance
          //                 .requestDisable();
          //           }
          //
          //           await getPairedDevices();
          //           _isButtonUnavailable = false;
          //
          //           if (_btConnected) {
          //             _disconnect();
          //           }
          //         }
          //
          //         future().then((_) {
          //           _setState(() {});
          //         });
          //       },
          //       activeColor: ThemeColors.primaryColor,
          //     )
          //   ],
          // ),
          // const SizedBox(height: 5,),
          Divider(
            thickness: 0.5,
            height: 5,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PAIRED DEVICES",
                style: TextStyle(fontSize: 25, color: ThemeColors.textPrimary),
              ),
              InkWell(
                onTap: () async{
                  await getPairedDevices().then((_) {
                    showSnackbar(context,'Device list refreshed');
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh,color: ThemeColors.textSecondary,size: 20,),
                    const SizedBox(width: 5),
                    Text('Refresh',style: TextStyle(color: ThemeColors.textSecondary,fontSize: 20),),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Visibility(
            visible: _isConnecting && _isButtonUnavailable &&
                _bluetoothState == BluetoothState.STATE_ON,
            child: LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.secondaryColor),
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width > 500 ? 300 : MediaQuery.of(context).size.width*0.5,
                  child: DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (value) =>
                        _setState(() => _device = value),
                    value: _devicesList.isNotEmpty ? _device : null,
                    style: TextStyle(color: ThemeColors.textPrimary,fontSize: 22,overflow: TextOverflow.ellipsis),
                    iconSize: 25,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed:
                    _btConnected ? (){
                      _disconnect();
                      _setState(() {
                        _btDataSent=false;
                        _btConnected=false;
                      });
                    } :
                        (){
                      _connect();
                      setState(() {
                        _btDataToSend= btData(tle);
                      });
                      print(_btDataToSend);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryColor,foregroundColor: ThemeColors.backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    child: Text(_btConnected ? 'Disconnect' : 'Connect',style: const TextStyle(fontSize: 20),),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _btConnected ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To view the correct direction of the satellite, please align the 3D model to 0°N',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),),
              const SizedBox(height: 10,),
              SizedBox(
                height: 45,
                width: 220,
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Compass()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent,foregroundColor: ThemeColors.textPrimary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12))),
                    child: const Row(
                      children: [
                        Icon(Icons.compass_calibration_outlined),
                        SizedBox(width: 10,),
                        Flexible(child: Text('Open Compass',style: TextStyle(fontSize: 20),overflow: TextOverflow.visible,))
                      ],
                    )
                ),
              ),
              const SizedBox(height: 30,),
            ],
          ) :
          const SizedBox(),
          _btConnected && !_btDataSent ?
          SizedBox(
            width: 200,
            height: 45,
            child: ElevatedButton(
                onPressed: (){
                  send(_btDataToSend);
                  setState(() {
                    _btDataSent=true;
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primaryColor,foregroundColor: ThemeColors.backgroundColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/3d.png',width: 25,height: 25,color: ThemeColors.backgroundColor,),
                    const SizedBox(width: 10),
                    const Text('VIEW IN 3D',style: TextStyle(fontSize: 20),),
                  ],
                )
            ),
          ) :
          const SizedBox(),
          _btDataSent ?
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Data Sent',style: TextStyle(color: ThemeColors.textPrimary),),
               const SizedBox(height: 10),
               btReceived=='' ? Row(
                 children: [
                   CircularProgressIndicator(color: ThemeColors.primaryColor,),
                   const SizedBox(width: 5,),
                   Text('Waiting for response',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,)
                 ],
               ) :
               Text(btReceived,style: TextStyle(color: ThemeColors.secondaryColor,fontSize: 25,fontWeight: FontWeight.bold),overflow: TextOverflow.visible,),
             ],
           ) :
           const SizedBox(),
          const SizedBox(height: 30,),
          !_btConnected ?
          RichText(
              text: TextSpan(
                  text: 'Note: ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primaryColor
                  ),
                  children: [
                    TextSpan(
                      text: 'If you cannot find the device in the list, please pair the device by going to the ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'bluetooth settings.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.secondaryColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = (){
                          FlutterBluetoothSerial.instance.openSettings();
                        }
                    )
                  ]
              )
          ) :
          const SizedBox(),
          const SizedBox(height: 10,),
        ],
      ) :
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text: 'To view in 3D, please go to ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.textPrimary
                      ),
                      children: [
                        TextSpan(
                            text: 'bluetooth settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.secondaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = (){
                                FlutterBluetoothSerial.instance.openSettings();
                              }
                        ),
                        TextSpan(
                          text: ' and enable bluetooth.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.textPrimary,
                          ),
                        ),
                      ]
                  )
              ),
            ],
          )
    );
  }

  Future send(String _data) async {
    List<int> bytes = utf8.encode(_data);
    Uint8List data = Uint8List.fromList(bytes);
    _connection?.output.add(data);
    await _connection?.output.allSent;
    print(data);
  }

  Widget _buildVisualisingInLG(){
    return _viewingLG ?
    Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton.icon(
                  onPressed: (){
                    setState(() {
                      _orbit=!_orbit;
                      _simulate=false;
                      _satelliteBalloonVisible=true;
                      _orbitPeriod=3;
                    });
                    if(_orbit){
                      _lgService.startTour('Orbit');
                    }else{
                      _lgService.stopTour();
                      viewSatelliteLG(context, widget.satelliteModel, true);
                    }

                  },
                  icon: Icon(!_orbit ? Icons.flip_camera_android_rounded
                      : Icons.stop_rounded,
                    color: ThemeColors.primaryColor,size: 30,),
                  label: Text(_orbit ? 'STOP ORBIT' : 'ORBIT',style: TextStyle(color: ThemeColors.textPrimary,fontWeight: FontWeight.bold,fontSize: 25),)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balloon visibility',
                    style: TextStyle(
                      color: ThemeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Switch(
                    value: _satelliteBalloonVisible,
                    activeColor: ThemeColors.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _orbit = false;
                        _simulate = false;
                        _satelliteBalloonVisible=value;
                      });
                      viewSatelliteLG(
                        context,
                        widget.satelliteModel,
                        value,
                        updatePosition: false,
                      );
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Orbit period (h)',
                    style: TextStyle(
                      color: ThemeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        disabledActiveTrackColor: Colors.grey,
                        disabledThumbColor: Colors.grey.shade400,
                        disabledInactiveTrackColor:
                        Colors.grey.withOpacity(0.5),
                      ),
                      child: Slider(
                        value: _orbitPeriod,
                        min: 1,
                        max: 12,
                        divisions: 120,
                        activeColor:
                        ThemeColors.primaryColor.withOpacity(0.8),
                        thumbColor: ThemeColors.primaryColor,
                        inactiveColor: Colors.grey.withOpacity(0.8),
                        label: _orbitPeriod.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _orbitPeriod = value;
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _orbitPeriod = value;
                            _orbit = false;
                            _simulate = false;
                          });

                          viewSatelliteLG(
                            context,
                            widget.satelliteModel,
                            _satelliteBalloonVisible,
                            orbitPeriod: value,
                            updatePosition: false,
                          );

                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      alignment: Alignment.centerRight,
                      minimumSize: const Size(120, 24),
                    ),
                    icon: Icon(
                      !_simulate
                          ? Icons.rocket_launch_rounded
                          : Icons.stop_rounded,
                      color: ThemeColors.primaryColor,
                      size: 30,
                    ),
                    label: Text(
                      _simulate ? 'STOP SIMULATION' : 'SIMULATE',
                      style: TextStyle(
                        color: ThemeColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    onPressed: () async {

                      setState(() {
                        _orbit = false;
                        _simulate = !_simulate;
                      });
                      if (_simulate) {
                        _lgService.startTour('SimulationTour');
                      } else {
                        _lgService.stopTour();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ) :
        const SizedBox();
  }

  /// Gets the status data from the current [satellite].
  Map<String, dynamic> _getStatusData() {
    switch (widget.satelliteModel.status) {
      case 'alive':
        return {
          'icon': Icons.check_circle_rounded,
          'title': 'Operational',
          'description': 'Satellite is in orbit.',
          'color': ThemeColors.success,
        };
      case 're-entered':
        return {
          'icon': Icons.transit_enterexit_rounded,
          'title': 'Decayed',
          'description': 'Satellite has re-entered',
          'color': ThemeColors.warning,
        };
      case 'future':
        return {
          'icon': Icons.av_timer_rounded,
          'title': 'Future',
          'description': 'Satellite is not yet in orbit',
          'color': ThemeColors.info,
        };
      case 'dead':
        return {
          'icon': Icons.public_off_rounded,
          'title': 'Malfunctioning ',
          'description': 'Satellite appears to be malfunctioning',
          'color': ThemeColors.alert
        };
    }
    return {
      'icon': Icons.add,
      'title': 'Decayed',
      'description': 'Satellite has re-entered',
      'color': ThemeColors.warning,
    };
  }

  // Opens the satellite `website`.
  void _openLink() async {
    final Uri _url = Uri.parse(widget.satelliteModel.website.toString());

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Widget divider(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      color: ThemeColors.dividerColor,
      margin: const EdgeInsets.only(top: 16),
    );
  }

  Widget shimmerTile(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerEffect().shimmer(Container(
            height: 15,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey))),
        const SizedBox(height: 10),
        ShimmerEffect().shimmer(Container(
            height: 15,
            width: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey))),
        const SizedBox(height: 30)
      ],
    );
  }

  void checkTLE(List<String> tle){
    int numLines = tle.length;
    if(numLines==4){
      tleExists=true;
    }
  }

  void checkWebsiteDialog(){
    if(_localStorageService.hasItem(StorageKeys.website)) {
      setState(() {
      websiteDialog = _localStorageService.getItem(StorageKeys.website);
    });
    }
  }

  void btInit(){
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _deviceState=0;

    // enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  String btData(String TLE){
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
    TLE = "$TLE,${date.year},${date.month},${date.day},${date.hour},${date.minute},${date.second}";
    TLE = "$TLE,$latitude,$longitude,$altitude";
    print(TLE);
    return TLE;
  }

  /// Determine the current position of the device.
  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _location='Location services are disabled.';
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _location='Location permissions are denied';
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _location='Location permissions are permanently denied, we cannot request permissions.';
      // Permissions are denied forever, handle appropriately.
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _location='access';
    print(_location);
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude=position.latitude.toString();
      longitude=position.longitude.toString();
      altitude=position.altitude.toString();
      print('latitude: $latitude');
    });
    // Location location = Location();
    //
    // bool serviceEnabled;
    // PermissionStatus permissionGranted;
    // LocationData locationData;
    //
    // serviceEnabled = await location.serviceEnabled();
    // if (!serviceEnabled) {
    //   serviceEnabled = await location.requestService();
    //   if (!serviceEnabled) {
    //     return;
    //   }
    // }
    //
    // permissionGranted = await location.hasPermission();
    // if (permissionGranted == PermissionStatus.denied) {
    //   permissionGranted = await location.requestPermission();
    //   if (permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }
    //
    // locationData = await location.getLocation();
    // setState(() {
    //   _location="granted";
    //   latitude=locationData.latitude.toString();
    //   longitude=locationData.longitude.toString();
    //   altitude=locationData.altitude.toString();
    //   if(double.parse(altitude) < 0){
    //     altitude="0";
    //   }
    // });
    // print("$latitude $longitude $altitude");
  }

  // Request Bluetooth permission from the user
  // Future<bool> enableBluetooth() async {
  //   // Retrieving the current Bluetooth state
  //   _bluetoothState = await FlutterBluetoothSerial.instance.state;
  //
  //   // If the bluetooth is off, then turn it on first
  //   // and then retrieve the devices that are paired.
  //   if (_bluetoothState == BluetoothState.STATE_OFF) {
  //     await FlutterBluetoothSerial.instance.requestEnable();
  //     await getPairedDevices();
  //     return true;
  //   } else {
  //     await getPairedDevices();
  //   }
  //   return false;
  // }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      if (kDebugMode) {
        print("Error");
      }
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

// Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
      _isConnecting=true;
    });
    if (_device == null) {
      showSnackbar(context,'No device selected');
    } else {

      if (!isConnected) {
        await BluetoothConnection.toAddress(_device?.address)
            .then((connection) {
          _connection = connection;
          setState(() {
            _btConnected = true;
          });

          //get data from HC-05
          _connection?.input?.listen((Uint8List data) {
            setState(() {
              btReceived=utf8.decode(data);
            });
            if (mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          if (kDebugMode) {
            print(error);
          }
        });
        if(mounted){
          showSnackbar(context,'Device connected');
        }

        setState(() {
          _isButtonUnavailable = false;
          _isConnecting=false;
        });
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await _connection?.close();
    showSnackbar(context,'Device disconnected');
    if (!_connection!.isConnected) {
      setState(() {
        _btConnected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  Future<void> viewSatelliteLG(BuildContext context, SatelliteModel satellite, bool showBalloon,
      {double orbitPeriod = 2.8, bool updatePosition = true})
  async {

    if(lgConnected==false){
      showSnackbar(context, 'Connection failed');
    }
    else{

      try {
        final tleCoord = tleModel.read();
        final placemark = _satelliteService.buildPlacemark(
          satellite,
          tleModel,
          showBalloon,
          orbitPeriod,
          lookAt: _satellitePlacemark != null && !updatePosition
              ? _satellitePlacemark!.lookAt
              : null,
          updatePosition: updatePosition,
        );

        setState(() {
          _satellitePlacemark = placemark;
        });
        //
        final kml = KMLEntity(
          name: satellite.name.toString().replaceAll(
              RegExp(r'[^a-zA-Z0-9]'), ''),
          content: placemark.tag,
        );

        try{
          await _lgService.sendKml(
            kml,
            images: [
              {
                'name': 'satellite.png',
                'path': 'assets/satellite.png',
              }
            ],
          );
        }
        catch(e){
          print('error :$e');
        }

        if (_lgService.balloonScreen == _lgService.logoScreen) {
          await _lgService.setLogos(
            name: 'CSt-logos-balloon',
            content: '''
            <name>Logos-Balloon</name>
            ${placemark.balloonOnlyTag}
          ''',
          );
        } else {
          final kmlBalloon = KMLEntity(
            name: 'CSt-balloon',
            content: placemark.balloonOnlyTag,
          );
          await _lgService.sendKMLToSlave(
            _lgService.balloonScreen,
            kmlBalloon.body,
          );
        }
        if (updatePosition) {
          await _lgService.flyTo(LookAtEntity(
            lat: tleCoord['lat']!,
            lng: tleCoord['lng']!,
            altitude: tleCoord['alt']!,
            range: '4000000',
            tilt: '60',
            heading: '0',
          ));
        }
        // await Future.delayed(const Duration(seconds: 5));
        // try{
        //   await _lgService.stopTour();
        // }
        // catch(e){
        //   print(e);
        // }

        final orbit = _satelliteService.buildOrbit(satellite, tleModel);
        try{
          await _lgService.sendTour(orbit, 'Orbit');
        }
        catch(e){
          print(e);
        }
        setState(() {
          _viewingLG=true;
        });
      } on Exception catch (_) {
        showSnackbar(context, 'Connection failed!');
      } catch (_) {
        print(_);
        showSnackbar(context, 'Connection failed!!');
      }

    }

  }

}
