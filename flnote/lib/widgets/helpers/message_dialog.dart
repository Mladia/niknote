import 'package:flutter/material.dart';
import 'package:niknote/models/Todo.dart';
import 'package:niknote/scoped_models/app_model.dart';

import 'package:niknote/scoped_models/connected_model.dart';

class MessageDialog {

  static void show(
    BuildContext context, {
    String title = 'Something went wrong',
    String message = 'Please try again!',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay'),
            )
          ],
        );
      },
    );
  }

static Future <bool> showSnoozeOptions (
    BuildContext context, {
      unsnoozeNote,
      Todo todo
  }) async {
    // String title = 'Snoozing at time: ' + todo.snoozedDate.toString();
    String title = "Reminder for note:";
    String message = todo.title;
    print("Show Snooze optins");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                print("clicked canncel");
                 Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
              ),
            FlatButton(
              onPressed: () {
                print("clicked okay");
                unsnoozeNote(todo.id);
                Navigator.of(context).pop(true);
              },
              child: Text('Okay'),
            )
          ],
        );
      },
    );
  }

  static Future<bool> showConfirmationDelete (
    BuildContext context, {
    AppModel model,
    int noteId
  }) async {
    String title = 'Deleting a note';
    String message = 'Are you are sure you want to delete this note?';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () {
                print("Clicking ok");
                Navigator.of(context).pop();
                return model.removeTodo(noteId);
              },
              child: Text('Okay'),
            )
          ],
        );
      },
    );
  }
}
