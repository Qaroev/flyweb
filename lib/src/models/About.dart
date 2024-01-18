class About {
  String? id = "";
  String? title = "";
  String? url = "";
  String? icon_url = "";
  //String? icon_base64 = "";
  List<TranslationAbout>? translationAbout = [];
  Map<String, Map<String, String>> translation = {};

  About(
      {this.id,
        this.title,
        this.url,
        this.icon_url,
        //this.icon_base64,
        this.translationAbout});

  About.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    icon_url = json['icon_url'];
    //icon_base64 = json['icon_base64'];

    if (json['translation'] != null) {
      translationAbout = <TranslationAbout>[];
      json['translation'].forEach((v) {
        translationAbout!.add(new TranslationAbout.fromJson(v));
      });

      Map<String, Map<String, String>> translate = {};

      translationAbout?.forEach((element) {
        Map<String, String> tran = {};
        //tran['title'] = element.title!;
        tran['description'] = element.description!;
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

    if (this.translationAbout != null) {
      data['translation'] = this.translationAbout!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class TranslationAbout {
  TranslationAbout({
    //String? title,
    String? description,
    String? lang,
  }) {
    //_title = title;
    _description = description;
    _lang = lang;
  }

  TranslationAbout.fromJson(dynamic json) {
    //_title = json['title'];
    _description = json['description'];
    _lang = json['lang'];
  }

  //String? _title;
  String? _description;
  String? _lang;

  //String? get title => _title;

  String? get description => _description;

  String? get lang => _lang;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    //map['title'] = _title;
    map['description'] = _description;
    map['lang'] = _lang;
    return map;
  }
}
