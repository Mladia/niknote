import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:http/http.dart' as http;
import 'package:niknote/models/Todo.dart';
import 'package:niknote/models/Priority.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/widgets/helpers/message_dialog.dart';
import 'package:niknote/widgets/helpers/confirm_dialog.dart';
import 'package:niknote/widgets/ui_elements/loading_modal.dart';
import 'package:niknote/widgets/form_fields/priority_form_field.dart';
import 'package:niknote/widgets/form_fields/toggle_form_field.dart';

class TodoEditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoEditorPageState();
  }
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'content': null,
    'priority': Priority.Low,
    'isDone': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildAppBar(AppModel model) {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Colors.blue,
      actions: <Widget>[
      ],
    );
  }


Future<http.Response> postRequest () async {

  String url = "http://192.168.2.38/server.php";
  String body = "cmd=get_notes";
  // final http.Response response = await http.post(url, body: body);

  http.post(url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: body
  ).then((http.Response response) {
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.contentLength}");
    // print(response.headers);
    // print(response.request);
    // print(response.body);

    final List <dynamic> todoListData = json.decode(response.body);

    if (todoListData == null) {
      print("Fetched notes are null");
      return;
    }
    todoListData.forEach( (dynamic todoData) {
      if (todoData == null) {
        print("null note");
        return;
      }
      
      final Todo todo = Todo (
        id: todoData['id'],
        title: todoData['title'],
        content: todoData['text'],
        snoozed: todoData['snoozed'],
        isDone: todoData["done"],
        snoozed_date: todoData['snoozed_date'],
        snoozed_time: todoData['snoozed_time'],
        tags: new List<String>.from( todoData['tags'])
      );
      print(todo.toString());
    });


  });
  }

  Widget _buildFloatingActionButton(AppModel model) {
    return FloatingActionButton(
      child: Icon(Icons.save),
      onPressed: () {
        print("Save is pressed");
        postRequest();

        if (!_formKey.currentState.validate()) {
          return;
        }

        _formKey.currentState.save();

        if (model.currentTodo != null && model.currentTodo.id != null) {
          model
              .updateTodo(
            _formData['title'],
            _formData['content'],
            _formData['priority'],
            _formData['isDone'],
          )
              .then((bool success) {
            if (success) {
              model.setCurrentTodo(null);

              Navigator.pop(context);
            } else {
              MessageDialog.show(context);
            }
          });
        } else {
          model
              .createTodo(
            _formData['title'],
            _formData['content'],
            _formData['priority'],
            _formData['isDone'],
          )
              .then((bool success) {
            if (success) {
              Navigator.pop(context);
            } else {
              MessageDialog.show(context);
            }
          });
        }
      },
    );
  }

  Widget _buildTitleField(Todo todo) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Title'),
      initialValue: todo != null ? todo.title : '',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter todo\'s title';
        }
      },
      onSaved: (value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildContentField(Todo todo) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Content'),
      initialValue: todo != null ? todo.content : '',
      maxLines: 5,
      onSaved: (value) {
        _formData['content'] = value;
      },
    );
  }

  Widget _buildOthers(Todo todo) {
    final bool isDone = todo != null && todo.isDone;
    //TODO: add snoozed
    final Priority priority = todo != null ? todo.priority : Priority.Low;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      ],
    );
  }

  Widget _buildForm(AppModel model) {
    Todo todo = model.currentTodo;

    _formData['title'] = todo != null ? todo.title : null;
    _formData['content'] = todo != null ? todo.content : null;
    _formData['priority'] = todo != null ? todo.priority : Priority.Low;
    _formData['isDone'] = todo != null ? todo.isDone : false;

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          _buildTitleField(todo),
          _buildContentField(todo),
          SizedBox(
            height: 12.0,
          ),
          _buildOthers(todo),
        ],
      ),
    );
  }

  Widget _buildPageContent(AppModel model) {
    return Scaffold(
      appBar: _buildAppBar(model),
      floatingActionButton: _buildFloatingActionButton(model),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: _buildForm(model),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (BuildContext context, Widget child, AppModel model) {
        Stack mainStack = Stack(
          children: <Widget>[
            _buildPageContent(model),
          ],
        );

        if (model.isLoading) {
          mainStack.children.add(LoadingModal());
        }

        return mainStack;
      },
    );
  }
}
