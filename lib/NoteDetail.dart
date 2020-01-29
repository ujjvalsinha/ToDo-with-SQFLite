import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/DatabaseHelper.dart';
import 'package:todo/Note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.tittle;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    moveToLastScreen();
                  }),
            ),
            body: Padding(
              padding: EdgeInsets.all(2),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 5),
                      child: ListTile(
                        leading: const Icon(Icons.low_priority),
                        title: DropdownButton(
                            items: _priorities.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            value: getPriorityAsString(note.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            }),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                            controller: titleController,
                            style: textStyle,
                            onChanged: (value) {
                              updateTitle();
                            },
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: textStyle,
                              icon: Icon(Icons.title),
                            ))),
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextField(
                          controller: descriptionController,
                          style: textStyle,
                          onChanged: (value) {
                            updateDescription();
                          },
                          decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: textStyle,
                              icon: Icon(Icons.details))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(children: <Widget>[
                        Expanded(
                            child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.green,
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        )),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                            child: RaisedButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ))
                      ]),
                    )
                  ],
                ),
              ),
            )));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
      print("update $result");
    } else {
      result = await helper.insertNote(note);
      print(result);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
    
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Task Deleted');
    } else {
      _showAlertDialog('Status', 'Error');
    }
  }
  void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),//
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}
} 