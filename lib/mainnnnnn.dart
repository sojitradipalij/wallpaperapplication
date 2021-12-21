import 'package:flutter/material.dart';

import 'mainnew.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: Scaffold(
        body: Container(
          child: MyHomePage(),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    MyHomePage();
    /* Future.delayed(Duration(seconds: 4), () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperFetchData(),
          ));
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        /* backgroundColor: Colors.red,
      body: Text(
        'Welcome to BMI Calculator',
        style: new TextStyle(
            fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.bold),
      ),*/
        );
  }
}
/*

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'BMI Calculator',
          style: new TextStyle(
              color: Colors.white
          ),
        ),
      ),
    );
  }
*/
