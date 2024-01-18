class Application {
  Application({
    String? title,
    String? sub_title,
    String? lang,
    String? url,
  }) {
    _title = title;
    _sub_title = sub_title;
    _lang = lang;
  }

  Application.fromJson(dynamic json) {
    _title = json['title'];
    _sub_title = json['sub_title'];
    _lang = json['lang'];
    _url = json['url'];
  }

  String? _title;
  String? _sub_title;
  String? _lang;
  String? _url;

  String? get title => _title;

  String? get sub_title => _sub_title;

  String? get lang => _lang;

  String? get url => _url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = _title;
    map['sub_title'] = _sub_title;
    map['lang'] = _lang;
    map['url'] = _url;
    return map;
  }
}
