class Tab {
  String? id = "";
  String? title = "";
  String? url = "";
  String? icon_url = "";
  //String? icon_base64 = "";
  List<TranslationTab>? translationTab = [];
  Map<String, Map<String, String>> translation = {};

  Tab(
      {this.id,
      this.title,
      this.url,
      this.icon_url,
      //this.icon_base64,
      this.translationTab});

  Tab.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    icon_url = json['icon_url'];
    //icon_base64 = json['icon_base64'];

    if (json['translation'] != null) {
      translationTab = <TranslationTab>[];
      json['translation'].forEach((v) {
        translationTab!.add(new TranslationTab.fromJson(v));
      });

      Map<String, Map<String, String>> translate = {};

      translationTab?.forEach((element) {
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
    data['title'] = this.title;
    data['url'] = this.url;
    data['icon_url'] = this.icon_url;
    //data['icon_base64'] = this.icon_base64;

    if (this.translationTab != null) {
      data['translation'] = this.translationTab!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TranslationTab {
  TranslationTab({
    String? title,
    String? url,
    String? lang,
  }) {
    _title = title;
    _url = url;
    _lang = lang;
  }

  TranslationTab.fromJson(dynamic json) {
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
