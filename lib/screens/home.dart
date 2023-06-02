import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_cubit.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_state.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/satellite_info.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/settings.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/widgets/custom_page_route.dart';

import '../repositories/countries_iso.dart';
import '../widgets/date.dart';

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
  List iso = ISO().iso;
  bool decayed = false,launched=false,deployed=false,filter=false;

  @override
  void initState() {
    super.initState();
    _dropDownCountries();
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
            SnackBar snackBar = SnackBar(
              content: Text(state.error,style: TextStyle(color: ThemeColors.snackBarTextColor),),
              backgroundColor: ThemeColors.snackBarBackgroundColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              body: const Center(
                child: CircularProgressIndicator(),
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
            );
          }

          return const Center(
            child: Text("An error occurred!"),
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
                Text(
                  satellites.name.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),
                ),
                Flexible(
                  flex: 1,
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
                  child: Text('Launched  -  ${parseDateString(satellites.launched!)}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 15,color: ThemeColors.textPrimary)),
            ),
            satellites.deployed.toString().isEmpty || satellites.deployed.toString() == 'null' ?
            Container()
                : (satellites.launched.toString() != 'null') && parseDateString(satellites.launched!) == parseDateString(satellites.deployed!)
                ? Container()
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
        context.read<SatelliteCubit>().filterSearchData(_searchController.text,dropdownvalueCountries,dropdownvalueStatus,false,false,false);
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
      bottom: AppBar(
        elevation: 0,
        backgroundColor: ThemeColors.backgroundCardColor,
        title: Card(
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
                      context.read<SatelliteCubit>().filterSearchData(val,dropdownvalueCountries,dropdownvalueStatus,false,false,false);
                    },
                    keyboardType: TextInputType.text,
                    cursorColor: ThemeColors.primaryColor,
                    style: TextStyle(color: ThemeColors.textPrimary),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: ThemeColors.searchBarColor),
                        hintText: 'Search satellites',
                        prefixIcon: Icon(Icons.search,color: ThemeColors.primaryColor),
                        suffixIcon: _clear(context)
                    ),
                  ),
                ),
                Text('|',style: TextStyle(fontSize: 30,color: ThemeColors.searchBarColor),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: IconButton(
                    icon: Icon(Icons.filter_list_rounded,color: filter ? ThemeColors.primaryColor : ThemeColors.searchBarColor),
                    onPressed: (){
                      showModalBottomSheet(
                          isDismissible: false,
                          backgroundColor: ThemeColors.backgroundColor,
                          context: context,
                          builder: (_context) => StatefulBuilder(
                              builder: (BuildContext _context, StateSetter _setState){
                                return buildFilter(context,_setState);
                              }),
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)
                              )
                          )
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget divider(double textWidth){
    return Container(
      width: (MediaQuery.of(context).size.width - textWidth - 40)*0.5,
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

  Widget buildFilter(BuildContext context, StateSetter _setState){
    return BlocProvider.value(
      value: BlocProvider.of<SatelliteCubit>(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 5, 25, 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                  color: ThemeColors.dividerColor,
                  borderRadius: BorderRadius.circular(20)
              ),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                width: MediaQuery.of(context).size.width*0.5,
                                child: Text(items,overflow: TextOverflow.ellipsis,)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          _setState(() {
                            dropdownvalueCountries = newValue!;
                          });
                        }
                    ),
                  ],
                ),
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
                                width: MediaQuery.of(context).size.width*0.2,
                                child: Text(items,overflow: TextOverflow.ellipsis,)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          _setState(() {
                            dropdownvalueStatus = newValue!;
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
                Row(
                  children: [
                    Text('Decayed',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible),
                    Checkbox(
                      value: decayed,
                      onChanged: (bool? value){
                        _setState(() {
                          decayed = value!;
                        });
                      },
                      checkColor: ThemeColors.backgroundColor,
                      activeColor: ThemeColors.primaryColor,
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Launched',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible),
                    Checkbox(
                      value: launched,
                      onChanged: (bool? value){
                        _setState(() {
                          launched = value!;
                        });
                      },
                      checkColor: ThemeColors.backgroundColor,
                      activeColor: ThemeColors.primaryColor,
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Deployed',style: TextStyle(color: ThemeColors.textPrimary),overflow: TextOverflow.visible,),
                    Checkbox(
                      value: deployed,
                      onChanged: (bool? value){
                        _setState(() {
                          deployed = value!;
                        });
                      },
                      checkColor: ThemeColors.backgroundColor,
                      activeColor: ThemeColors.primaryColor,
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: (){
                  checkFilter();
                  Navigator.pop(context);
                  context.read<SatelliteCubit>().filterSearchData(_searchController.text,dropdownvalueCountries,dropdownvalueStatus,decayed,launched,deployed);
                },
                style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primaryColor,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text('FILTER',style: TextStyle(color: ThemeColors.backgroundColor,fontSize: 18,letterSpacing: 5),),
              ),
            )
          ],
        ),
      ),
    );
  }

  void checkFilter(){
    if(decayed == false && deployed == false && launched == false && dropdownvalueCountries == 'ALL' && dropdownvalueStatus == 'ALL'){
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

}
