import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class AppBarItem extends StatefulWidget implements PreferredSizeWidget {
  Settings settings;
  String title;

  AppBarItem({Key? key, required this.settings, this.title = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _AppBarItem();
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _AppBarItem extends State<AppBarItem> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                themeProvider.isLightTheme
                    ? HexColor(Setting.getValue(
                        widget.settings.setting!, "firstColor"))
                    : themeProvider.darkTheme.primaryColor,
                themeProvider.isLightTheme
                    ? HexColor(Setting.getValue(
                        widget.settings.setting!, "secondColor"))
                    : themeProvider.darkTheme.primaryColor,
              ],
            ),
          ),
        ));
  }
}
