import 'station.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

class StationsList {
  int _count;
  List<Station> _list;

  BehaviorSubject<List<Station>> onListUpdate;
  int get count => _count;

  StationsList(this._count, this._list)
      : onListUpdate = BehaviorSubject<List<Station>>.seeded(_list);

  StationsList.newList() : this(0, []);

  String stationName(index) {
    return _list[index].name;
  }

  String stationLogo(index) {
    return _list[index].logo;
  }

  Future<Station> getStation(int index) async {
    return index <= _count ? _list[index] : _list[_count];
  }

  Future<List> getJson() async {
    var str = await rootBundle.loadString('lib/assets/list.json');
    return json.decode(str);
  }

  Future<void> loadList() async {
    var list = await getJson();

    for (var item in list) {
      Station station = Station(
          index: count,
          name: item["name"],
          url: item["url"],
          logo: item["logo"]);
      _list.add(station);
      _count++;
    }
  }
}