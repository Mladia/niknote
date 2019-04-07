import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:niknote/models/filter.dart';
import 'package:niknote/widgets/helpers/message_dialog.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/models/Todo.dart';
import 'package:niknote/widgets/todo/todo_card.dart';

class TodoListView extends StatelessWidget {
  Widget _buildEmptyText(AppModel model) {
    String emptyText;
    switch (model.filter) {
      case Filter.All:
        emptyText = 'This is boring here. \r\nCreate a todo to make it crowd.';
        break;

      case Filter.Done:
        emptyText =
            'This is boring here. \r\nCreate a Done todo to make it crowd.';
        break;

      case Filter.Current:
        emptyText =
            'This is boring here. \r\nCreate a running todo to make it crowd.';
        break;
      case Filter.Snoozed:
        emptyText =
            'This is boring here. \r\nCreate a snoozed todo to make it crowd.';
    }

    Widget svg = new SvgPicture.asset(
      'assets/todo_list.svg',
      width: 200,
    );

    return Container(
      color: Color.fromARGB(16, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          svg,
          SizedBox(
            height: 40.0,
          ),
          Text(
            emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListView(AppModel model) {
    print("building list view");
    return ListView.builder(
      itemCount: model.todos.length,
      itemBuilder: (BuildContext context, int index) {
        Todo todo = model.todos[index];

        return Dismissible(
            key: Key(todo.id.toString()),
            onDismissed: (DismissDirection dismissDirection) {
              return;
              print("onDissmised function");
              if (model.filter == Filter.Current )
                if (dismissDirection == DismissDirection.startToEnd) {
                  print("Deleting this note");
                  int noteId = todo.id;
                  model.toggleDone(noteId);
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("Note is done")));
                } else {
                  print("not known dismissable");
                } 
                else {
                  if (dismissDirection == DismissDirection.startToEnd) {
                    print("Deleting this note");
                    int noteId = todo.id;
                    MessageDialog.showConfirmationDelete(context, model: model, noteId: noteId );
                  } else if (dismissDirection == DismissDirection.endToStart) {
                    print("Deleting this note");
                    int noteId = todo.id;
                    MessageDialog.showConfirmationDelete(context, model: model, noteId: noteId );
                  } else {
                    print("not known dismissable");
                  } 
                }
            }, 
            // confirmDismiss: model.snoozeNote(todo.id, null),
            confirmDismiss: (DismissDirection dismissDirection) async {
              print("Confirm dimiss in direction " + dismissDirection.toString());

              if (model.filter == Filter.Current  || model.filter == Filter.Snoozed ) {
                if (dismissDirection == DismissDirection.startToEnd) {
                  print("Marking note as done");
                  int noteId = todo.id;
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("Note is done")));
                  model.toggleDone(noteId);
                } else {
                  print("not known dismissable");
                } 
              } else {
                if (dismissDirection == DismissDirection.startToEnd) {
                  print("Deleting this note");
                  int noteId = todo.id;
                  return MessageDialog.showConfirmationDelete(context, model: model, noteId: noteId );
                } else if (dismissDirection == DismissDirection.endToStart) {
                  print("Deleting this note");
                  int noteId = todo.id;
                  return MessageDialog.showConfirmationDelete(context, model: model, noteId: noteId );
                } else {
                  print("not known dismissable");
                } 
              }

            },
            child: GestureDetector (
              onTap: () =>_settingModalBottomSheet(context, todo),
              onLongPress: () {
                print("Long pressing");
                print("Let's delete this");
                int noteId = todo.id;
                MessageDialog.showConfirmationDelete(context, model: model, noteId: noteId );
              },
              child: TodoCard(todo),
            ),
            background: Container(color: Colors.red),
          );
      }
    );
  }

Widget titleText(BuildContext context, String text) {
  return new Text(
      text,
      style: TextStyle(
        decoration: TextDecoration.underline,
        decorationColor: Theme.of(context).primaryColor,
        fontSize: 25,
      )
    );
}

Widget _snoozedText(BuildContext context, Todo todo) {
  if (todo.snoozed) {
      return new Text( "Snoozed for " + todo.snoozedDate.toString().substring(0, todo.snoozedDate.toString().length-7) ,
          style: TextStyle (color: Colors.yellow[900], fontSize: 15)); 
  }

  return new Text("");


}

void _settingModalBottomSheet(BuildContext context, Todo todo){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Padding(
            padding: EdgeInsets.all(10.0),
            child: new Wrap(
              children: <Widget>[
                new Center(
                  child: 
                    new Icon(
                      IconData(0xe801, fontFamily: 'note'),
                      color: !todo.snoozed ?
                             Theme.of(context).accentColor 
                             : Colors.yellow[900]
                    // new Text("Note:"),
                    )
                ),
                new Center(
                  child:
                  _snoozedText(context, todo)
                ),
                new Padding(
                  padding: EdgeInsets.all(2.0)
                ),
                new ListTile(
                            leading: new Text(""),
                            title: titleText(context, todo.title),
                            onTap: () => {}          
                          ),
                          new ListTile(
                            leading: new Text(""),
                            title: new Text(todo.content),
                            onTap: () => {},          
                          ),
              ],
          ),
          );
      }
    );
}

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (BuildContext context, Widget child, AppModel model) {
        Widget todoCards = model.todos.length > 0
            ? _buildListView(model)
            : _buildEmptyText(model);

        return todoCards;
      },
    );
  }
}
