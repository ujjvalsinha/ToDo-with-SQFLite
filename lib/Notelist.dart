import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo/DatabaseHelper.dart';
import 'package:todo/NoteDetail.dart';

import 'Note.dart';

class Notelist extends StatefulWidget {
  @override
  _NotelistState createState() => _NotelistState();
}

class _NotelistState extends State<Notelist> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("TO DO"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.redAccent,
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
              ),
              title: Text(
                this.noteList[position].tittle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(Icons.open_in_new, color: Colors.white),
                onTap: () {
                  navigateToDetail(this.noteList[position], 'Edit to do');
                },
              ),
            ),
          );
        });
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        {
          setState(() {
            this.noteList = noteList;
            this.count = noteList.length;
          });
        }
      });
    });
  }
}
