import 'package:flutter/material.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class SocialItemMenu extends StatefulWidget {
  String? icon_url;
  IconData icon;
  String text;
  void Function()? onTap;

  SocialItemMenu(
      {Key? key,
      this.icon_url = "",
      this.icon = Icons.edit,
      this.text = "",
      required this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SocialItemMenu();
  }
}

class _SocialItemMenu extends State<SocialItemMenu> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return ListTile(
      title: Container(
          child: Text(
            widget.text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15.0,color:  themeProvider.isLightTheme ? Colors.black : Colors.white,),
          )),
      leading:
          _renderIcon(widget.icon_url, widget.icon, themeProvider.isLightTheme),
      onTap: widget.onTap,
    );
  }

  Widget _renderIcon(icon_url, icon, isLightTheme) {
    return Container(
        height: 22,
        width: 22,
        child: icon_url != ""
            ? Image.network(
                icon_url,
                width: 20,
                height: 20,
                 color: isLightTheme ? Colors.grey : Colors.white,
              )
            : Icon(icon,
          color: isLightTheme ? Colors.grey : Colors.white,));
  }
}
