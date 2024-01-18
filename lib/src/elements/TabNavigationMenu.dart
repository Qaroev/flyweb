import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
//import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

class TabNavigationMenu extends StatefulWidget {
  Settings settings;
  List<StreamController<int>> listStream;
  TabController tabController;
  int currentIndex;
  final ValueChanged<String?>? roloadWebUrl;

  TabNavigationMenu(
      {Key? key,
      required this.settings,
      required this.listStream,
      required this.tabController,
      required this.currentIndex,
      required this.roloadWebUrl})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _TabNavigationMenu();
  }
}

class _TabNavigationMenu extends State<TabNavigationMenu> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    bool isLight = themeProvider.isLightTheme;
    Color tab_color_icon_active = renderColor(
        isLight ? "tab_color_icon_active" : "tab_color_icon_active_dark");
    Color tab_color_icon_inactive = renderColor(
        isLight ? "tab_color_icon_inactive" : "tab_color_icon_inactive_dark");
    Color tab_color_background = renderColor(
        isLight ? "tab_color_background" : "tab_color_background_dark");

    return Setting.getValue(
                widget.settings.setting!, "tab_navigation_enable") ==
            "true"
        ? new Material(
            color: tab_color_background,
            child: new Container(
                /*decoration: BoxDecoration(
                  color: tab_color_background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),*/
                //height: 60.0,
                child: renderBubbleTab(
                    tab_color_background,
                    tab_color_icon_active,
                    tab_color_icon_inactive,
                    Setting.getValue(widget.settings.setting!, "tab_type") ==
                        "regular")))
        : Container(height: 0);
  }

  Color renderColor(color) {
    return HexColor(Setting.getValue(widget.settings.setting!, color));
  }

  String renderTabTitle(index) {
    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;
    if (widget.settings.tab![index] != null) {
      if (widget.settings.tab![index].translation[languageCode] != null)
        return widget.settings.tab![index].translation[languageCode]!["title"]!;
    }
    return " ";
  }

  Widget renderTab(Color tab_color_icon_active, Color tab_color_icon_inactive) {
    return new TabBar(
        onTap: (index) {
          for (int i = 0; i < widget.listStream.length; i++) {
            widget.listStream[i].add(index);
          }
        },
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: tab_color_icon_active, width: 2.5),
          //insets: EdgeInsets.symmetric(horizontal:16.0)
        ),
        controller: widget.tabController,
        labelColor: tab_color_icon_active,
        unselectedLabelColor: tab_color_icon_inactive,
        tabs: List.generate(widget.settings.tab!.length, (index) {
          return new Tab(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Image.network(widget.settings.tab![index].icon_url!,
                      width: 25,
                      height: 25,
                      color: widget.currentIndex == index
                          ? tab_color_icon_active
                          : tab_color_icon_inactive),
                  new SizedBox(height: 5),
                  new Flexible(
                      child: new Text(renderTabTitle(index),
                          //widget.settings.tab![index].title!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.getFont(
                            Setting.getValue(
                                widget.settings.setting!, "google_font"),
                            textStyle: TextStyle(
                                fontSize:
                                    widget.settings.tab!.length == 5 ? 8 : 10,
                                color: widget.currentIndex == index
                                    ? tab_color_icon_active
                                    : tab_color_icon_inactive),
                          ))),
                ]),
          );
        }));
  }

  Widget renderBubbleTab(
      Color tab_color_background,
      Color tab_color_icon_active,
      Color tab_color_icon_inactive,
      bool typeBar) {
    var appLanguage = Provider.of<AppLanguage>(context);
    String languageCode = appLanguage.appLocal.languageCode;
    return StylishBottomBar(
      backgroundColor: tab_color_background,
      //  option: AnimatedBarOptions(
      //    iconSize: 32,
      //    barAnimation: BarAnimation.liquid,
      //    iconStyle: IconStyle.animated,
      //    opacity: 0.3,
      //  ),
      option: typeBar
          ? AnimatedBarOptions(
              iconStyle: IconStyle.Default,
              // barStyle: BubbleBarStyle.vertical,
              // bubbleFillStyle: BubbleFillStyle.fill,
              // bubbleFillStyle: BubbleFillStyle.outlined,
              opacity: 0.3,
            )
          : BubbleBarOptions(
              barStyle: BubbleBarStyle.horizotnal,
              // barStyle: BubbleBarStyle.vertical,
              // bubbleFillStyle: BubbleFillStyle.fill,
              // bubbleFillStyle: BubbleFillStyle.outlined,
              opacity: 0.3,
            ),
      items: List.generate(widget.settings.tab!.length, (index) {
        return BottomBarItem(
          icon: new Image.network(
            widget.settings.tab![index].icon_url!,
            width: 22,
            height: 22,
            color: widget.currentIndex == index
                ? tab_color_icon_active
                : tab_color_icon_inactive,
          ),
          title: Padding(
              padding: EdgeInsets.only(top: typeBar ? 5 : 0),
              child: new Text(renderTabTitle(index),
                  //widget.settings.tab![index].title!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    Setting.getValue(widget.settings.setting!, "google_font"),
                    textStyle: TextStyle(
                        fontSize: widget.settings.tab!.length == 5 ? 10 : 12,
                        color: widget.currentIndex == index
                            ? tab_color_icon_active
                            : tab_color_icon_inactive),
                  ))),
          backgroundColor: widget.currentIndex == index
              ? tab_color_icon_active
              : tab_color_icon_inactive,
          /*activeIcon: new Image.network(widget.settings.tab![index].icon_url!,
                width: 25,
                height: 25,
                color: widget.currentIndex == index
                    ? tab_color_icon_active
                    : tab_color_icon_inactive),*/
        );
      }),
      //fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: widget.currentIndex,
      onTap: (int? index) {
        /*
        for (int i = 0; i < widget.listStream.length; i++) {
          if (index == widget.tabController.index) {
            print("TAB (0)=> " + index.toString());
            print("TAB (1)=> " + widget.tabController.index.toString());
            widget.roloadWebUrl!(index);
          }
          widget.listStream[i].add(index!);
          widget.tabController.index = index!;
        }
        */
        if (index == widget.tabController.index &&
            (Setting.getValue(widget.settings.setting!, "tab_refresh") ==
                "true")) {
          //print("TAB (0)=> " + index.toString());
          //print("TAB (1)=> " + widget.tabController.index.toString());
          widget.roloadWebUrl!(index.toString() + "#" + languageCode);
        }
        widget.tabController.index = index!;
      },
    );

    /*
      new BubbleBottomBar(
        onTap: (int? index) {
          for (int i = 0; i < widget.listStream.length; i++) {
            widget.listStream[i].add(index!);
            widget.tabController.index = index!;
            if (index == widget.tabController.index) {
              print("TAB (0)=> " + index.toString());
              print("TAB (1)=> " + widget.tabController.index.toString());
              widget.roloadWebUrl!(index);
            }
          }
        },
        currentIndex: widget.currentIndex,
        opacity: 0.2,
        items: List.generate(widget.settings.tab!.length, (index) {
          return BubbleBottomBarItem(
            icon: new Image.network(widget.settings.tab![index].icon_url!,
                width: 25,
                height: 25,
                color: widget.currentIndex == index
                    ? tab_color_icon_active
                    : tab_color_icon_inactive),
            activeIcon: new Image.network(widget.settings.tab![index].icon_url!,
                width: 25,
                height: 25,
                color: widget.currentIndex == index
                    ? tab_color_icon_active
                    : tab_color_icon_inactive),
            title: new Text(renderTabTitle(index),
                //widget.settings.tab![index].title!,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.getFont(
                  Setting.getValue(widget.settings.setting!, "google_font"),
                  textStyle: TextStyle(
                      fontSize: widget.settings.tab!.length == 5 ? 10 : 12,
                      color: widget.currentIndex == index
                          ? tab_color_icon_active
                          : tab_color_icon_inactive),
                )),
            backgroundColor: widget.currentIndex == index
                ? tab_color_icon_active
                : tab_color_icon_inactive,
          );
        }));
     */
  }
}
