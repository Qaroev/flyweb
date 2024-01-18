import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/AppBarItem.dart';
import 'package:flyweb/src/models/language.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  final Settings settings;

  const LanguageScreen(this.settings);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _LanguageScreen();
  }
}

class _LanguageScreen extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);
    List<Language> languages = widget.settings.languages!; //Config.language;

    return Scaffold(
      appBar:
          AppBarItem(settings: widget.settings, title: I18n.current!.languages),
      body: SafeArea(
          child: Column(
        children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.translate,
                size: 30,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(I18n.current!.appLang,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(I18n.current!.descLang,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                    ))
              ],
            )
          ]),
          Expanded(
              child: Container(
                  child: ListView.builder(
            itemCount: languages.length,
            // Add one more item for progress indicator
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                onTap: () {
                   appLanguage
                      .changeLanguage(Locale(languages[index].app_lang_code!, ""),languages[index].app_lang_code!);
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black26,
                  child: Locale(languages[index].app_lang_code!, "") ==
                          appLanguage.appLocal
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/img/checked.png',
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromRGBO(35, 208, 101, 0.5),
                          ),
                        )
                      : Container(),
                  backgroundImage: ExactAssetImage('assets/img/flag/' +
                      languages[index].code!.toLowerCase() +
                      '.png'),
                ),
                title: Text(
                  languages[index].title!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(languages[index].title_native!),
              );
            },
          ))),
        ],
      )),
    );
  }
}
