import '../models/satellite_model.dart';

abstract class SatelliteState{}

class SatelliteLoadingState extends SatelliteState{}

class SatelliteLoadedState extends SatelliteState{
  final List<SatelliteModel> satellites;
  SatelliteLoadedState(this.satellites);
}

class FilteredSatelliteState extends SatelliteState{
  final List<SatelliteModel> searchedSatellites;
  FilteredSatelliteState(this.searchedSatellites);
}

class SatelliteErrorState extends SatelliteState{
  final String error;
  SatelliteErrorState(this.error);
}
