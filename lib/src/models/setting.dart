class Setting {
  String? type = "";
  String? value = "";

  Setting({this.type, this.value});

  Setting.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }

  static String getValue(List<Setting> list, String key) {
    Iterable<Setting> obj = list.where((s) => s.type == key);
    if (obj.isEmpty) {
      if(key == "google_font"){
        return "Roboto";
      }
      return "";
    } else {
      Setting result = obj.first;
      return result.value!;
    }
  }
}
