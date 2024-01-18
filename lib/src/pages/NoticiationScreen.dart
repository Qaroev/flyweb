import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/AppBarItem.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';

class NoticiationScreen extends StatefulWidget {
  final Settings settings;

  const NoticiationScreen(this.settings);

  @override
  State<StatefulWidget> createState() => _NoticiationScreen();
}

class _NoticiationScreen extends State<NoticiationScreen> {
  final _baseUrl =
      '${GlobalConfiguration().getValue('api_base_url')}/api/notification/notification.php';

  int _page = 0;
  int _limit = 20;

  bool _hasNextPage = true;

  bool _isFirstLoadRunning = false;

  bool _isLoadMoreRunning = false;

  List _list = [];

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res = await get(Uri.parse("$_baseUrl?page=$_page&_limit=$_limit"));
      setState(() {
        _list = json.decode(res.body);
      });
    } catch (err) {
      print('Something went wrong');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  // This function will be triggered whenver the user scroll
  // to near the bottom of the list view
  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1
      try {
        final res =
            await get(Uri.parse("$_baseUrl?page=$_page&_limit=$_limit"));

        final List fetchedPosts = json.decode(res.body);
        if (fetchedPosts.length > 0) {
          setState(() {
            _list.addAll(fetchedPosts);
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        print('Something went wrong!');
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = new ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBarItem(
          settings: widget.settings, title: I18n.current!.notification),
      body: _isFirstLoadRunning
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: _list.length,
                    itemBuilder: (_, index) => Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          _list[index]['title'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(_list[index]['content']),
                        onTap: () async {
                          if (_list[index]['url'] != "") {
                            final result = await Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: WebScreen(_list[index]['url']!,
                                        widget.settings)));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                if (_isLoadMoreRunning == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }
}
