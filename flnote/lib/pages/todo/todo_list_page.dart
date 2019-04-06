import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';
import 'package:niknote/models/timers.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/models/filter.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/widgets/ui_elements/loading_modal.dart';
import 'package:niknote/widgets/todo/todo_list_view.dart';

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

    Timers timerSnoozed = Timers(model: widget.model, context: context);
    timerSnoozed.periodical();

    super.initState();
  }

  Widget _buildAppBar(AppModel model) {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Theme.of(context).primaryColor,
      actions: <Widget>[
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child:
            Icon(
           model.device == null ?
              Icons.bluetooth
              : Icons.bluetooth_connected,
        )),
        Padding(padding: EdgeInsets.all(5.0) ,),
        IconButton(
          // icon: Icon(Icons.compare_arrows),
          icon: Icon(IconData(0xe800, fontFamily: 'reload')),
          onPressed: () {
            model.fetchTodos();
          },
        ),
        // PopupMenuButton<String>(
        //   onSelected: (String choice) {
        //     switch (choice) {
        //       case 'Settings':
        //         Navigator.pushNamed(context, '/settings');
        //     }
        //   },
        //   itemBuilder: (BuildContext context) {
        //     return [
        //       PopupMenuItem<String>(
        //         value: 'Settings',
        //         child: Text('Settings'),
        //       )
        //     ];
        //   },
        // ),
      ],
    );
  }

  Widget _buildFloatingActionButton(AppModel model) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          model.setCurrentTodo(null);

          Navigator.pushNamed(context, '/editor');
        },
      );
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
                  model.filter == Filter.Current ? Colors.white : Colors.black,
            ),
            Text(
              'Running',
              style: TextStyle(
                color: model.filter == Filter.Current
                    ? Colors.white
                    : Colors.black,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        model.applyFilter(Filter.Current);
      },
    );
  }
  Widget _buildSnoozedFlatButton(AppModel model) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.timer,
              color:
                  model.filter == Filter.Snoozed? Colors.white : Colors.black,
            ),
            Text(
              'Snoozed',
              style: TextStyle(
                color: model.filter == Filter.Snoozed
                    ? Colors.white
                    : Colors.black,
              ),
            )
          ],
        ),
      ),
      onPressed: () {
        model.applyFilter(Filter.Snoozed);
      },
    );
  }




  Widget _buildBottomAppBar(AppModel model) {
    
    // return null;

    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // SizedBox(),
          _buildNotDoneFlatButton(model),
          _buildSnoozedFlatButton(model),
          _buildDoneFlatButton(model),
          _buildAllFlatButton(model),
          // SizedBox(
          //   width: 80.0,
          // ),
        ],
      ),
      color: Theme.of(context).primaryColor,
      shape: CircularNotchedRectangle(),
    );
  }

  Widget _buildPageContent(AppModel model) {
    return Scaffold(
      appBar: _buildAppBar(model),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(model),
      bottomNavigationBar: _buildBottomAppBar(model),
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
