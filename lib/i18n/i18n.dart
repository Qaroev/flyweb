import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';

class I18n implements WidgetsLocalizations {
  //I18n(this.locale);
  SharedPref sharedPref = SharedPref();

  I18n(this.locale) {
    loadSharedPrefs();
  }

  Future loadSharedPrefs() async {
    try {
      var set = await sharedPref.read("settings");
      if (set != null) {
        Settings _settings = Settings.fromJson(set);

        Map<String, Map<String, String>> translate = {};

        _settings.languages?.forEach((element) {
          Map<String, String> tran = {};

          element.translations?.forEach((element) {
            tran[element.lang_key!] = element.lang_value!;
          });
          tran["rtl"] = element.rtl!;

          translate[element.app_lang_code.toString()] = tran;
        });

        _localizedValues = translate;
      }
    } catch (Excepetion) {}
  }

  static Future refreshI18n(Settings _settings) async {
    try {
      Map<String, Map<String, String>> translate = {};

      _settings.languages?.forEach((element) {
        Map<String, String> tran = {};

        element.translations?.forEach((element) {
          tran[element.lang_key!] = element.lang_value!;
        });
        tran["rtl"] = element.rtl!;

        translate[element.app_lang_code.toString()] = tran;
      });
      _localizedValues = translate;
    } catch (Excepetion) {}
  }

  static I18n? current;

  static const GeneratedLocalizationsDelegate delegate =
  GeneratedLocalizationsDelegate();

  static I18n? of(BuildContext context) =>
      Localizations.of<I18n>(context, I18n);

  final Locale locale;

  static Map<String, Map<String, String>>? _localizedValues;

  String get title {
    return _localizedValues![locale.languageCode]!['title']!;
  }

  String get home {
    return _localizedValues![locale.languageCode]!['home']!;
  }

  String get share {
    return _localizedValues![locale.languageCode]!['share']!;
  }

  String get about {
    return _localizedValues![locale.languageCode]!['about']!;
  }

  String get rate {
    return _localizedValues![locale.languageCode]!['rate_us']!;
  }

  String get update {
    return _localizedValues![locale.languageCode]!['update_application']!;
  }

  String get notification {
    return _localizedValues![locale.languageCode]!['notification']!;
  }

  String get languages {
    return _localizedValues![locale.languageCode]!['languages']!;
  }

  String get appLang {
    return _localizedValues![locale.languageCode]!['app_language']!;
  }

  String get descLang {
    return _localizedValues![locale.languageCode]![
    'select_your_preferred_languages']!;
  }

  String get whoops {
    return _localizedValues![locale.languageCode]!['whoops']!;
  }

  String get noInternet {
    return _localizedValues![locale.languageCode]!['no_internet_connection']!;
  }

  String get tryAgain {
    return _localizedValues![locale.languageCode]!['try_again']!;
  }

  String get closeApp {
    return _localizedValues![locale.languageCode]!['close_app']!;
  }

  String get sureCloseApp {
    return _localizedValues![locale.languageCode]![
    'are_you_sure_want_to_quit_this_application']!;
  }

  String get ok {
    return _localizedValues![locale.languageCode]!['ok']!;
  }

  String get cancel {
    return _localizedValues![locale.languageCode]!['cancel']!;
  }

  String get changeTheme {
    return _localizedValues![locale.languageCode]!['change_theme']!;
  }

  String get customizeYourOwnWay {
    return _localizedValues![locale.languageCode]!['customize_your_own_way']!;
  }

  String get navigationBarStyle {
    return _localizedValues![locale.languageCode]!['navigation_bar_style']!;
  }

  String get headerType {
    return _localizedValues![locale.languageCode]!['header_type']!;
  }

  String get leftButtonOption {
    return _localizedValues![locale.languageCode]!['left_button_option']!;
  }

  String get rightButtonOption {
    return _localizedValues![locale.languageCode]!['right_button_option']!;
  }

  String get colorGradient {
    return _localizedValues![locale.languageCode]!['color_gradient']!;
  }

  String? get colorSolid {
    return _localizedValues![locale.languageCode]!['color_solid']!;
  }

  String get loadingAnimation {
    return _localizedValues![locale.languageCode]!['loading_animation']!;
  }

  String get backToHomePage {
    return _localizedValues![locale.languageCode]!['back_to_home_page']!;
  }

  String get darkMode {
    return _localizedValues![locale.languageCode]!['dark_mode']!;
  }

  String get lightMode {
    return _localizedValues![locale.languageCode]!['light_mode']!;
  }

  String social(String type) {
    return type;
  }

  String get follow_us {
    return _localizedValues![locale.languageCode]!['follow_us']!;
  }

  String get get_start {
    return _localizedValues![locale.languageCode]!['get_start']!;
  }

  String get skip {
    return _localizedValues![locale.languageCode]!['skip']!;
  }

  TextDirection get textDirection {
    try {
      if (_localizedValues![locale.languageCode]!['rtl'] == "1") {
        return TextDirection.rtl;
      } else {
        return TextDirection.ltr;
      }
    } catch (e) {
      return TextDirection.ltr;
    }
  }

  @override
  // TODO: implement reorderItemDown
  String get reorderItemDown => throw UnimplementedError();

  @override
  // TODO: implement reorderItemLeft
  String get reorderItemLeft => throw UnimplementedError();

  @override
  // TODO: implement reorderItemRight
  String get reorderItemRight => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToEnd
  String get reorderItemToEnd => throw UnimplementedError();

  @override
  // TODO: implement reorderItemToStart
  String get reorderItemToStart => throw UnimplementedError();

  @override
  // TODO: implement reorderItemUp
  String get reorderItemUp => throw UnimplementedError();
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<I18n> load(Locale locale) {
    I18n.current = I18n(locale);
    return SynchronousFuture<I18n>(I18n(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<I18n> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    final Set<String> kMaterialSupportedLanguages =
    HashSet<String>.from(const <String>[
      'af', // Afrikaans
      'am', // Amharic
      'ar', // Arabic
      'as', // Assamese
      'az', // Azerbaijani
      'be', // Belarusian
      'bg', // Bulgarian
      'bn', // Bengali Bangla
      'bs', // Bosnian
      'ca', // Catalan Valencian
      'cs', // Czech
      'da', // Danish
      'de', // German
      'el', // Modern Greek
      'en', // English
      'es', // Spanish Castilian
      'et', // Estonian
      'eu', // Basque
      'fa', // Persian
      'fi', // Finnish
      'fil', // Filipino Pilipino
      'fr', // French
      'gl', // Galician
      'gsw', // Swiss German Alemannic Alsatian
      'gu', // Gujarati
      'he', // Hebrew
      'hi', // Hindi
      'hr', // Croatian
      'hu', // Hungarian
      'hy', // Armenian
      'id', // Indonesian
      'is', // Icelandic
      'it', // Italian
      'ja', // Japanese
      'ka', // Georgian
      'kk', // Kazakh
      'km', // Khmer Central Khmer
      'kn', // Kannada
      'ko', // Korean
      'ky', // Kirghiz Kyrgyz
      'lo', // Lao
      'lt', // Lithuanian
      'lv', // Latvian
      'mk', // Macedonian
      'ml', // Malayalam
      'mn', // Mongolian
      'mr', // Marathi
      'ms', // Malay
      'my', // Burmese
      'nb', // Norwegian Bokmål
      'ne', // Nepali
      'nl', // Dutch Flemish
      'no', // Norwegian
      'or', // Oriya
      'pa', // Panjabi Punjabi
      'pl', // Polish
      'ps', // Pushto Pashto
      'pt', // Portuguese
      'ro', // Romanian Moldavian Moldovan
      'ru', // Russian
      'si', // Sinhala Sinhalese
      'sk', // Slovak
      'sl', // Slovenian
      'sq', // Albanian
      'sr', // Serbian
      'sv', // Swedish
      'sw', // Swahili
      'ta', // Tamil
      'te', // Telugu
      'th', // Thai
      'tl', // Tagalog
      'tr', // Turkish
      'uk', // Ukrainian
      'ur', // Urdu
      'uz', // Uzbek
      'vi', // Vietnamese
      'zh', // Chinese
      'zu', // Zulu
    ]);

    return List<Locale>.generate(
      kMaterialSupportedLanguages.length,
          (index) => Locale(kMaterialSupportedLanguages.elementAt(index), ""),
    );
  }

/*  LocaleListResolutionCallback listResolution(
      {Locale fallback, bool withCountry = true}) {
    return (List<Locale> locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution(
      {Locale fallback, bool withCountry = true}) {
    return (Locale locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }*/

  @override
  Future<I18n> load(Locale locale) {
    I18n.current = I18n(locale);
    return SynchronousFuture<I18n>(I18n.current!);
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported,
      bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    return true;
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry &&
            (supportedLocale.countryCode == null ||
                supportedLocale.countryCode!.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}
