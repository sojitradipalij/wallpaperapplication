import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_extend/share_extend.dart';
import 'package:wallpaperapplication/constants.dart';
import 'package:wallpaperapplication/database.dart';
import 'package:wallpaperapplication/downloaded_image.dart';
import 'package:wallpaperapplication/utils.dart';
import 'package:wallpaperapplication/wallpaper.dart';

var dio = Dio();

class ImageViewWallpaper extends StatefulWidget {
  final Wallpaper wallpaper;

  ImageViewWallpaper({Key? key, required this.wallpaper}) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageViewWallpaper> {
  late bool isLoading;
  late Wallpaper wallpaper;
  final imageDB = ImageDB.getInstance();

  // late StreamSubscription subscription;
  // late StreamSubscription subscription1;
  // final imagesCollection = Firestore.instance.collection('images');

  // final scaffoldKey = GlobalKey<ScaffoldState>();

  final StreamController<bool> _isFavoriteStreamController =
      StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    isLoading = false;
    wallpaper = widget.wallpaper;

    /* final imageStream = imagesCollection
        .document(wallpaper.imageID)
        .snapshots()
        .map(mapperImageModel);
    subscription = imageStream.listen(_onListen);
    subscription1 = Rx.combineLatest2<Wallpaper, bool, Map<String, dynamic>>(
      imageStream,
      _isFavoriteStreamController.stream.distinct(),
      (img, isFav) => {
        'image': img,
        'isFavorite': isFav,
      },
    )
        .where((map) => map['isFavorite'])
        .map<Wallpaper>((map) => map['image'])
        .listen((Wallpaper newImage) {
      debugPrint('onListen fav $newImage');
      debugPrint('onListen fav old $imageModel');

      imageDB
          .updateFavoriteImage(newImage)
          .then((i) => debugPrint('Updated fav $i'))
          .catchError((e) => debugPrint('Updated fav error $e'));
    });*/

    _isFavoriteStreamController.addStream(
      Stream.fromFuture(
        imageDB.isFavoriteImage(wallpaper.imageID),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isFavoriteStreamController.close();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // key: scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).backgroundColor.withOpacity(0.8),
                Theme.of(context).backgroundColor.withOpacity(0.9),
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
          ),
          child: Stack(
            children: <Widget>[
              _buildCenterImage(),
              _buildAppbar(context),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    final onPressedWhileLoading =
        () => _showSnackBar('Downloading...Please wait');
    return Positioned(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: isLoading ? CircularProgressIndicator() : Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: Colors.black.withOpacity(0.7)),
                  onPressed: isLoading ? onPressedWhileLoading : download,
                  child: Text(
                    'Download',
                    textAlign: TextAlign.center,
                  ),
                ),
                fit: FlexFit.tight,
              ),
              Flexible(
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: Colors.black.withOpacity(0.7)),
                  onPressed: isLoading
                      ? onPressedWhileLoading
                      : _showDialogSetImageAsWallpaper,
                  child: Text(
                    'Set wallpaper',
                    textAlign: TextAlign.center,
                  ),
                ),
                fit: FlexFit.tight,
              ),
            ],
          ),
        ],
      ),
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
    );
  }

  Positioned _buildAppbar(BuildContext context) {
    final favoriteIconButton = StreamBuilder(
      stream: _isFavoriteStreamController.stream.distinct(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        debugPrint('DEBUG ${snapshot.data}');

        if (snapshot.hasError || !snapshot.hasData) {
          return Container();
        }
        final isFavorite = snapshot.data;
        if (isFavorite != null) {
          return IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => _changeFavoriteStatus(isFavorite),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          );
        } else {
          return IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () => _changeFavoriteStatus(false),
            tooltip: 'Remove from favoritesssssssss',
          );
        }
      },
    );

    final closeButton = ClipOval(
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    final textName = Expanded(
      child: Text(
        wallpaper.albumImage.substring(0, wallpaper.albumImage.indexOf('_')) +
            " Wallpaper",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );

    return Positioned(
      child: Container(
        child: Row(
          children: <Widget>[
            closeButton,
            SizedBox(width: 8.0),
            textName,
            favoriteIconButton,
            IconButton(
              icon: Icon(Icons.share, color: Colors.white),
              onPressed: () async {
                final targetPlatform = Theme.of(context).platform;

                // get external directory
                Directory externalDir;
                switch (targetPlatform) {
                  case TargetPlatform.android:
                    externalDir = (await getExternalStorageDirectory())!;
                    break;
                  case TargetPlatform.iOS:
                    externalDir = await getApplicationDocumentsDirectory();
                    break;
                  default:
                    _showSnackBar('Not support target: $targetPlatform');
                    return _done();
                }
                print('externalDir=$externalDir');

                final filePath = path.join(externalDir.path, 'flutterImages',
                    wallpaper.albumImage.replaceAll('thb', 'hd') + ".webp");
                print('filePath=$filePath');

                final file = File(filePath);
                if (file.existsSync()) {
                  ShareExtend.share(file.path, "image");
                } else {
                  _showSnackBar('You need Donwload Image before');
                }
              },
              tooltip: 'Share to facebook',
            ),
          ],
        ),
        height: kToolbarHeight,
        constraints: BoxConstraints.expand(height: kToolbarHeight),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Colors.black,
              Colors.transparent,
            ],
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
            stops: const [0.1, 0.9],
          ),
        ),
      ),
      top: 0.0,
      left: 0.0,
      right: 0.0,
    );
  }

  Center _buildCenterImage() {
    return Center(
      child: Hero(
        tag: "imageModel.id",
        child: CachedNetworkImage(
          imageUrl: "http://159.65.146.129/Wallpaper/hd/" +
              wallpaper.albumImage.replaceAll('thb', 'hd') +
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
    );
  }

  void _showSnackBar(String text,
      {Duration duration = const Duration(seconds: 1)}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), duration: duration));
  }

  Future _showDialogSetImageAsWallpaper() {
    final onPressedWhileLoading =
        () => _showSnackBar('Downloading...Please wait');
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set wallpaper"),
          content: Text("Set this image as wallpaper?"),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: isLoading ? onPressedWhileLoading : _setWallpaper,
            ),
          ],
        );
      },
    );
  }

  Future download() async {
    try {
      await _askPermission();

      final targetPlatform = Theme.of(context).platform;

      // get external directory
      Directory externalDir;
      switch (targetPlatform) {
        case TargetPlatform.android:
          externalDir = Directory("storage/emulated/0/Download/WallpapersApp");
          if ((await externalDir.exists())) {
            // TODO:
            print("exist");
          } else {
            // TODO:
            print("not exist");
            await externalDir.create();
          }
          break;
        case TargetPlatform.iOS:
          externalDir = await getApplicationDocumentsDirectory();
          break;
        default:
          _showSnackBar('Not support target: $targetPlatform');
          return _done();
      }
      print('externalDir=$externalDir');

      final filePath = path.join(externalDir.path,
          wallpaper.albumImage.replaceAll('thb', 'hd') + ".webp");

      final file = File(filePath);
      if (file.existsSync()) {
        _showSnackBar('Image Already Downloaded');
      } else {
        setState(() => isLoading = true);
        print('Start download...');
        final bytes = await http.readBytes(Uri.parse(
            "http://159.65.146.129/Wallpaper/hd/" +
                wallpaper.albumImage.replaceAll('thb', 'hd') +
                ".webp"));
        print('Done download...');

        final queryData = MediaQuery.of(context);
        final width =
            (queryData.size.shortestSide * queryData.devicePixelRatio).toInt();
        final height =
            (queryData.size.longestSide * queryData.devicePixelRatio).toInt();

        final outBytes = await methodChannel.invokeMethod(
          resizeImage,
          <String, dynamic>{
            'bytes': bytes,
            'width': width,
            'height': height,
          },
        );

        //save image to storage
        final saveFileResult =
            saveImage({'filePath': filePath, 'bytes': outBytes});

        if (saveFileResult) {
          await ImageDB.getInstance().insertDownloadedImage(
            DownloadedImage(
              wallpaper.imageID.toString(),
              wallpaper.albumImage.replaceAll('thb', 'hd').toString(),
              wallpaper.albumImage.replaceAll('thb', 'hd') + '.webp',
              DateTime.now(),
            ),
          );
        }

        _showSnackBar(
          saveFileResult
              ? 'Image downloaded successfully'
              : 'Failed to download image',
        );
      }
      // call scanFile method, to show image in gallery
      methodChannel
          .invokeMethod(
            scanFile,
            <String>[wallpaper.albumImage.replaceAll('thb', 'hd') + '.webp'],
          )
          .then((result) => print('Scan file: $result'))
          .catchError((e) => print('Scan file error: $e'));
    } on PlatformException catch (e) {
      _showSnackBar(e.message.toString());
    } catch (e, s) {
      _showSnackBar('An error occurred');
      debugPrint('Download image: $e, $s');
    }
    return _done();
  }

  Future _setWallpaper() async {
    Navigator.pop(context, false);
    await _askPermission();
    // setState(() => isLoading = true);
    try {
      final targetPlatform = Theme.of(context).platform;

      // get external directory
      Directory externalDir;
      switch (targetPlatform) {
        case TargetPlatform.android:
          externalDir = Directory("storage/emulated/0/Download/WallpapersApp");
          if ((await externalDir.exists())) {
            // TODO:
            print("exist");
          } else {
            // TODO:
            print("not exist");
            await externalDir.create();
          }
          break;
        case TargetPlatform.iOS:
          externalDir = await getApplicationDocumentsDirectory();
          break;
        default:
          _showSnackBar('Not support target: $targetPlatform');
          return _done();
      }

      final filePath = path.join(externalDir.path, 'flutterImages',
          wallpaper.albumImage.replaceAll('thb', 'hd') + ".webp");
      if (!File(filePath).existsSync()) {
        return _showSnackBar('You need Donwload Image before');
      }
      if (targetPlatform == TargetPlatform.android) {
        // set image as wallpaper
        // if (await _showDialogSetImageAsWallpaper()) {
        showProgressDialog(context, 'Please wait...');
        try {
          final res = await methodChannel.invokeMethod(
            setWallpaper,
            <String>[
              'flutterImages',
              wallpaper.albumImage.replaceAll('thb', 'hd') + ".webp"
            ],
          );
          _showSnackBar(res);
        } finally {
          Navigator.pop(context);
        }
        // }
      } else if (targetPlatform == TargetPlatform.iOS) {
        await methodChannel.invokeMethod(
          setWallpaper,
          <String>[
            'flutterImages',
            wallpaper.albumImage.replaceAll('thb', 'hd') + ".webp"
          ],
        );
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.message.toString());
    } catch (e) {
      _showSnackBar('An error occurred');
      debugPrint('Set wallpaper: $e');
    }
  }

  void _done() {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  _askPermission() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
      ].request();
      print(statuses[Permission.photos]);
    } else {
      /*var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }*/
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
    }
  }

  void _changeFavoriteStatus(bool isFavorite) {
    final result = isFavorite
        ? imageDB.deleteFavoriteImageById(wallpaper.imageID).then((i) => i > 0)
        : imageDB.insertFavoriteImage(wallpaper).then((i) => i != -1);
    result.then((b) {
      final msg = isFavorite ? 'Remove from favorites' : 'Add to favorites';
      if (b) {
        _showSnackBar('$msg successfully');
        _isFavoriteStreamController.add(!isFavorite);
      } else {
        _showSnackBar('$msg unsuccessfully');
      }
      _isFavoriteStreamController.addStream(
        Stream.fromFuture(
          imageDB.isFavoriteImage(wallpaper.imageID),
        ),
      );
    }).catchError((e) {
      debugPrint('DEBUG $e');
      _showSnackBar(e.toString());
    });
  }
}
