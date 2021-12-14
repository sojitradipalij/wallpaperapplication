import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:wallpaperapplication/downloaded_image.dart';
import 'package:wallpaperapplication/wallpaper.dart';

class ImageDB {
  static const dbName = 'images.db';
  static const tableRecent = 'recents';
  static const tableFavorites = 'favorites';
  static const tableDownloads = 'downloads';
  static const createdAtDesc = 'datetime(createdAt) DESC';
  static const nameAsc = 'name ASC';

  ImageDB._privateConstuctor();

  static final ImageDB instance = ImageDB._privateConstuctor();

  factory ImageDB.getInstance() => instance;

  static BriteDatabase? _database;

  Future<BriteDatabase> get database async => _database ??= await open();

  /* BriteDatabase _db;

  Future<BriteDatabase> get db async => _db;*/

  static Future<BriteDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, dbName);
    final database = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''CREATE TABLE $tableRecent( 
            id TEXT PRIMARY KEY UNIQUE NOT NULL, 
            name TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            thumbnailUrl TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            uploadedTime TEXT NOT NULL,
            viewTime TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE $tableFavorites(
            imageID TEXT PRIMARY KEY UNIQUE NOT NULL, 
            creatorInfo TEXT,
            albumImage TEXT NOT NULL,
            creatorLink TEXT,
            licence TEXT
            uploadedTime TEXT NOT NULL,
            createdAt TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE $tableDownloads(
            id TEXT PRIMARY KEY UNIQUE NOT NULL, 
            name TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            createdAt TEXT NOT NULL
        )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('[DEBUG] onUpgrade from $oldVersion to $newVersion');

        if (oldVersion == 1) {
          await db.execute('''CREATE TABLE $tableDownloads(
              id TEXT PRIMARY KEY UNIQUE NOT NULL, 
              name TEXT NOT NULL,
              imageUrl TEXT NOT NULL,
              createdAt TEXT NOT NULL
          )''');
        }
      },
    );
    return BriteDatabase(database);
  }

  Future<Null> close() async {
    final dbClient = _database;
    await dbClient!.close();
  }

  ///
  /// Recent images
  ///
  /*
  Future<int> insertRecentImage(Wallpaper image) async {
    final values = (image..viewTime = DateTime.now()).toJson();
    BriteDatabase dbClient = await instance.database;
    return await dbClient.insert(
      tableRecent,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future<int> updateRecentImage(ImageModel image) async {
    final dbClient = await db;
    return await dbClient.update(
      tableRecent,
      image.toJson(),
      where: 'id = ?',
      whereArgs: [image.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteRecentImageById(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      tableRecent,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllRecentImages() async {
    final dbClient = await db;
    return await dbClient.delete(tableRecent, where: '1');
  }

  Future<ImageModel?> getRecentImageById(String id) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      tableRecent,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty
        ? ImageModel.fromJson(id: maps.first['id'] as String, json: maps.first)
        : null;
  }

  Stream<List<ImageModel>> getRecentImages({int? limit}) async* {
    final dbClient = await db;
    final query$ = dbClient.createQuery(
      tableRecent,
      orderBy: 'datetime(viewTime) DESC',
      limit: limit,
    );
    yield* query$.mapToList(
            (row) => ImageModel.fromJson(id: row['id'] as String, json: row));
  }*/

  ///
  /// Favorite images
  ///
  Future<int> insertFavoriteImage(Wallpaper image) async {
    final values = image.toJson();
    values['createdAt'] = DateTime.now().toIso8601String();
    values.remove('viewTime');

    BriteDatabase dbClient = await instance.database;
    return await dbClient.insert(
      tableFavorites,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isFavoriteImage(String id) async {
    BriteDatabase dbClient = await instance.database;
    final maps = await dbClient.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM $tableFavorites WHERE imageID=? LIMIT 1)',
      [id],
    );
    var values;
    return maps.isNotEmpty &&
        (values = maps[0].values).isNotEmpty &&
        values.first == 1;
  }

  Future<int> deleteFavoriteImageById(String id) async {
    BriteDatabase dbClient = await instance.database;
    return await dbClient.delete(
      tableFavorites,
      where: 'imageID = ?',
      whereArgs: [id],
    );
  }

  Stream<List<Wallpaper>> getFavoriteImages({
    String orderBy = createdAtDesc,
    int? limit,
  }) async* {
    BriteDatabase dbClient = await instance.database;
    yield* dbClient
        .createQuery(
          tableFavorites,
          orderBy: orderBy,
          limit: limit,
        )
        .mapToList((row) => Wallpaper.fromJson(row));
  }

  /*Future<int> updateFavoriteImage(Wallpaper image) async {
    BriteDatabase dbClient = await instance.database;
    return dbClient.rawUpdate('''
      UPDATE $tableFavorites
      SET name = ?, imageUrl = ?, thumbnailUrl = ?, categoryId = ?, uploadedTime = ?
      WHERE id = ?
    ''', <String>[
      image.name,
      image.imageUrl,
      image.thumbnailUrl,
      image.categoryId,
      image.uploadedTime.toDate().toIso8601String(),
      image.id,
    ]);
  }*/

  ///
  /// Downloaded images
  ///

  Future<List<DownloadedImage>> getDownloadedImages(
      {String orderBy = createdAtDesc, int? limit}) async {
    // final dbClient = await (_database as FutureOr<BriteDatabase>);
    BriteDatabase dbClient = await instance.database;
    final maps = limit != null
        ? await dbClient.query(
            tableDownloads,
            orderBy: orderBy,
            limit: limit,
          )
        : await dbClient.query(
            tableDownloads,
            orderBy: orderBy,
          );
    return maps.map((json) => DownloadedImage.fromJson(json)).toList();
  }

  Future<bool> insertDownloadedImage(DownloadedImage image) async {
    // final dbClient = await (_database as FutureOr<BriteDatabase>);
    // final dbClient = _database;
    BriteDatabase dbClient = await instance.database;

    final id = await dbClient.insert(
      tableDownloads,
      image.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id != -1;
  }

  Future<bool> deleteDownloadedImageById({required String id}) async {
    // final dbClient = await (_database as FutureOr<BriteDatabase>);
    BriteDatabase dbClient = await instance.database;
    final rows = await dbClient.delete(
      tableDownloads,
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows > 0;
  }
}
