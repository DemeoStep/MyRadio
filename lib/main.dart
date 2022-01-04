import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_radio/view/genre.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/player.dart';
import 'model/station.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Player _radioPlayer = Player(false, [], Station.newStation());

  MyApp({Key? key})
      : super(key: key);

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: initFirebase(),
      builder: (BuildContext context, futureSnapshot) {
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
                      stream: _radioPlayer.onIsPlayingChange,
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
                leading: StreamBuilder<Station>(
                  stream: _radioPlayer.onStationChange,
                  builder: (context, snapshot) {
                    return Image.memory(snapshot.data!.img);
                  },
                ),
                title: StreamBuilder<Station>(
                  stream: _radioPlayer.onStationChange,
                  builder: (context, snapshot) {
                    var station =
                        snapshot.data ?? Station(name: '', url: '', logo: '',
                            img: '');
                    return Text(station.name);
                  },
                )),
            body: Center(
              child: FutureBuilder(
                future: initFirebase(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState == ConnectionState.done) {
                    return Genre(radioPlayer: _radioPlayer, genre: 'rock',);
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
