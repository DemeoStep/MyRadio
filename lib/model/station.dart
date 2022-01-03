class Station {
  String _name = '';
  String _url = '';
  String _logo = '';

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
      {required String name,
        required String url,
        String logo = ''}) {
    _name = name;
    _url = url;
    logo != '' ? _logo = logo : _logo = '';
  }

  Station.newStation() : this(name: '', url: '');
}