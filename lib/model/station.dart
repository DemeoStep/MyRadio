class Station {
  String _name = '';
  String _url = '';
  String _logo = 'lib/assets/cover.jpg';
  int _index = 0;

  int get index => _index;

  String get name => _name;
  void setName(String name) {
    _name = name;
  }

  String get url => _url;
  void setUrl(String url) {
    _url = url;
  }

  String get logo => _logo;
  void setLogo(String filename) {}

  Station(
      {required int index,
        required String name,
        required String url,
        String logo = ''}) {
    _index = index;
    _name = name;
    _url = url;
    logo != '' ? _logo = logo : _logo = 'lib/assets/cover.jpg';
  }

  Station.newStation() : this(index: 0, name: '', url: '');
}