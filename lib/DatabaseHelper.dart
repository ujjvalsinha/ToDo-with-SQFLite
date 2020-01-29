import 'dart:core';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo/Note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescroption = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both android & ios
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    try {
      await db.execute(
        'create table $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT  ,$colTitle text,$colDescroption text,$colPriority integer,$colDate text)');
    } catch (e) {

      
    }
    
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    var result = await db.query(noteTable, orderBy: '$colPriority asc');
    return result;
  }

  //Insert Operation : Insert a note object to the database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId=?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('delete from $noteTable where $colId=$id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('select (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
