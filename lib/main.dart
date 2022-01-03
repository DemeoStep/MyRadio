import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:radio_player/radio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/player.dart';
import 'model/station.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(false, null, Station.newStation()));
}

class MyApp extends StatelessWidget {
  final Player _radioPlayer = Player(false, [], Station.newStation());
  bool _isPlaying = false;
  List<String>? _metadata;

  Station _station;

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

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          onTap: (value) {},
        ),
        appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade900,
            centerTitle: true,
            title: StreamBuilder<Station>(
              stream: _radioPlayer.onStationChange,
              builder: (context, snapshot) {
                var station =
                    snapshot.data ?? Station(name: '', url: '');
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
                              return OutlinedButton(
                                onPressed: () {
                                  _station = Station(
                                    name: snap.data?.docs[index].get('name'),
                                    url: snap.data?.docs[index].get('url'),
                                      logo: snap.data?.docs[index].get('icon')
                                  );
                                  _radioPlayer.stationChange(_station);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: Colors.amber,
                                  child: Image.network(
                                      snap.data?.docs[index].get('icon')),
                                ),
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
