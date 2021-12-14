import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wallpaperapplication/database.dart';
import 'package:wallpaperapplication/wallpaper.dart';
import 'package:wallpaperapplication/wallpaperfullview.dart';

@immutable
class FavoritesPage extends StatelessWidget {
  final Stream<String> sortOrderStream;

  const FavoritesPage(this.sortOrderStream);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder<List<Wallpaper>>(
        stream: sortOrderStream.distinct().switchMap(
            (order) => ImageDB.getInstance().getFavoriteImages(orderBy: order)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final images = snapshot.data;

          if (images!.isEmpty) {
            return Center(
              child: Text(
                'Your favorites is empty',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 9 / 16,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewWallpaper(
                            wallpaper: images[index],
                          ),
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: CachedNetworkImage(
                        imageUrl: "http://159.65.146.129/Wallpaper/thumb/" +
                            images[index].albumImage +
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
              // return WallpaperFetchData(images[index]);
            },
            itemCount: images.length,
          );
        },
      ),
    );
  }
}
