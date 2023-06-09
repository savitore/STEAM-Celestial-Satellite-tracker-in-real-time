import 'package:steam_celestial_satellite_tracker_in_real_time/models/tle_model.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/widgets/date.dart';

class SatelliteModel {
  String? satId;
  int? noradCatId;
  int? noradFollowId;
  String? name;
  String? names;
  String? image;
  String? status;
  String? decayed;
  String? launched;
  String? deployed;
  String? website;
  String? operator;
  String? countries;
  List<dynamic>? telemetries;
  String? updated;
  String? citation;
  bool? isFrequencyViolator;
  List<dynamic>? associatedSatellites;

  SatelliteModel(
      {required this.satId,
        required this.noradCatId,
        required this.noradFollowId,
        required this.name,
        required this.names,
        required this.image,
        required this.status,
        required this.decayed,
        required this.launched,
        required this.deployed,
        required this.website,
        required this.operator,
        required this.countries,
        required this.telemetries,
        required this.updated,
        required this.citation,
        required this.isFrequencyViolator,
        required this.associatedSatellites});


  SatelliteModel.fromJson(Map<String, dynamic> json) {
    satId = json['sat_id'];
    noradCatId = json['norad_cat_id'];
    noradFollowId = json['norad_follow_id'];
    name = json['name'];
    names = json['names'];
    image = json['image'];
    status = json['status'];
    decayed = json['decayed'];
    launched = json['launched'];
    deployed = json['deployed'];
    website = json['website'];
    operator = json['operator'];
    countries = json['countries'];
    telemetries = json['telemetries'].cast<String>();
    updated = json['updated'];
    citation = json['citation'];
    isFrequencyViolator = json['is_frequency_violator'];
    associatedSatellites = json['associated_satellites'].cast<String>();
  }

  /// Gets whether the [website] is a valid URL.
  bool websiteValid() {
    final regex = RegExp(
        'https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)');
    return regex.hasMatch(website!);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sat_id'] = this.satId;
    data['norad_cat_id'] = this.noradCatId;
    data['norad_follow_id'] = this.noradFollowId;
    data['name'] = this.name;
    data['names'] = this.names;
    data['image'] = this.image;
    data['status'] = this.status;
    data['decayed'] = this.decayed;
    data['launched'] = this.launched;
    data['deployed'] = this.deployed;
    data['website'] = this.website;
    data['operator'] = this.operator;
    data['countries'] = this.countries;
    data['telemetries'] = this.telemetries;
    data['updated'] = this.updated;
    data['citation'] = this.citation;
    data['is_frequency_violator'] = this.isFrequencyViolator;
    data['associated_satellites'] = this.associatedSatellites;
    return data;
  }


  /// Gets the balloon content from the current satellite.
  String balloonContent() => '''
    <b><font size="+2">$name <font color="#5D5D5D">(${status.toString().toUpperCase()})</font></font></b>
    <br/><br/>
    ${image.toString().isNotEmpty ? '<img height="200" src="https://db-satnogs.freetls.fastly.net/media/$image"><br/><br/>' : ''}
    <b>NORAD ID:</b> $noradCatId
    <br/>
    <b>Alternames:</b> $names
    <br/>
    <b>Countries:</b> ${countries.toString().replaceAll('\r\n', ' | ')}
    <br/>
    <b>Operator:</b> $operator
    <br/>
    <b>Launched:</b> ${launched.toString() != 'null' ? parseDateHourString(launched.toString()) : 'Never'}
    <br/>
    <b>Deployed:</b> ${deployed.toString() != 'null' ? parseDateHourString(deployed.toString()) : 'Never'}
    <br/>
    <b>Decayed:</b> ${decayed.toString() != 'null' ? parseDateHourString(decayed.toString()) : 'Never'}
  ''';


  /// Gets the orbit coordinates from the current satellite.
  /// Returns a [List] of coordinates with [lat], [lng] and [alt].
  List<Map<String, double>> getOrbitCoordinates({double step = 3, required TLEModel tle}) {

    List<Map<String, double>> coords = [];

    double displacement = 3.3 - step / 361;
    double spot = 0;

    while (spot < 361) {
      displacement += step / 361;
      final tleCoords = tle.read(displacement: displacement / 24.0);
      coords.add({
        'lat': tleCoords['lat']!,
        'lng': tleCoords['lng']!,
        'altitude': tleCoords['alt']!
      });
      spot++;
    }

    return coords;
  }

}
