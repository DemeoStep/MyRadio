import 'dart:typed_data';

class Station {
  String _name = '';
  String _url = '';
  String _logo = '';
  Uint8List _img = Uint8List.fromList([]);

  String get name => _name;
  void setName(String name) {
    _name = name;
  }

  String get url => _url;
  void setUrl(String url) {
    _url = url;
  }

  Uint8List get img => _img;

  void setImg(String source) {
    List<int> list = [];
    for(var item in source.split(', ')) {
      list.add(int.parse(item));
    }
    _img = Uint8List.fromList(list);
  }

  String get logo => _logo;
  void setLogo(String filename) {}

  Station(
      {required String name,
        required String url,
        required String logo,
      required img}) {
    _name = name;
    _url = url;
    logo != '' ? _logo = logo : _logo = '';
    setImg(img);
  }

  Station.newStation() : this(name: '', url: '', logo: '', img: '');
}