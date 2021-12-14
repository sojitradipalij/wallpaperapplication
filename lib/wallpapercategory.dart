import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperapplication/utils.dart';
import 'package:wallpaperapplication/wallpaperdata.dart';

import 'category.dart';

class WallpaperCategory extends StatefulWidget {
  const WallpaperCategory({Key? key}) : super(key: key);

  @override
  _WallpaperCategoryDataState createState() => _WallpaperCategoryDataState();
}

class _WallpaperCategoryDataState extends State<WallpaperCategory> {
  List<Category> loadlist = [];
  var isLoading = false;

  _fetchData() async {
    // I am connected to a mobile network.
    //get category token api and category data
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      http.post(Uri.parse("http://159.65.146.129:6500/token"), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).then((http.Response responsea) {
        final int statusCode = responsea.statusCode;
        print("====response ${responsea.body.toString()}");

        if (statusCode < 200 || statusCode >= 400) {
          // throw new ApiException(jsonDecode(responsea.body)["message"]);
        } else {
          setState(() {
            isLoading = true;
          });
          tokens = jsonDecode(responsea.body)['token'];
          http.post(Uri.parse("http://159.65.146.129:6500/imageCategory"),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $tokens',
                'parentid': "1",
              }).then((http.Response responsea) {
            final int statusCode = responsea.statusCode;
            print("====response ${responsea.body.toString()}");

            if (statusCode < 200 || statusCode >= 400) {
              // throw new ApiException(jsonDecode(responsea.body)["message"]);
            }
            loadlist = (json.decode(responsea.body)['data'] as List)
                .map((data) => new Category.fromJson(data))
                .toList();
            setState(() {
              isLoading = false;
            });
          });
        }
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
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: GridView.builder(
                itemCount: loadlist.length,
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  // mainAxisSpacing: 2.0,
                  // crossAxisSpacing: 2.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: new GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WallpaperFetchData(
                                indexs: loadlist[index].categoryID,
                                catname: loadlist[index].categoryName,
                              ),
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: CachedNetworkImage(
                            imageUrl: "http://159.65.146.129/Wallpaper/thumb/" +
                                loadlist[index].categoryImage,
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
