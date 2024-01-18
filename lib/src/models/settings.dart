import 'package:flyweb/src/models/About.dart';
import 'package:flyweb/src/models/Application.dart';
import 'package:flyweb/src/models/floating.dart';
import 'package:flyweb/src/models/language.dart';
import 'package:flyweb/src/models/navigationIcon.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/slider.dart';
import 'package:flyweb/src/models/social.dart';
import 'package:flyweb/src/models/splash.dart';
import 'package:flyweb/src/models/tab.dart';
import 'package:flyweb/src/models/userAgent.dart';

import 'menu.dart';
import 'page.dart';

class Settings {
  List<Setting>? setting = [];
  NavigationIcon? leftNavigationIcon;
  NavigationIcon? rightNavigationIcon;
  Splash? splash;
  UserAgent? userAgent;
  List<Tab>? tab = [];
  List<Menu>? menus = [];
  List<Floating>? floating = [];
  List<Page>? pages = [];
  List<Social>? socials = [];
  List<Slider>? sliders = [];
  List<NavigationIcon>? rightNavigationIconList = [];
  List<String>? nativeApplication = [];
  List<Language>? languages = [];
  List<About>? about = [];

  List<Application>? translationApplication = [];
  Map<String, Map<String, String>> translation = {};

  Settings(
      {this.setting,
      this.menus,
      this.floating,
      this.pages,
      this.socials,
      this.sliders,
      this.leftNavigationIcon,
      this.rightNavigationIcon,
      this.rightNavigationIconList,
      this.splash,
      this.userAgent,
      this.tab,
      this.nativeApplication,
      this.languages,
      this.about,
      this.translationApplication});

  Settings.fromJson(Map<String, dynamic> json) {
    if (json['settings'] != null) {
      setting = <Setting>[];
      json['settings'].forEach((v) {
        setting!.add(new Setting.fromJson(v));
      });
    }

    if (json['menudynamics'] != null) {
      menus = <Menu>[];
      json['menudynamics'].forEach((v) {
        menus!.add(new Menu.fromJson(v));
      });
    }

    if (json['floating'] != null) {
      floating = <Floating>[];
      json['floating'].forEach((v) {
        floating!.add(new Floating.fromJson(v));
      });
    }

    if (json['pages'] != null) {
      pages = <Page>[];
      json['pages'].forEach((v) {
        pages!.add(new Page.fromJson(v));
      });
    }

    if (json['socials'] != null) {
      socials = <Social>[];
      json['socials'].forEach((v) {
        socials!.add(new Social.fromJson(v));
      });
    }

    if (json['sliders'] != null) {
      sliders = <Slider>[];
      json['sliders'].forEach((v) {
        sliders!.add(new Slider.fromJson(v));
      });
    }

    if (json['leftNavigationIcon'] != null) {
      leftNavigationIcon =
          new NavigationIcon.fromJson(json['leftNavigationIcon']);
    }

    if (json['rightNavigationIcon'] != null) {
      rightNavigationIcon =
          new NavigationIcon.fromJson(json['rightNavigationIcon']);
    }

    if (json['rightNavigationIconList'] != null) {
      rightNavigationIconList = <NavigationIcon>[];
      json['rightNavigationIconList'].forEach((v) {
        rightNavigationIconList!.add(new NavigationIcon.fromJson(v));
      });
    }

    if (json['splash'] != null) {
      splash = new Splash.fromJson(json['splash']);
    }

    if (json['userAgent'] != null) {
      userAgent = new UserAgent.fromJson(json['userAgent']);
    }

    if (json['tab'] != null) {
      tab = <Tab>[];
      json['tab'].forEach((v) {
        tab!.add(new Tab.fromJson(v));
      });
    }

    if (json['nativeApplication'] != null) {
      nativeApplication = <String>[];
      json['nativeApplication'].forEach((v) {
        nativeApplication!.add(v);
      });
    }

    if (json['languages'] != null) {
      languages = <Language>[];
      json['languages'].forEach((v) {
        languages!.add(new Language.fromJson(v));
      });
    }

     if (json['about'] != null) {
      about = <About>[];
      json['about'].forEach((v) {
        about!.add(new About.fromJson(v));
      });
    }

    if (json['applicationTranslation'] != null) {
      translationApplication = <Application>[];
      json['applicationTranslation'].forEach((v) {
        translationApplication!.add(new Application.fromJson(v));
      });

      Map<String, Map<String, String>> translate = {};

      translationApplication?.forEach((element) {
        Map<String, String> tran = {};
        tran['title'] = element.title!;
        tran['sub_title'] = element.sub_title!;
        tran["lang"] = element.lang!;
        tran["url"] = element.url!;
        translate[element.lang.toString()] = tran;
      });
      translation = translate;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.setting != null) {
      data['setting'] = this.setting!.map((v) => v.toJson()).toList();
    }

    if (this.rightNavigationIconList != null) {
      data['rightNavigationIconList'] =
          this.rightNavigationIconList!.map((v) => v.toJson()).toList();
    }

    if (this.menus != null) {
      data['menudynamics'] = this.menus!.map((v) => v.toJson()).toList();
    }

    if (this.floating != null) {
      data['floating'] = this.floating!.map((v) => v.toJson()).toList();
    }

    if (this.pages != null) {
      data['pages'] = this.pages!.map((v) => v.toJson()).toList();
    }

    if (this.about != null) {
      data['about'] = this.about!.map((v) => v.toJson()).toList();
    }

    if (this.socials != null) {
      data['socials'] = this.socials!.map((v) => v.toJson()).toList();
    }

    if (this.sliders != null) {
      data['sliders'] = this.sliders!.map((v) => v.toJson()).toList();
    }

    if (this.rightNavigationIcon != null) {
      data['rightNavigationIcon'] = this.rightNavigationIcon!.toJson();
    }

    if (this.leftNavigationIcon != null) {
      data['leftNavigationIcon'] = this.leftNavigationIcon!.toJson();
    }

    if (this.splash != null) {
      data['splash'] = this.splash!.toJson();
    }

    if (this.userAgent != null) {
      data['userAgent'] = this.userAgent!.toJson();
    }

    if (this.tab != null) {
      data['tab'] = this.tab!.map((v) => v.toJson()).toList();
    }

    if (this.nativeApplication != null) {
      data['nativeApplication'] =
          this.nativeApplication!.map((v) => v).toList();
    }

    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }

    if (this.translationApplication != null) {
      data['applicationTranslation'] =
          this.translationApplication!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
