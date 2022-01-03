import 'package:my_radio/model/station.dart';
import 'package:rxdart/rxdart.dart';
import 'package:radio_player/radio_player.dart';

class Player{
  final RadioPlayer _player = RadioPlayer();
  bool isPlaying = false;

  List<String>? metadata;
  late Station station;

  BehaviorSubject<bool> onIsPlayingChange;
  BehaviorSubject<List<String>?> onMetaChange;
  BehaviorSubject<Station> onStationChange;

  Player(this.isPlaying, this.metadata, this.station)
      : onIsPlayingChange = BehaviorSubject<bool>.seeded(isPlaying),
        onMetaChange = BehaviorSubject<List<String>?>.seeded(metadata),
        onStationChange = BehaviorSubject<Station>.seeded(station);

  Future isPlayingChange(bool isPlaying) async {
    onIsPlayingChange.add(isPlaying);
    this.isPlaying = isPlaying;
  }

  Future metaChange(List<String>? meta) async {
    onMetaChange.add(meta);
    metadata = meta;
  }

  Future stationChange(Station station) async {
    onStationChange.add(station);
    this.station = station;
    initRadioPlayer();
    _player.play();
  }

  void initRadioPlayer() async {
    _player.setMediaItem(station.name, station.url);

    _player.stateStream.listen((value) {
      isPlayingChange(value);
    });

    _player.metadataStream.listen((value) {
      metaChange(value);
    });
  }

}