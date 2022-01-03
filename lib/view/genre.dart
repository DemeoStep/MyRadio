import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_radio/controller/player.dart';
import 'package:my_radio/model/station.dart';

class Genre extends StatelessWidget {
  Genre({Key? key, required this.radioPlayer, required this.genre})
      : super(key: key);

  final Player radioPlayer;
  String genre = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(genre)
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
                var station = Station(
                    name: snap.data?.docs[index].get('name'),
                    url: snap.data?.docs[index].get('url'),
                    logo: snap.data?.docs[index].get('icon'),
                    // img: snap.data?.docs[index].get('logo')
                    img: Uint8List.fromList([])
                );
                return OutlinedButton(
                  onPressed: () {
                    radioPlayer.stationChange(station);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    color: Colors.amber,
                    // child: Image.memory(
                    //     station.img),
                    child: Image.network(station.logo),
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        });
  }
}