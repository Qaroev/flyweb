import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatefulWidget {
  String icon_url;
  IconData icon;
  String text;
  String type;
  void Function()? onTap;

  DrawerMenu(
      {Key? key,
      this.icon_url = "",
      this.icon = Icons.edit,
      this.text = "",
      this.type = "url",
      required this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerMenu();
}

class _DrawerMenu extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return widget.type == "divider"
        ? Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Divider(height: 1, color: Colors.grey[400]),
          )
        : widget.type == "title_block"
            ? _renderTitleBlock(widget.text, themeProvider.isLightTheme)
            : ListTile(
                title: _renderTitle(
                    widget.text, widget.type, themeProvider.isLightTheme),
                leading: _renderIcon(widget.icon_url, widget.icon,
                    themeProvider.isLightTheme, widget.type),
                trailing: Icon(
                  I18n.current!.textDirection == TextDirection.ltr
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                ),
                onTap: widget.onTap,
              );
  }

  Widget _renderIcon(icon_url, icon, isLightTheme, String type) {
    IconData? item_icon = null;
    switch (widget.type) {
      case "home":
        item_icon = Icons.home;
        break;
      case "share":
        item_icon = Icons.share;
        break;
      case "about":
        item_icon = Icons.info;
        break;
      case "notification":
        item_icon = Icons.notifications;
        break;
      case "rate_us":
        item_icon = Icons.star;
        break;
      case "languages":
        item_icon = Icons.translate;
        break;
      case "dark":
        item_icon = Icons.brightness_medium;
        break;
      default:
        item_icon = null;
    }
    return item_icon != null
        ? Icon(
            item_icon,
            color: isLightTheme ? Colors.grey : Colors.white,
          )
        : icon_url != ""
            ? Image.network(
                icon_url,
                width: 20,
                height: 20,
                color: type == "url"
                    ? null
                    : isLightTheme
                        ? Colors.grey
                        : Colors.white,
              )
            : Icon(
                icon,
                color: isLightTheme ? Colors.grey : Colors.white,
              );
  }

  Widget _renderTitle(text, type, isLightTheme) {
    var title = text;
    var color = isLightTheme ? Colors.black : Colors.white;
    switch (type) {
      case "home":
        title = I18n.current!.home;
        break;
      case "share":
        title = I18n.current!.share;
        break;
      case "about":
        title = I18n.current!.about;
        break;
      case "notification":
        title = I18n.current!.notification;
        break;
      case "rate_us":
        title = I18n.current!.rate;
        break;
      case "languages":
        title = I18n.current!.languages;
        break;
      case "dark":
        title = isLightTheme ? I18n.current!.darkMode : I18n.current!.lightMode;
        break;
      default:
        title = text;
    }
    return Container(
        child: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 15.0, color: color),
    ));
  }

  Widget _renderTitleBlock(text, isLightTheme) {
    var color = isLightTheme ? Colors.black : Colors.white;
    return Align(
        alignment: I18n.current!.textDirection == TextDirection.ltr
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: color))));
  }
}
