import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/models/Todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;

  TodoCard(this.todo);

  @override
  Widget build(BuildContext context) {
    // print("Showing notes");
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, AppModel model) {
        return Card(
          child: Row(
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: todo.snoozed != null ? (todo.snoozed ? Colors.yellow : Colors.lightGreen) 
                                                : Colors.lightGreen,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(4.0),
                    bottomLeft: const Radius.circular(4.0),
                  ),
                ),
                width: 40.0,
                height: 80.0,
                child: todo.isDone
                    ? IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          model.toggleDone(todo.id);
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.check_box_outline_blank),
                        onPressed: () {
                          model.toggleDone(todo.id);
                        },
                      ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    todo.title,
                    style: TextStyle(
                        fontSize: 24.0,
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  model.setCurrentTodo(todo);

                  Navigator.pushNamed(context, '/editor');
                },
              )
            ],
          ),
        );
      },
    );
  }
}
