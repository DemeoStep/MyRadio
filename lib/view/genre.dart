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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.8,
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20
              ),
              itemCount: snap.data?.docs.length,
              itemBuilder: (context, index) {
                var station = Station(
                    name: snap.data?.docs[index].get('name'),
                    url: snap.data?.docs[index].get('url'),
                    logo: snap.data?.docs[index].get('icon'),
                    img: snap.data?.docs[index].get('logo')
                    //img: Uint8List.fromList([])
                );
                return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red,
                            offset: Offset(2,2),
                            blurRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.yellow,
                            offset: Offset(-2,-2),
                            blurRadius: 5,
                          )
                        ]
                    ),
                    child: OutlinedButton(
                      clipBehavior: Clip.antiAlias,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        radioPlayer.stationChange(station);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(station.logo),
                          Text(station.name,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        });
  }
}