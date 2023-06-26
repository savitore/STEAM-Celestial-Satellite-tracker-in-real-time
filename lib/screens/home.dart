import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_cubit.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_state.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/satellite_info.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/settings.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/widgets/custom_page_route.dart';

import '../repositories/countries_iso.dart';
import '../utils/snackbar.dart';
import '../widgets/date.dart';
import '../widgets/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _searchController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _dropDownCountries();
    _dropDownOperators();
    checkFilter();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
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
                title: const Text('Celestial Satellite tracker'),
                actions: [
                  IconButton(
                      onPressed: (){},
                      icon: IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: (){
                          Navigator.of(context).push(
                              CustomPageRoute(child: const Settings())
                          );
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
                                                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                                onTap: (){
                                                  Navigator.of(context).push(
                                                      CustomPageRoute(child: SatelliteInfo(satellites[index]))
                                                  );
                                                },
                                                child: _buildList(context, index, satellites[index]),
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
                                                onTap: (){
                                                  Navigator.of(context).push(
                                                      CustomPageRoute(child: SatelliteInfo(searchedSatellites[index]))
                                                  );
                                                },
                                                child: _buildList(context, index, searchedSatellites[index]),
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


  Widget _buildList(BuildContext context, int index, SatelliteModel satellites){
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
                    style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),
                  ),
                ),
                Flexible(
                  child: Text(
                    satellites.status!.toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(satellites.status.toString(),),
                        fontWeight: FontWeight.bold
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
                  child: Text('${checkLaunch(satellites.launched!)}  -  ${parseDateString(satellites.launched!)}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: ThemeColors.textPrimary)),
            ),
            satellites.deployed.toString().isEmpty || satellites.deployed.toString() == 'null' ?
            Container()
                : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text('Deployed  -  ${parseDateString(satellites.deployed!)}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: ThemeColors.textPrimary)),
            ),
            satellites.decayed.toString().isEmpty || satellites.decayed.toString() == 'null' ?
            Container()
                : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text('Decayed  -  ${parseDateString(satellites.decayed!)}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: ThemeColors.textPrimary)),
            ),
            satellites.noradCatId.toString() == 'null'
                ? const SizedBox()
                : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(satellites.noradCatId.toString(),style: TextStyle(color: ThemeColors.primaryColor,fontWeight: FontWeight.bold,fontSize: 18),overflow: TextOverflow.visible,),
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

  IconButton? _clear(BuildContext context){
    return _searchController.text.isEmpty ? null : IconButton(
      icon: const Icon(Icons.clear,color: Colors.grey),
      onPressed: (){
        _searchController.clear();
        context.read<SatelliteCubit>().filterSearchData(_searchController.text,dropdownvalueCountries,dropdownvalueStatus,decayed,launched,deployed, dropdownvalueOperators,featured,launchNew,launchOld);
      },
    );
  }

  SliverAppBar sliverAppBar(BuildContext context,SatelliteState state){
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      centerTitle: false,
      foregroundColor: ThemeColors.textPrimary,
      backgroundColor: ThemeColors.backgroundCardColor,
      elevation: 0,
      title: const Text('STEAM Celestial Satellite tracker'),
      actions: [
        IconButton(
            onPressed: (){},
            icon: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: (){
                Navigator.of(context).push(
                    CustomPageRoute(child: const Settings())
                );
              },
            )
        ),
        const SizedBox(width: 5)
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: ThemeColors.backgroundCardColor,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Card(
              color: ThemeColors.backgroundColor,
              elevation: 2,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        onChanged: (val){
                          context.read<SatelliteCubit>().filterSearchData(val,dropdownvalueCountries,dropdownvalueStatus,decayed,launched,deployed,dropdownvalueOperators,featured,launchNew,launchOld);
                        },
                        keyboardType: TextInputType.text,
                        cursorColor: ThemeColors.primaryColor,
                        style: TextStyle(color: ThemeColors.textPrimary),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: ThemeColors.searchBarColor),
                            hintText: 'Search satellites..',
                            prefixIcon: Icon(Icons.search,color: ThemeColors.primaryColor),
                            suffixIcon: _clear(context)
                        ),
                      ),
                    ),
                    // Text('|',style: TextStyle(fontSize: 30,color: ThemeColors.searchBarColor),),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 0),
                    //   child: IconButton(
                    //     icon: Icon(Icons.filter_list_rounded,color: filter ? ThemeColors.primaryColor : ThemeColors.searchBarColor),
                    //     onPressed: (){
                    //
                    //     },
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
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
    for(int i=0;i<prefs.getStringList('operators')!.length;i++){
      itemsOperators.add(prefs.getStringList('operators')![i]);
    }
    print(prefs.getStringList('operators'));
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
              child: Text('SORT BY',style: TextStyle(fontSize: 16,color: ThemeColors.textPrimary),),
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
                      launchOld);
                });
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
                      launchOld);
                });
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
                      launchOld);
                });
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
                Text('Filters',style: TextStyle(fontSize: 16,color: ThemeColors.textPrimary),),
                const SizedBox(height: 10),
                Divider(
                  thickness: 0.5,
                  height: 0.5,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 20,),
                Text('Country of Origin',style: TextStyle(fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                DropdownButton(
                  // isExpanded: true,
                    elevation: 4,
                    value: dropdownvalueCountries,
                    underline: Container(
                        height: 1, color:ThemeColors.textPrimary),
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
                        Text('Status',style: TextStyle(fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                        DropdownButton(
                          // isExpanded: true,
                            elevation: 4,
                            value: dropdownvalueStatus,
                            underline: Container(
                                height: 1, color:ThemeColors.textPrimary),
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
                        Text('Operators',style: TextStyle(fontWeight: FontWeight.w500,color: ThemeColors.primaryColor),),
                        DropdownButton(
                          // isExpanded: true,
                            elevation: 4,
                            value: dropdownvalueOperators,
                            underline: Container(
                                height: 1, color:ThemeColors.textPrimary),
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
                          Flexible(child: Text('Decayed',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible)),
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
                          Flexible(child:Text('Launched',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible)),
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
                          Flexible(child: Text('Deployed',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible,)),
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
              ],
            ),
          ),
          const SizedBox(height: 10,),
          const Divider(
            height: 5,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filter ?
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: (){
                      _setState(() {
                        dropdownvalueCountries='ALL';
                        dropdownvalueStatus='ALL';
                        dropdownvalueOperators='ALL';
                        deployed=false;
                        decayed=false;
                        launched=false;
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
                          launchOld);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.backgroundColor,elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),side: const BorderSide(color: Colors.black12))),
                    child: Text('Clear Filters',style: TextStyle(color: ThemeColors.primaryColor,fontSize: 18),),
                  ),
                ) :
                const SizedBox(),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: (){
                      checkFilter();
                      Navigator.pop(context);
                      if(filter) {
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
                            launchOld);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                    child: Text('Filter Satellites',style: TextStyle(color: ThemeColors.backgroundColor,fontSize: 18),),
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: ThemeColors.backgroundColor,
      elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: (){
                showModalBottomSheet(
                    isDismissible: true,
                    backgroundColor: ThemeColors.backgroundColor,
                    context: context,
                    builder: (_context) => StatefulBuilder(
                        builder: (BuildContext _context, StateSetter _setState){
                          return buildSort(context,_setState);
                        }),
                    isScrollControlled: true,
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded,color: Colors.black54,),
                  const SizedBox(width: 10,),
                  const Text('SORT',style: TextStyle(color: Colors.black54),),
                  sort ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0,left: 5),
                    child: Container(
                      width: 5.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeColors.primaryColor
                      ),
                    ),
                  ) :
                  const SizedBox()
                ],
              )
          ),
          Container(
            width: 0.5,
            height: 20,
            color: Colors.black54,
          ),
          GestureDetector(
              onTap: (){
                showModalBottomSheet(
                    isDismissible: true,
                    backgroundColor: ThemeColors.backgroundColor,
                    context: context,
                    builder: (_context) => StatefulBuilder(
                        builder: (BuildContext _context, StateSetter _setState){
                          return buildFilter(context,_setState);
                        }),
                    isScrollControlled: true,
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.filter_list,color: Colors.black54,),
                  const SizedBox(width: 10,),
                  const Text('FILTER',style: TextStyle(color: Colors.black54),),
                  filter ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0,left: 5),
                    child: Container(
                      width: 5.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeColors.primaryColor
                      ),
                    ),
                  ) :
                  const SizedBox()
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget sortItem(String message, bool check){
    return Text(message,style: TextStyle(fontSize: 16,color: check ? ThemeColors.primaryColor : ThemeColors.textSecondary),);
  }

  void checkFilter(){
    if(decayed == false && deployed == false && launched == false && dropdownvalueCountries == 'ALL' && dropdownvalueStatus == 'ALL' && dropdownvalueOperators=='ALL'){
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
