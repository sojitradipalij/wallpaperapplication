import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaperapplication/database.dart';
import 'package:wallpaperapplication/downloads_page.dart';
import 'package:wallpaperapplication/favorites_page.dart';
import 'package:wallpaperapplication/trendingwallpaper.dart';
import 'package:wallpaperapplication/wallpapercategory.dart';

import 'dart:ui';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallpaper',
      theme: ThemeData(
        fontFamily: 'NunitoSans',
        brightness: Brightness.dark,
        primaryColor: Color(0xff070b16),
        primaryColorDark: Color(0xff070a11),
        primaryColorLight: Color(0xff141622),
        accentColor: Color(0xffffC126),
        backgroundColor: Color(0xff0b101d),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Drawer related
  int selectedIndex = 0;
  late List<Map<String, dynamic>> nav;
  late List<Widget> listTiles;

  // bool isSearching = false;

  /// clear history functionality
  final clearStreamController = StreamController<void>.broadcast();

  /// sort order favourites
  final sortOrderS = BehaviorSubject.seeded(ImageDB.createdAtDesc);

  String _currentRoute = "/";

  @override
  void initState() {
    super.initState();

    nav = [
      {
        'title': 'Categories',
        'icon': Icons.category,
        'builder': (BuildContext context) => WallpaperCategory(),
      },
      {
        'title': 'Favourites ',
        'icon': Icons.favorite,
        'builder': (BuildContext context) => FavoritesPage(sortOrderS.stream),
      },
      {
        'title': 'Downloaded',
        'icon': Icons.cloud_done,
        'builder': (BuildContext context) => DownloadedPage(),
      },
    ];

    listTiles = nav
        .asMap()
        .map((index, m) {
      return MapEntry(
        index,
        ListTile(
          title: Text(m['title']),
          trailing: Icon(m['icon']),
          onTap: () {
            setState(() => selectedIndex = index);

            Navigator.pop(context);
          },
        ),
      );
    })
        .values
        .toList();
  }

  _rateapp() async {
    // Android
    const url =
        'https://play.google.com/store/apps/details?id=livecrickerscore.crickerapp.crickfeed';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // iOS
      const url = 'http://maps.apple.com/?ll=52.32,4.917';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onWillPop(),
      child: Scaffold(
        key: scaffoldKey,
        drawer: _buildDrawer(context),
        appBar: _buildAppBar(context),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: nav[selectedIndex]['builder'](context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    clearStreamController.close();
    sortOrderS.close();
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Wallpaper HD Flutter',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/drawer_header_image.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.darken,
                  ),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4.0,
                    spreadRadius: 4.0,
                  )
                ],
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            listTiles[0],
            ListTile(
              title: Text('Trending image'),
              trailing: Icon(Icons.trending_up),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrendingWallpaper(),
                    ));
                // doRoute(context, '/');
              },
            ),
            Divider(color: Colors.white30),
            listTiles[1],
            listTiles[2],
            Divider(color: Colors.white30),
            ListTile(
              title: Text('Rate 5 Star'),
              trailing: Icon(Icons.star_border_outlined),
              onTap: () {
                _rateapp();
                doRoute(context, '/');
              },
            ),
            ListTile(
              title: Text('Share App'),
              trailing: Icon(Icons.share),
              onTap: () {
                _rateapp();
                doRoute(context, '/');
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.privacy_tip_outlined),
              onTap: () {
                _rateapp();
                doRoute(context, '/');
              },
            ),
            ListTile(
              title: Text('Our More App'),
              trailing: Icon(Icons.more_outlined),
              onTap: () {
                _rateapp();
                doRoute(context, '/');
              },
            ),
            Divider(color: Colors.white30),
            AboutListTile(
              applicationName: 'Flutter wallpaper HD',
              applicationIcon: FlutterLogo(),
              applicationVersion: '1.0.0',
            ),
          ],
        ),
      ),
    );
  }

  void doRoute(BuildContext context, String name) {
    if (_currentRoute != name)
      Navigator.pushReplacementNamed(context, name);
    else
      Navigator.pop(context);

    _currentRoute = name;
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(nav[selectedIndex]['title']),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Exit app'),
        content: Text('Do you want to exit app?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    )) ??
        false;
  }
}
