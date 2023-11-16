import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_cubit.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_state.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/satellite_info.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/settings.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/storage_keys.dart';

import '../repositories/countries_iso.dart';
import '../services/local_storage_service.dart';
import '../utils/snackbar.dart';
import '../utils/date.dart';
import '../widgets/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  LocalStorageService get _localStorageService => GetIt.I<LocalStorageService>();
  TextEditingController _searchController = TextEditingController();
  bool lgConnected=false;
  FocusNode _searchFocusNode = FocusNode();
  String dropdownvalueCountries = 'ALL';
  String dropdownvalueStatus = 'ALL';
  String dropdownvalueOperators = 'ALL';
  List<String> itemsCountries = [
    'ALL',
  ];
  List<String> itemsStatus = [
    'ALL',
    'ALIVE',
    'DEAD',
    'RE-ENTERED',
    'FUTURE'
  ];
  List<String> itemsOperators = [];
  List iso = ISO().iso;
  bool decayed = false, launched=false, deployed=false, filter=false,sort=false;
  bool featured=true, launchNew=false, launchOld=false;
  String location = "";
  double latitude=0, longitude=0, altitude=0;
  bool gotServo = false, range3d=false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _dropDownCountries();
    checkFilter();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
    _dropDownOperators();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      checkLGConnection();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  //check if lg is connected
  void checkLGConnection() {
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


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SatelliteCubit(),
      child: BlocConsumer<SatelliteCubit, SatelliteState>(
        listener: (context,state){
          if(state is SatelliteErrorState){
            showSnackbar(context, state.error);
          }
        },
        builder: (context, state){
          if(state is SatelliteLoadingState){
            return Scaffold(
              backgroundColor: ThemeColors.backgroundCardColor,
              appBar: AppBar(
                centerTitle: false,
                foregroundColor: ThemeColors.textPrimary,
                backgroundColor: ThemeColors.backgroundCardColor,
                elevation: 0,
                title: const Text("STEAM Celestial Satellite tracker",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                actions: [
                  IconButton(
                      onPressed: (){},
                      icon: IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Settings()));
                        },
                      )
                  )
                ],
              ),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ShimmerEffect().shimmer(Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Card(
                        elevation: 2,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey), // Set the base color of the shimmer effect
                        ),
                      ),
                    )),
                    ShimmerEffect().shimmer(Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.5-130,
                            height: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10,),
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey),
                            width: 200,
                          ),
                          const SizedBox(width: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.5-130,
                            height: 1,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    )),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                    shimmerList(),
                  ],
                ),
              ),
            );
          }
          else if(state is SatelliteLoadedState){
            List<SatelliteModel> satellites = state.satellites;
            double textWidth = _textWidth('${satellites.length} SATELLITES', TextStyle(fontSize: 20,color: ThemeColors.textPrimary));
            return Scaffold(
              backgroundColor: ThemeColors.backgroundCardColor,
              body: CustomScrollView(
                slivers: [
                  sliverAppBar(context,state),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            SafeArea(
                                child:SingleChildScrollView(
                                  physics: const ScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: Row(
                                            children: [
                                              divider(textWidth),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                child: Text('${satellites.length} SATELLITES',style: TextStyle(fontSize: 20,color: ThemeColors.textPrimary)),
                                              ),
                                              divider(textWidth),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                            primary: false,
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: satellites.length,
                                            itemBuilder:(context, index){
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => SatelliteInfo(satellites[index], location, latitude, longitude, altitude)));
                                                },
                                                child: _buildList(context, satellites[index]),
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            )
                          ]
                      )
                  )
                ],
              ),
              bottomNavigationBar: bottomRow(context,state),
            );
          }
          else if(state is FilteredSatelliteState){
            List<SatelliteModel> searchedSatellites = state.searchedSatellites;
            double textWidth = _textWidth('${searchedSatellites.length} SATELLITES', const TextStyle(fontSize: 20,color: Colors.black));
            return Scaffold(
              backgroundColor: ThemeColors.backgroundCardColor,
              body: CustomScrollView(
                slivers: [
                  sliverAppBar(context,state),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            SafeArea(
                                child: SingleChildScrollView(
                                  physics: const ScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: Row(
                                            children: [
                                              divider(textWidth),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child: Text('${searchedSatellites.length} SATELLITES',style: TextStyle(fontSize: 20,color: ThemeColors.textPrimary)),
                                              ),
                                              divider(textWidth),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                            primary: false,
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: searchedSatellites.length,
                                            itemBuilder:(context, index){
                                              return InkWell(
                                                onTap: () async{
                                                  final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => SatelliteInfo(searchedSatellites[index],location, latitude, longitude, altitude)));
                                                  if(result == "range" && range3d && filter && mounted){
                                                      context.read<SatelliteCubit>().filterSearchData(
                                                          _searchController.text,
                                                          dropdownvalueCountries,
                                                          dropdownvalueStatus,
                                                          decayed,
                                                          launched,
                                                          deployed,
                                                          dropdownvalueOperators,
                                                          featured,
                                                          launchNew,
                                                          launchOld,
                                                          range3d);
                                                  }
                                                },
                                                child: _buildList(context, searchedSatellites[index]),
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            )
                          ]
                      )
                  )
                ],
              ),
              bottomNavigationBar: bottomRow(context,state),
            );
          }
          return Scaffold(
            backgroundColor: ThemeColors.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("An error occurred!",overflow: TextOverflow.visible,style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height: 45,
                    width: 150,
                    child: ElevatedButton(
                        onPressed: (){
                          context.read<SatelliteCubit>().fetchData();
                          context.read<SatelliteCubit>().emit(SatelliteLoadingState());
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor),
                        child: const Text('TRY AGAIN',style: TextStyle(fontSize: 20),),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildList(BuildContext context, SatelliteModel satellites){
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: ThemeColors.backgroundColor,
      child:  Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    satellites.name.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 22),
                  ),
                ),
                Flexible(
                  child: Text(
                    satellites.status!.toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(satellites.status.toString(),),
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5,),
            satellites.launched.toString().isEmpty || satellites.launched.toString() == 'null' ?
            Container()
                : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text('${checkLaunch(satellites.launched!)}  -  ${parseDateString(satellites.launched!)}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18,color: ThemeColors.textSecondary)),
            ),
            const SizedBox(height: 15),
            Text('# ${satellites.satId}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 18,color: ThemeColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                satellites.noradCatId.toString() == 'null'
                    ? const SizedBox()
                    : Text(satellites.noradCatId.toString(),style: TextStyle(color: ThemeColors.primaryColor,fontWeight: FontWeight.bold,fontSize: 20),overflow: TextOverflow.visible,),
                satellites.countries.toString() == 'null' || satellites.countries.toString().isEmpty
                   ? const SizedBox()
                   : MediaQuery.of(context).size.width >= 500 ?
                       Row(
                         children: [
                           Icon(Icons.outlined_flag_rounded,color: ThemeColors.textPrimary,),
                           Text(' ${satellites.countries}',style: TextStyle(fontSize: 20,color: ThemeColors.textPrimary),overflow: TextOverflow.ellipsis,)
                   ],
                ) : const SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the color of satellite status
  Color? _getStatusColor(String status) {
    switch (status) {
      case 'alive':
        return ThemeColors.success;
      case 're-entered':
        return ThemeColors.warning;
      case 'future':
        return ThemeColors.info;
      case 'dead':
        return ThemeColors.alert;
    }
    return ThemeColors.backgroundColor;
  }

  double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  void refresh(BuildContext context,SatelliteState state){
    setState(() {
      featured=true;
      launchNew=false;
      launchOld=false;
      sort=false;
      filter=false;
      _searchController.text = "";
    });
    context.read<SatelliteCubit>().fetchData(refresh: true);
    context.read<SatelliteCubit>().emit(SatelliteLoadingState());
  }

  SliverAppBar sliverAppBar(BuildContext context,SatelliteState state)
  {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      centerTitle: false,
      foregroundColor: ThemeColors.textPrimary,
      backgroundColor: ThemeColors.backgroundCardColor,
      elevation: 0,
      title: const Text("STEAM Celestial Satellite tracker",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
      actions: [
        TextButton(
          onPressed: null,
          child: Text(
            lgConnected ? 'LG: CONNECTED' : 'LG: NOT CONNECTED',style: TextStyle(color: lgConnected ? ThemeColors.success : ThemeColors.alert,fontSize: 19),overflow: TextOverflow.visible,
          ),
        ),
        IconButton(
              icon: Icon(Icons.settings,color: ThemeColors.textPrimary,),
              tooltip: 'Settings',
              onPressed: () async {
                   final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Settings()));
                   if(result=="pop"){
                     checkLGConnection();
                   }
                   if(result=="refresh"){
                     if(mounted){
                       refresh(context, state);
                     }
                   }
              },
        ),
        const SizedBox(width: 5)
      ],
 bottom: AppBar(
  elevation: 0,
  backgroundColor: ThemeColors.backgroundCardColor,
  title: Padding(
    padding: const EdgeInsets.only(bottom:15),
    child: Column(
      children: [
        const SizedBox(height: 10,),
        Card(
          color: ThemeColors.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation:2,
          child: Stack(
            children: [
              TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onChanged: (val) {
                  context.read<SatelliteCubit>().filterSearchData(
                    val,
                    dropdownvalueCountries,
                    dropdownvalueStatus,
                    decayed,
                    launched,
                    deployed,
                    dropdownvalueOperators,
                    featured,
                    launchNew,
                    launchOld,
                    range3d,
                  );
                },
                keyboardType: TextInputType.text,
                cursorColor: ThemeColors.primaryColor,
                style: TextStyle(color: ThemeColors.textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: ThemeColors.searchBarColor),
                  hintText: 'Search satellites..',
                  prefixIcon: Icon(Icons.search, color: ThemeColors.primaryColor),
                ),
              ),
              Visibility(
                visible: _searchController.text.isNotEmpty,
                child: Positioned(
                  right: 8,
                  top: 1,
                  child: IconButton(
                    icon: Icon(Icons.clear, color: ThemeColors.primaryColor),
                    onPressed: () {
                      _searchController.clear();
                        },
                      ),
                    ),
                  ),
                ],
            ),
           ),
         ],
      ),
    ),
    ),
  );
}

  Widget divider(double textWidth){
    return Container(
      width: (MediaQuery.of(context).size.width - textWidth - 60)*0.5,
      height: 0.5,
      color: ThemeColors.textPrimary,
    );
  }

  void _dropDownCountries(){
    for(int i=0;i<iso.length;i++){
      Map<String, String> data = iso[i];
      itemsCountries.add(data['Name'].toString());
    }
  }

  Future<void> _dropDownOperators() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    itemsOperators.add('ALL');
    List<String>? items = prefs.getStringList('operators');
    for(int i=0;i<items!.length;i++){
      itemsOperators.add(items![i]);
    }
  }

  Widget buildSort(BuildContext context, StateSetter _setState){
    return BlocProvider.value(
        value: BlocProvider.of<SatelliteCubit>(context),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text('SORT BY',style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                thickness: 0.5,
                height: 0.5,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 10,),
            InkWell(
              onTap: (){
                _setState(() {
                  featured=true;
                  launchNew=false;
                  launchOld=false;
                  sort=false;
                });
                  Navigator.pop(context);
                    context.read<SatelliteCubit>().filterSearchData(
                        _searchController.text,
                        dropdownvalueCountries,
                        dropdownvalueStatus,
                        decayed,
                        launched,
                        deployed,
                        dropdownvalueOperators,
                        featured,
                        launchNew,
                        launchOld,
                        range3d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  width: double.infinity ,
                  child: sortItem('Featured', featured)
              ),
            ),
            InkWell(
              onTap: (){
                _setState(() {
                  featured=false;
                  launchNew=true;
                  launchOld=false;
                  sort=true;
                });
                  Navigator.pop(context);
                  context.read<SatelliteCubit>().filterSearchData(
                      _searchController.text,
                      dropdownvalueCountries,
                      dropdownvalueStatus,
                      decayed,
                      launched,
                      deployed,
                      dropdownvalueOperators,
                      featured,
                      launchNew,
                      launchOld,
                      range3d);
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  width: double.infinity ,
                  child: sortItem('Launch date - New to Old', launchNew)
              ),
            ),
            InkWell(
              onTap: (){
                _setState(() {
                  featured=false;
                  launchNew=false;
                  launchOld=true;
                  sort=true;
                });
                  Navigator.pop(context);
                  context.read<SatelliteCubit>().filterSearchData(
                      _searchController.text,
                      dropdownvalueCountries,
                      dropdownvalueStatus,
                      decayed,
                      launched,
                      deployed,
                      dropdownvalueOperators,
                      featured,
                      launchNew,
                      launchOld,
                      range3d);
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  width: double.infinity ,
                  child: sortItem('Launch date - Old to New', launchOld)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilter(BuildContext context, StateSetter _setState){
    return BlocProvider.value(
      value: BlocProvider.of<SatelliteCubit>(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('FILTERS',style: TextStyle(fontSize: 22,color: ThemeColors.textPrimary),),
                const SizedBox(height: 20),
                Divider(
                  thickness: 0.5,
                  height: 0.5,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 20,),
                Text('Country of Origin',style: TextStyle(fontSize:18, fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                DropdownButton(
                  // isExpanded: true,
                    elevation: 4,
                    value: dropdownvalueCountries,
                    underline: Container(
                        height: 1, color:ThemeColors.textPrimary),
                    style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),
                    items: itemsCountries.map((String items){
                      return DropdownMenuItem(
                        value: items,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width-50,
                            child: Text(items,overflow: TextOverflow.ellipsis,)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _setState(() {
                        dropdownvalueCountries = newValue!;
                        checkFilter();
                      });
                    }
                ),
                const SizedBox(height: 30,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',style: TextStyle(fontSize:18, fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                        DropdownButton(
                          // isExpanded: true,
                            elevation: 4,
                            value: dropdownvalueStatus,
                            underline: Container(
                                height: 1, color:ThemeColors.textPrimary),
                            style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),
                            items: itemsStatus.map((String items){
                              return DropdownMenuItem(
                                value: items,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.3,
                                    child: Text(items,overflow: TextOverflow.ellipsis,)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              _setState(() {
                                dropdownvalueStatus = newValue!;
                                checkFilter();
                              });
                            }
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operators',style: TextStyle(fontSize:18, fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                        DropdownButton(
                          // isExpanded: true,
                            elevation: 4,
                            value: dropdownvalueOperators,
                            underline: Container(
                                height: 1, color:ThemeColors.textPrimary),
                            style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),
                            items: itemsOperators.map((String items){
                              return DropdownMenuItem(
                                value: items,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width*0.3,
                                    child: Text(items,overflow: TextOverflow.ellipsis,)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              _setState(() {
                                dropdownvalueOperators = newValue!;
                                checkFilter();
                              });
                            }
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(child: Text('Decayed',style: TextStyle(fontSize: 18, color: ThemeColors.textPrimary),overflow: TextOverflow.visible)),
                          Checkbox(
                            value: decayed,
                            onChanged: (bool? value){
                              _setState(() {
                                decayed = value!;
                                checkFilter();
                              });
                            },
                            checkColor: ThemeColors.backgroundColor,
                            activeColor: ThemeColors.primaryColor,
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(child:Text('Launched',style: TextStyle(fontSize: 18, color: ThemeColors.textPrimary),overflow: TextOverflow.visible)),
                          Checkbox(
                            value: launched,
                            onChanged: (bool? value){
                              _setState(() {
                                launched = value!;
                                checkFilter();
                              });
                            },
                            checkColor: ThemeColors.backgroundColor,
                            activeColor: ThemeColors.primaryColor,
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(child: Text('Deployed',style: TextStyle(fontSize: 18, color: ThemeColors.textPrimary),overflow: TextOverflow.visible,)),
                          Checkbox(
                            value: deployed,
                            onChanged: (bool? value){
                              _setState(() {
                                deployed = value!;
                                checkFilter();
                              });
                            },
                            checkColor: ThemeColors.backgroundColor,
                            activeColor: ThemeColors.primaryColor,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                location=="access" ?
                Row(
                  children: [
                    Checkbox(
                      value: range3d,
                      onChanged: (bool? value){
                        _setState(() {
                          range3d = value!;
                          checkFilter();
                        });
                      },
                      checkColor: ThemeColors.backgroundColor,
                      activeColor: ThemeColors.primaryColor,
                    ),
                    Flexible(child: Text('Only show the satellites that are in range to view in 3D',style: TextStyle(fontSize: 18, color: ThemeColors.textPrimary),overflow: TextOverflow.visible)),
                  ],
                ) :
                const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          const Divider(
            height: 5,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filter ?
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (){
                      _setState(() {
                        dropdownvalueCountries='ALL';
                        dropdownvalueStatus='ALL';
                        dropdownvalueOperators='ALL';
                        deployed=false;
                        decayed=false;
                        launched=false;
                        range3d=false;
                      });
                      setState(() {

                      });
                      checkFilter();
                      Navigator.pop(context);
                      context.read<SatelliteCubit>().filterSearchData(
                          _searchController.text,
                          dropdownvalueCountries,
                          dropdownvalueStatus,
                          decayed,
                          launched,
                          deployed,
                          dropdownvalueOperators,
                          featured,
                          launchNew,
                          launchOld,
                          range3d);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.backgroundColor,elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12))),
                    child: Text('CLEAR',style: TextStyle(color: ThemeColors.primaryColor,fontSize: 20),),
                  ),
                ) :
                const SizedBox(),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (){
                      checkFilter();
                      Navigator.pop(context);
                        context.read<SatelliteCubit>().filterSearchData(
                            _searchController.text,
                            dropdownvalueCountries,
                            dropdownvalueStatus,
                            decayed,
                            launched,
                            deployed,
                            dropdownvalueOperators,
                            featured,
                            launchNew,
                            launchOld,
                            range3d);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                    child: Text('APPLY',style: TextStyle(color: ThemeColors.backgroundColor,fontSize: 20),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomRow(BuildContext context,SatelliteState state){
    return BottomAppBar(
      color: ThemeColors.backgroundColor,
      elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
              onTap: (){
                showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: false,
                    backgroundColor: ThemeColors.backgroundColor,
                    context: context,
                    builder: (_context) => StatefulBuilder(
                        builder: (BuildContext _context, StateSetter _setState){
                          return buildSort(context,_setState);
                        }),
                    isScrollControlled: true,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width*0.5-0.25,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sort_rounded,color: Colors.black54,size: 25,),
                    const SizedBox(width: 10,),
                    const Text('SORT',style: TextStyle(color: Colors.black54,fontSize: 20),),
                    sort ?
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0,left: 5),
                      child: Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeColors.primaryColor
                        ),
                      ),
                    ) :
                    const SizedBox()
                  ],
                ),
              )
          ),
          Container(
            width: 0.5,
            height: 20,
            color: Colors.black54,
          ),
          InkWell(
              onTap: (){
                showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: false,
                    backgroundColor: ThemeColors.backgroundColor,
                    context: context,
                    builder: (_context) => StatefulBuilder(
                        builder: (BuildContext _context, StateSetter _setState){
                          return buildFilter(context,_setState);
                        }),
                    isScrollControlled: true,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width*0.5-0.25,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_list,color: Colors.black54,size: 25,),
                    const SizedBox(width: 10,),
                    const Text('FILTER',style: TextStyle(color: Colors.black54,fontSize: 20),),
                    filter ?
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0,left: 5),
                      child: Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeColors.primaryColor
                        ),
                      ),
                    ) :
                    const SizedBox()
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget sortItem(String message, bool check){
    return Text(message,style: TextStyle(fontSize: 20,color: check ? ThemeColors.primaryColor : ThemeColors.textSecondary),);
  }

  void checkFilter(){
    if(decayed == false && deployed == false && launched == false && range3d == false && dropdownvalueCountries == 'ALL' && dropdownvalueStatus == 'ALL' && dropdownvalueOperators=='ALL'){
      setState(() {
        filter=false;
      });
    }
    else{
      setState(() {
        filter=true;
      });
    }
  }

  void _determinePosition() async {
    if(_localStorageService.hasItem(StorageKeys.latitude)){
      setState(() {
        location=_localStorageService.getItem(StorageKeys.location);
        latitude=_localStorageService.getItem(StorageKeys.latitude);
        longitude=_localStorageService.getItem(StorageKeys.longitude);
        altitude=_localStorageService.getItem(StorageKeys.altitude);
      });
    }
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      location='Location services are disabled.';
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        location='Location permissions are denied';
        // Permissions are denied, next time you could try
        // requesting permissions again
      }
    }

    if (permission == LocationPermission.deniedForever) {
      location='Location permissions are permanently denied, we cannot request permissions.';
      // Permissions are denied forever, handle appropriately.
    }
    setState(() {
      location="granted";
    });
    Position position = await Geolocator.getCurrentPosition();
      setState(() {
        location='access';
        latitude=position.latitude;
        longitude=position.longitude;
        altitude=position.altitude;
        _localStorageService.setItem(StorageKeys.location, location);
        _localStorageService.setItem(StorageKeys.latitude, latitude);
        _localStorageService.setItem(StorageKeys.longitude, longitude);
        _localStorageService.setItem(StorageKeys.altitude, altitude);
      });
  }


  String checkLaunch(String _datetime){
    String current = DateTime.now().toString();
    if(current.compareTo(_datetime)<0){
      return 'Launching On';
    }
    return 'Launched';
  }

  Widget shimmerList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerEffect().shimmer(Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey))),
              const SizedBox(
                height: 15,
              ),
              ShimmerEffect().shimmer(Container(
                  height: 10,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey))),
              const SizedBox(
                height: 20,
              ),
              ShimmerEffect().shimmer(Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }

}
