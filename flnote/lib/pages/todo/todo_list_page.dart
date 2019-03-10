import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/models/filter.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/widgets/helpers/confirm_dialog.dart';
import 'package:niknote/widgets/ui_elements/loading_modal.dart';
import 'package:niknote/widgets/todo/todo_list_view.dart';
import 'package:niknote/widgets/todo/shortcuts_enabled_todo_fab.dart';

class TodoListPage extends StatefulWidget {
  final AppModel model;

  TodoListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _TodoListPageState();
  }
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    widget.model.fetchTodos();

    super.initState();
  }

  Widget _buildAppBar(AppModel model) {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Colors.blue,
      actions: <Widget>[
      ],
    );
  }

  Widget _buildFloatingActionButton(AppModel model) {
    if (model.settings.isShortcutsEnabled) {
      return ShortcutsEnabledTodoFab(model);
    } else {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          model.setCurrentTodo(null);

          Navigator.pushNamed(context, '/editor');
        },
      );
    }
  }

  Widget _buildAllFlatButton(AppModel model) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.all_inclusive,
              color: model.filter == Filter.All ? Colors.white : Colors.black,
            ),
            Text(
              'All',
              style: TextStyle(
                color: model.filter == Filter.All ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        model.applyFilter(Filter.All);
      },
    );
  }

  Widget _buildDoneFlatButton(AppModel model) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check,
              color: model.filter == Filter.Done ? Colors.white : Colors.black,
            ),
            Text(
              'Done',
              style: TextStyle(
                color:
                    model.filter == Filter.Done ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        model.applyFilter(Filter.Done);
      },
    );
  }

  Widget _buildNotDoneFlatButton(AppModel model) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_box_outline_blank,
              color:
                  model.filter == Filter.NotDone ? Colors.white : Colors.black,
            ),
            Text(
              'Not Done',
              style: TextStyle(
                color: model.filter == Filter.NotDone
                    ? Colors.white
                    : Colors.black,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        model.applyFilter(Filter.NotDone);
      },
    );
  }

  Widget _buildBottomAppBar(AppModel model) {
    return null;
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // SizedBox(),
          _buildAllFlatButton(model),
          _buildDoneFlatButton(model),
          _buildNotDoneFlatButton(model),
          // SizedBox(
          //   width: 80.0,
          // ),
        ],
      ),
      color: Colors.blue,
      shape: CircularNotchedRectangle(),
    );
  }

  Widget _buildPageContent(AppModel model) {
    return Scaffold(
      appBar: _buildAppBar(model),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _buildFloatingActionButton(model),
      // bottomNavigationBar: _buildBottomAppBar(model),
      body: TodoListView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (BuildContext context, Widget child, AppModel model) {
        Stack stack = Stack(
          children: <Widget>[
            _buildPageContent(model),
          ],
        );

        if (model.isLoading) {
          stack.children.add(LoadingModal());
        }

        return stack;
      },
    );
  }
}
