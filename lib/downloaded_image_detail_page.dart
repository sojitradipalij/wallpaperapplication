import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wallpaperapplication/constants.dart';
import 'package:wallpaperapplication/database.dart';

class DownloadedImageDetailPage extends StatefulWidget {
  final ImageDetail imageDetail;

  const DownloadedImageDetailPage({Key? key, required this.imageDetail})
      : super(key: key);

  @override
  _DownloadedImageDetailPageState createState() =>
      _DownloadedImageDetailPageState();
}

class _DownloadedImageDetailPageState extends State<DownloadedImageDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late ImageDetail imageDetail;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    imageDetail = widget.imageDetail;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.wallpaper),
          onPressed: _setWallpaper,
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    final closeButton = ClipOval(
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );

    final textName = Expanded(
      child: Text(
        imageDetail.name,
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
            Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: _deleteImage,
                tooltip: 'Delete',
              ),
            ),
            SizedBox(width: 8),
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

  Widget _buildCenterImage() {
    return Positioned.fill(
      child: Hero(
        tag: imageDetail.id,
        child: Image.file(
          imageDetail.imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _deleteImage() async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Delete image. This action cannot be undone!'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    if (delete ?? false) {
      try {
        await imageDetail.imageFile.delete();
        await ImageDB.getInstance()
            .deleteDownloadedImageById(id: imageDetail.id);
        _showSnackBar('Deleted ${imageDetail.name} successfully');
        Navigator.pop(context, true);
      } catch (e) {
        _showSnackBar('Error when deleting ${imageDetail.name}');
      }
    }
  }

  void _showSnackBar(String text,
      {Duration duration = const Duration(seconds: 1)}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), duration: duration));
  }

  void _setWallpaper() async {
    try {
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
          return _showSnackBar('Not support target: $targetPlatform');
      }
      final filePath = path.join(
          externalDir.path, 'flutterImages', imageDetail.name + '.webp');
      print('filePath: $filePath');
      // check image is exists
      if (!File(filePath).existsSync()) {
        return _showSnackBar('You need donwload image before');
      }

      if (targetPlatform == TargetPlatform.android) {
        // set image as wallpaper
        if (await _showDialogSetImageAsWallpaper()) {
          await methodChannel.invokeMethod(
            setWallpaper,
            <String>['flutterImages', '${imageDetail.name}.webp'],
          );
          _showSnackBar('Wallpaper Set Successfully.');
        }
      } else if (targetPlatform == TargetPlatform.iOS) {
        await methodChannel.invokeMethod(
          setWallpaper,
          <String>['flutterImages', '${imageDetail.name}.webp'],
        );
        _showSnackBar('Wallpaper Set Successfully.');
        print("File exists");
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.message.toString());
    } catch (e) {
      _showSnackBar('An error occurred');
      debugPrint('Set wallpaper: $e');
    }
  }

  Future _showDialogSetImageAsWallpaper() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set wallpaper'),
          content: Text('Set this image as wallpaper?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

class ImageDetail {
  final String id;
  final String name;
  final File imageFile;
  final DateTime createdAt;

  ImageDetail({
    required this.id,
    required this.name,
    required this.imageFile,
    required this.createdAt,
  });
}
