abstract class SatelliteInfoState{}

class SatelliteLoadingState extends SatelliteInfoState{}

class SatelliteLoadedState extends SatelliteInfoState{
  final List<String> tle;
  SatelliteLoadedState(this.tle);
}

class SatelliteErrorState extends SatelliteInfoState{
  final String error;
  SatelliteErrorState(this.error);
}
