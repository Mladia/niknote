import 'package:flutter/material.dart';
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


  static void showConfirmationDelete (
    BuildContext context, {
    AppModel model,
    int noteId
  }) {
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
                model.removeTodo(noteId);
                Navigator.of(context).pop();
              },
              child: Text('Okay'),
            )
          ],
        );
      },
    );
  }
}
