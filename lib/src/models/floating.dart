class Floating {
  String? id = "";
  String? title = "";
  String? type = "";
  String? icon = "";
  String? url = "";
  String? status = "";
  String? background_color = "";
  String? icon_color = "";
  String? background_color_dark = "";
  String? icon_color_dark = "";
  String? date = "";
  String? iconUrl = "";
  List<TranslationFloating>? translationFloating = [];
  Map<String, Map<String, String>> translation = {};

  Floating(
      {this.id,
      this.title,
      this.type,
      this.icon,
      this.url,
      this.status,
      this.background_color,
      this.icon_color,
      this.background_color_dark,
      this.icon_color_dark,
      this.date,
      this.iconUrl,
      this.translationFloating});

  Floating.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    icon = json['icon'];
    url = json['url'];
    status = json['status'];
    background_color = json['background_color'];
    icon_color = json['icon_color'];
    background_color_dark = json['background_color_dark'];
    icon_color_dark = json['icon_color_dark'];
    date = json['date'];
    iconUrl = json['icon_url'];

    if (json['translation'] != null) {
      translationFloating = <TranslationFloating>[];
      json['translation'].forEach((v) {
        translationFloating!.add(new TranslationFloating.fromJson(v));
      });

      Map<String, Map<String, String>> translate = {};

      translationFloating?.forEach((element) {
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
    data['type'] = this.type;
    data['icon'] = this.icon;
    data['url'] = this.url;
    data['status'] = this.status;
    data['background_color'] = this.background_color;
    data['icon_color'] = this.icon_color;
    data['background_color_dark'] = this.background_color_dark;
    data['icon_color_dark'] = this.icon_color_dark;
    data['date'] = this.date;
    data['icon_url'] = this.iconUrl;

    if (this.translationFloating != null) {
      data['translation'] =
          this.translationFloating!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class TranslationFloating {
  TranslationTab({
    String? title,
    String? url,
    String? lang,
  }) {
    _title = title;
    _url = url;
    _lang = lang;
  }

  TranslationFloating.fromJson(dynamic json) {
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
