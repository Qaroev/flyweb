/// id : "1"
/// title : "Home"
/// url : "http://positifmobile.com/positifMobile/flyweb/demo"
/// icon : "tab_item_1.png"
/// status : "1"
/// created_at : "2022-03-19 23:18:58"
/// updated_at : "2022-03-19 23:18:58"
/// icon_url : "http://localhost//FlyWeb/images/tab/tab_item_1.png"
/// translation : {"en ":{"title":"zsdsdsd"}}

class TabTest {
  TabTest({
      String? id, 
      String? title, 
      String? url, 
      String? icon, 
      String? status, 
      String? createdAt, 
      String? updatedAt, 
      String? iconUrl, 
      Translation? translation,}){
    _id = id;
    _title = title;
    _url = url;
    _icon = icon;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _iconUrl = iconUrl;
    _translation = translation;
}

  TabTest.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _url = json['url'];
    _icon = json['icon'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _iconUrl = json['icon_url'];
    _translation = json['translation'] != null ? Translation.fromJson(json['translation']) : null;
  }
  String? _id;
  String? _title;
  String? _url;
  String? _icon;
  String? _status;
  String? _createdAt;
  String? _updatedAt;
  String? _iconUrl;
  Translation? _translation;

  String? get id => _id;
  String? get title => _title;
  String? get url => _url;
  String? get icon => _icon;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get iconUrl => _iconUrl;
  Translation? get translation => _translation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['url'] = _url;
    map['icon'] = _icon;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['icon_url'] = _iconUrl;
    if (_translation != null) {
      map['translation'] = _translation?.toJson();
    }
    return map;
  }

}

/// en  : {"title":"zsdsdsd"}

class Translation {
  Translation({
      En? en,}){
    _en = en;
}

  Translation.fromJson(dynamic json) {
    _en = json['en '] != null ? En.fromJson(json['en ']) : null;
  }
  En? _en;

  En? get en => _en;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_en != null) {
      map['en '] = _en?.toJson();
    }
    return map;
  }

}

/// title : "zsdsdsd"

class En {
  En({
      String? title,}){
    _title = title;
}

  En.fromJson(dynamic json) {
    _title = json['title'];
  }
  String? _title;

  String? get title => _title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = _title;
    return map;
  }

}