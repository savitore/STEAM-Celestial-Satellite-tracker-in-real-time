import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_info_cubit.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/cubit/satellite_info_state.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/models/satellite_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';
import '../widgets/date.dart';

class SatelliteInfo extends StatefulWidget {
  final SatelliteModel satelliteModel;
  const SatelliteInfo(this.satelliteModel, {super.key});

  @override
  State<SatelliteInfo> createState() => _SatelliteInfoState();
}

class _SatelliteInfoState extends State<SatelliteInfo> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => SatelliteInfoCubit(widget.satelliteModel.noradCatId.toString() !='null' ? widget.satelliteModel.noradCatId! : 0),
        child: Scaffold(
          backgroundColor: ThemeColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: ThemeColors.primaryColor,
            foregroundColor: ThemeColors.backgroundColor,
            elevation: 3,
            leading: IconButton(icon : const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context); },),
            title: Text(widget.satelliteModel.name.toString(),overflow: TextOverflow.ellipsis,),
            actions: const [
              Icon(Icons.satellite_alt),
              SizedBox(width: 15),
            ],
          ),
          body: SafeArea(
            child: BlocConsumer<SatelliteInfoCubit, SatelliteInfoState>(
              listener: (context,state){
                if(state is SatelliteErrorState){
                  SnackBar snackBar = SnackBar(
                    content: Text(state.error,style: TextStyle(color: ThemeColors.snackBarTextColor),),
                    backgroundColor: ThemeColors.snackBarBackgroundColor,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              builder: (context,state){
                if(state is SatelliteLoadingState){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else if(state is SatelliteLoadedState){
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSatelliteStatus(),
                          const SizedBox(height: 20),
                          _buildSatelliteImage(),
                          _buildTitle('Satellite ID', widget.satelliteModel.satId.toString()),
                          _buildTitle('NORAD ID', widget.satelliteModel.noradCatId.toString()),
                          _buildTitle('NORAD Follow ID', widget.satelliteModel.noradFollowId.toString()),
                          _buildTitle('Alternate names', widget.satelliteModel.names.toString()),
                          _buildDate('Launch date', widget.satelliteModel.launched.toString()),
                          _buildDate('Deploy date', widget.satelliteModel.deployed.toString()),
                          _buildDate('Decay date', widget.satelliteModel.decayed.toString()),
                          _buildCountry(widget.satelliteModel.countries.toString()),
                          _buildTitle('Operator', widget.satelliteModel.operator.toString()),
                          _buildWebsite('Website', widget.satelliteModel.website.toString()),
                          _buildTLE(state.tle),
                          _buildDate('Updated', widget.satelliteModel.updated.toString())
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

  Widget _buildTitle(String title, String info){
    if(info.isEmpty || info == 'null' ){
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: TextStyle(fontSize: 18,color: ThemeColors.textSecondary),overflow: TextOverflow.ellipsis,),
        const SizedBox(height: 10),
        Text(info,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,),
        const SizedBox(height: 30)
      ],
    );
  }

  Widget _buildWebsite(String title, String web){
    Color? color = ThemeColors.textPrimary;
    if(widget.satelliteModel.websiteValid()){
        color = ThemeColors.websiteColor;
    }
    if(web.isEmpty || web == 'null' ){
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: TextStyle(fontSize: 18,color: ThemeColors.textSecondary)),
        const SizedBox(height: 10),
        InkWell(
            onTap: (){
              if(widget.satelliteModel.websiteValid()){
                _openLink();
              }
            },
            child: Text(web,style: TextStyle(color: color,fontSize: 20),overflow: TextOverflow.visible,)
        ),
        const SizedBox(height: 30)
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
        Text(title,style: TextStyle(fontSize: 18,color: ThemeColors.textSecondary)),
        const SizedBox(height: 10),
        Text(date,style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,),
        const SizedBox(height: 30)
      ],
    );
  }

  Widget _buildSatelliteImage() {
    final image = widget.satelliteModel.image;

    if (image.toString().isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://db-satnogs.freetls.fastly.net/media/$image',
                // width: 180,
              ),
            ),
      ),
    );
  }

  Widget _buildTLE(List<String> tle){
    int numLines = tle.length;
    if(numLines == 4){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest Two-Line Element (TLE)',style: TextStyle(fontSize: 18,color: ThemeColors.textSecondary)),
          const SizedBox(height: 10),
          Text('${tle[0]}\n${tle[1]}\n${tle[2]}',style: TextStyle(color: ThemeColors.textPrimary,fontSize: 20),overflow: TextOverflow.visible,),
          const SizedBox(height: 30)
        ],
      );
    }
    return Container();
  }

  Widget _buildCountry(String countries){
    String title = 'Country of Origin';
    if(countries.contains(',')){
      title = 'Countries of Origin';
    }
    return _buildTitle(title, countries.toString());
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
                fontWeight: FontWeight.w600,
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
        Container(
          width: MediaQuery.of(context).size.width,
          height: 1,
          color: ThemeColors.dividerColor,
          margin: const EdgeInsets.only(top: 16),
        ),
      ],
    );
  }

  /// Gets the status data from the current [satellite].
  Map<String, dynamic> _getStatusData() {
    switch (widget.satelliteModel.status) {
      case 'alive':
        return {
          'icon': Icons.check_circle_rounded,
          'title': 'Operational',
          'description': 'Satellite is in orbit and operational',
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
    final Uri websiteLaunchUri = Uri.parse(widget.satelliteModel.website.toString());

    if (await canLaunchUrl(websiteLaunchUri)) {
      await launchUrl(websiteLaunchUri, mode: LaunchMode.platformDefault);
    }
  }

}
