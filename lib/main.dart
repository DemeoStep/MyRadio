import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:radio_player/radio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'model/station.dart';
import 'model/stations_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(false, null, Station.newStation()));
}

class MyApp extends StatelessWidget {
  final RadioPlayer _radioPlayer = RadioPlayer();
  bool _isPlaying = false;
  List<String>? _metadata;

  StationsList list = StationsList.newList();
  Station _station;
  int _stationIndex = 0;

  BehaviorSubject<bool> onIsPlayingChange;
  BehaviorSubject<List<String>?> onMetaChange;
  BehaviorSubject<Station> onStationChange;

  MyApp(this._isPlaying, this._metadata, this._station, {Key? key})
      : onIsPlayingChange = BehaviorSubject<bool>.seeded(_isPlaying),
        onMetaChange = BehaviorSubject<List<String>?>.seeded(_metadata),
        onStationChange = BehaviorSubject<Station>.seeded(_station),
        super(key: key);

  Future isPlayingChange(bool isPlaying) async {
    onIsPlayingChange.add(isPlaying);
    _isPlaying = isPlaying;
  }

  Future metaChange(List<String>? meta) async {
    onMetaChange.add(meta);
    _metadata = meta;
  }

  Future stationChange(int index) async {
    if (index < 0) index = list.count - 1;
    if (index > list.count - 1) index = 0;

    _station = await list.getStation(index);
    _stationIndex = _station.index;
    onStationChange.add(_station);
    initRadioPlayer();
  }

  void initRadioPlayer() async {
    _radioPlayer.setMediaItem(_station.name, _station.url, _station.logo);

    _radioPlayer.stateStream.listen((value) {
      isPlayingChange(value);
    });

    _radioPlayer.metadataStream.listen((value) {
      metaChange(value);
    });
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  Future<void> loadList() async {
    list.loadList().then((result) async {
      await stationChange(_stationIndex);
      initRadioPlayer();
      metaChange(['', '', '']);
    });
  }

  void _controls(int index) {
    index == 1 && _isPlaying ? _radioPlayer.pause() : _radioPlayer.play();
    if (index == 2) stationChange(_stationIndex + 1);
    if (index == 0) stationChange(_stationIndex - 1);
  }

  @override
  Widget build(BuildContext context) {
    loadList();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blueGrey.shade900,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.skip_previous,
                size: 50,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<bool>(
                  stream: onIsPlayingChange,
                  builder: (context, snapshot) {
                    var isPlaying = snapshot.data ?? false;
                    return Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 50,
                    );
                  }),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.skip_next,
                size: 50,
              ),
              label: "",
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          onTap: _controls,
        ),
        appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade900,
            centerTitle: true,
            title: StreamBuilder<Station>(
              stream: onStationChange,
              builder: (context, snapshot) {
                var station =
                    snapshot.data ?? Station(index: 0, name: '', url: '');
                return Text(station.name);
              },
            )),
        body: Center(
          child: FutureBuilder(
            future: initFirebase(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.done) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('rock')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
                      if(snap.hasData) {
                        return GridView.builder(
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                            ),
                            itemCount: snap.data?.docs.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(5),
                                color: Colors.amber,
                                child: Image.network(
                                    snap.data?.docs[index].get('icon')),
                              );
                            },
                        );
                      }
                      return const CircularProgressIndicator();
                    });
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
