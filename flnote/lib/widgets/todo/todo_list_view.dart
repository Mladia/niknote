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
    //TODO: change text and image
    switch (model.filter) {
      case Filter.All:
        emptyText = 'This is boring here. \r\nCreate a todo to make it crowd.';
        break;

      case Filter.Done:
        emptyText =
            'This is boring here. \r\nCreate a Done todo to make it crowd.';
        break;

      case Filter.NotDone:
        emptyText =
            'This is boring here. \r\nCreate a Not Done todo to make it crowd.';
        break;
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
        // print("showing todo " + todo.title);

        //TODO: fix this
        return Dismissible(
            key: Key(todo.id.toString()),
            onDismissed: (DismissDirection dismissDirection) {
              if (dismissDirection == DismissDirection.startToEnd) {
                print("Dismissing start to end");
                model.toggleDone(todo.id);
              } else if (dismissDirection == DismissDirection.endToStart) {
                //TODO: just delete maybe
                print("Snooze this note");
              } else {
                print("not nown dismissable");
              } 
            }, 
            // child: TodoCard(todo), background: Container(color: Colors.red,),);


            child: GestureDetector (
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
