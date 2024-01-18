class Menu {
  String? id = "";
  String? label = "";
  String? type = "";
  String? icon = "";
  String? url = "";
  String? status = "";
  String? date = "";
  String? iconUrl = "";
  List<TranslationMenu>? translationMenu = [];
  Map<String, Map<String, String>> translation = {};

  Menu(
      {this.id,
      this.label,
      this.type,
      this.icon,
      this.url,
      this.status,
      this.date,
      this.iconUrl});

  Menu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    type = json['type'];
    icon = json['icon'];
    url = json['url'];
    status = json['status'];
    date = json['date'];
    iconUrl = json['icon_url'];

    if (json['translation'] != null) {
      translationMenu = <TranslationMenu>[];
      json['translation'].forEach((v) {
        translationMenu!.add(new TranslationMenu.fromJson(v));
      });

      Map<String, Map<String, String>> translate = {};

      translationMenu?.forEach((element) {
        Map<String, String> tran = {};

        tran['title'] = element.title!;
        tran['url'] = element.url!;
        tran["lang"] = element.lang!;

        translate[element.lang.toString()] = tran;
      });
      translation = translate;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['label'] = this.label;
    data['type'] = this.type;
    data['icon'] = this.icon;
    data['url'] = this.url;
    data['status'] = this.status;
    data['date'] = this.date;
    data['icon_url'] = this.iconUrl;

    if (this.translationMenu != null) {
      data['translation'] =
          this.translationMenu!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class TranslationMenu {
  TranslationTab({
    String? title,
    String? url,
    String? lang,
  }) {
    _title = title;
    _url = url;
    _lang = lang;
  }

  TranslationMenu.fromJson(dynamic json) {
    _title = json['title'];
    _url = json['url'];
    _lang = json['lang'];
  }

  String? _title;
  String? _url;
  String? _lang;

  String? get title => _title;

  String? get url => _url;

  String? get lang => _lang;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = _title;
    map['url'] = _url;
    map['lang'] = _lang;
    return map;
  }
}
