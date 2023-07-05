abstract class SatelliteInfoState{}

class SatelliteLoadingState extends SatelliteInfoState{}

class SatelliteLoadedState extends SatelliteInfoState{
  final List<String> tle;
  final String TLE;
  SatelliteLoadedState({required this.tle, required this.TLE});
}

class SatelliteErrorState extends SatelliteInfoState{
  final String error;
  SatelliteErrorState(this.error);
}
