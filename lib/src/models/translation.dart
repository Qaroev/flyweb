class Translation {
  String? id;
  String? lang;
  String? lang_key;
  String? lang_value;
  String? createdAt;
  String? updatedAt;

  Translation(
      {this.id,
        this.lang,
        this.lang_key,
        this.lang_value,
        this.createdAt,
        this.updatedAt });

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lang = json['lang'];
    lang_key = json['lang_key'];
    lang_value = json['lang_value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['lang'] = this.lang;
    data['lang_key'] = this.lang_key;
    data['lang_value'] = this.lang_value;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }


}