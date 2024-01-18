import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/widgets/slide_dots.dart';
import 'package:flyweb/src/widgets/slide_items/slide_item.dart';

class OnBoardingScreen extends StatefulWidget {
  final String url;
  final Settings settings;

  const OnBoardingScreen(this.url, this.settings);

  @override
  State<StatefulWidget> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < widget.settings.sliders!.length) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 700),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: topSliderLayout(),
    );
  }

  Widget topSliderLayout() => Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.settings.sliders!.length,
              itemBuilder: (ctx, i) => SlideItem(i, widget.settings.sliders!),
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: <Widget>[
                    _currentPage == widget.settings.sliders!.length - 1
                        ? Align(
                            alignment:
                                I18n.current!.textDirection == TextDirection.rtl
                                    ? Alignment.bottomLeft
                                    : Alignment.bottomRight,
                            child: ElevatedButton(
                              child: Text(
                                  _currentPage <
                                          widget.settings.sliders!.length - 1
                                      ? "NEXT"
                                      : I18n.current!.get_start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  )),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(HexColor(
                                          Setting.getValue(
                                              widget.settings.setting!,
                                              "firstColor"))),
                                  shadowColor: MaterialStateProperty.all<Color>(
                                      Colors.white)),
                              onPressed: () {
                                if (_currentPage <
                                    widget.settings.sliders!.length - 1)
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                else {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              HomeScreen(widget.url,
                                                  widget.settings)));
                                }
                              },
                            ))
                        : Container(),
                    Align(
                      alignment:
                          I18n.current!.textDirection == TextDirection.rtl
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                        child: RichText(
                          text: TextSpan(
                            style:
                                TextStyle(color: Colors.grey, fontSize: 20.0),
                            children: <TextSpan>[
                              TextSpan(
                                  text: I18n.current!.skip,
                                  style: TextStyle(
                                    color: HexColor(Setting.getValue(
                                        widget.settings.setting!,
                                        "firstColor")),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomeScreen(widget.url,
                                                      widget.settings)));
                                    }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: AlignmentDirectional.bottomCenter,
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0;
                              i < widget.settings.sliders!.length;
                              i++)
                            if (i == _currentPage)
                              SlideDots(
                                  true,
                                  Setting.getValue(
                                      widget.settings.setting!, "firstColor"))
                            else
                              SlideDots(
                                  false,
                                  Setting.getValue(
                                      widget.settings.setting!, "firstColor"))
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      );
}
