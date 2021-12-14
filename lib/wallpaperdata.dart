import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapplication/utils.dart';
import 'package:wallpaperapplication/wallpaper.dart';
import 'package:wallpaperapplication/wallpaperfullview.dart';

class WallpaperFetchData extends StatefulWidget {
  final int indexs;
  final String catname;

  const WallpaperFetchData(
      {Key? key, required this.indexs, required this.catname})
      : super(key: key);

  @override
  _WallpaperFetchDataState createState() => _WallpaperFetchDataState();
}

class _WallpaperFetchDataState extends State<WallpaperFetchData> {
  List<Wallpaper> loadlist = [];
  List<int> imageListnumber = [];
  var isLoading = false;
  late ScrollController _controller;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        _fetchloadmoredata();
        log('reach the bottom');
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        log('reach the top');
      });
    }
  }

  _fetchloadmoredata() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      http.post(Uri.parse("http://159.65.146.129:6500/imageGallery"), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $tokens',
        'indexnumber': widget.indexs.toString(),
      }).then((http.Response response) {
        final int statusCode = response.statusCode;
        // print("categorywisewallpaper ${response.body.toString()}");

        if (statusCode < 200 || statusCode >= 400) {
          // throw new ApiException(jsonDecode(responsea.body)["message"]);
        }
        List<Wallpaper> loadmorelist =
            (json.decode(response.body)['data'] as List)
                .map((data) => new Wallpaper.fromJson(data))
                .toList();

        print("load more fetch data");
        for (int i = 0; i < loadmorelist.length; i++) {
          print(loadmorelist[i].imageID);
        }

        imageListnumber.clear();
        for (int i = 0; i < loadlist.length; i++) {
          imageListnumber.add(int.parse(loadlist[i].imageID));
        }
        for (int i = 0; i < loadmorelist.length; i++) {
          if (imageListnumber.contains(int.parse(loadmorelist[i].imageID))) {
          } else {
            loadlist.add(loadmorelist[i]);
            print("not match data");
            print(loadmorelist[i].imageID);
          }
        }

        setState(() {
          isLoading = false;
        });
      });
    } else {
      // I am connected to a wifi network.
      Fluttertoast.showToast(
          msg: "No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _fetchData() async {
    // I am connected to a mobile network.
    //get category token api and category data
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      setState(() {
        isLoading = true;
      });
      http.post(Uri.parse("http://159.65.146.129:6500/imageGallery"), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $tokens',
        'indexnumber': widget.indexs.toString(),
      }).then((http.Response responsea) {
        final int statusCode = responsea.statusCode;
        // print("categorywisewallpaper ${responsea.body.toString()}");

        if (statusCode < 200 || statusCode >= 400) {
          // throw new ApiException(jsonDecode(responsea.body)["message"]);
        }
        List<Wallpaper> loadmorelist =
            (json.decode(responsea.body)['data'] as List)
                .map((data) => new Wallpaper.fromJson(data))
                .toList();
        print("fetch data");
        for (int i = 0; i < loadmorelist.length; i++) {
          print(loadmorelist[i].imageID);
        }
        loadlist.addAll(loadmorelist);

        setState(() {
          isLoading = false;
        });
      });
    } else {
      // I am connected to a wifi network.
      Fluttertoast.showToast(
          msg: "No Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = false;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    // if (loadlist.isNotEmpty) {

    _fetchData();
    // }
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catname),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff0b101d),
        child: Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          setState(() {
            _controller.jumpTo(0);
          });
        },
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: GridView.builder(
                controller: _controller,
                itemCount: loadlist.length,
                // padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.2),
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewWallpaper(
                                wallpaper: loadlist[index],
                              ),
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: CachedNetworkImage(
                            imageUrl: "http://159.65.146.129/Wallpaper/thumb/" +
                                loadlist[index].albumImage +
                                ".webp",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              constraints: BoxConstraints.expand(),
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/picture.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
