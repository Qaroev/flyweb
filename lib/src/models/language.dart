
import 'package:flyweb/src/models/translation.dart';

class Language {
  String? id;
  String? title;
  String? title_native;
  String? code;
  String? app_lang_code;
  String? rtl;
  String? status;
  List<Translation>? translations = [];
  String? createdAt;
  String? updatedAt;

  Language(
      {this.id,
      this.title,
      this.title_native,
      this.code,
      this.app_lang_code,
      this.rtl,
      this.status,
      this.translations,
      this.createdAt,
      this.updatedAt});

  Language.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    title_native = json['title_native'];
    code = json['code'];
    app_lang_code = json['app_lang_code'];
    rtl = json['rtl'];
    status = json['status'];

    if (json['translations'] != null) {
      translations = <Translation>[];
      json['translations'].forEach((v) {
        translations!.add(new Translation.fromJson(v));
      });
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['title_native'] = this.title_native;
    data['code'] = this.code;
    data['app_lang_code'] = this.app_lang_code;
    data['rtl'] = this.rtl;
    data['status'] = this.status;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;

    if (this.translations != null) {
      data['translations'] = this.translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
