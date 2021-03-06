import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/pages/settings/settings_page.dart';
import 'package:niknote/pages/auth/auth_page.dart';
import 'package:niknote/pages/todo/todo_editor_page.dart';
import 'package:niknote/pages/todo/todo_list_page.dart';

import 'widgets/todo/snooze_actions.dart';


void main() async {

  runApp(TodoApp());
}

class TodoApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoAppState();
  }
}


class _TodoAppState extends State<TodoApp> {
  AppModel _model;
  bool _isAuthenticated = true;

  @override
  void initState() {
    print("initState TodoAppState");
    _model = AppModel();

    _model.loadSettings();

    print("User subject");


    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return ScopedModel<AppModel>(
      model: _model,
      child: MaterialApp(
        title: Configure.AppName,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (BuildContext context) =>
              TodoListPage(_model),
          '/editor': (BuildContext context) =>
              TodoEditorPage(),
          '/register': (BuildContext context) =>
              TodoListPage(_model),
          '/settings': (BuildContext context) =>
               //BluetoothSettings(),
              SettingsPage(_model),
          '/snooze_actions': (BuildContext context) =>
              SnoozeActions(_model),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) =>
                _isAuthenticated ? TodoListPage(_model) : AuthPage(),
          );
        },
        theme: ThemeData(
          accentColor: Colors.green[700],
          primaryColor: Colors.green[300],
          highlightColor: Colors.green[100],
          cardColor: Colors.green[50],
          hintColor: Colors.green[600],
          brightness: Brightness.light,
        )
      ),
    );
  }
}
