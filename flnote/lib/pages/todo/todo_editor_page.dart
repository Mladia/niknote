
import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';
import 'package:niknote/widgets/todo/snooze_actions.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/models/Todo.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/widgets/helpers/message_dialog.dart';
import 'package:niknote/widgets/ui_elements/loading_modal.dart';
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
    'isDone': false,
    'snoozed' : false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildAppBar(AppModel model) {
    return AppBar(
      title: Text(Configure.AppName),
      backgroundColor: Theme.of(context).primaryColor,
      actions: <Widget>[
      ],
    );
  }


  _pressedSave (AppModel model, BuildContext context) async {
    bool rvalue = false;;
    print("Save is pressed");

    if (!_formKey.currentState.validate()) {
        return false;
      }

    _formKey.currentState.save();
    final String title = _formData['title'];
    final String content = _formData['content'];

    if (_formData['snoozed']) {
      print("showing options");
      // final DateTime snoozedDate = await Navigator.pushNamed(context, '/snooze_actions');
      final DateTime snoozedDate = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SnoozeActions(model))
      );

      
      if (model.currentTodo != null && model.currentTodo.id != null) {
        rvalue = await model
            .updateTodo(
              title,
              content,
              snoozedDate
          );
      } else {
        rvalue = await model
            .createTodo(
              title,
              content,
          snoozedDate
        );
      }

    } else {
      print("not snoozed");
      if (model.currentTodo != null && model.currentTodo.id != null) {
        rvalue = await model
            .updateTodo(
              title,
              content,
          null 
          );
      } else {
        rvalue = await model
            .createTodo(
              title,
              content,
          null
        );
      }
    }
    return rvalue;
  }

  Widget _buildFloatingActionButton(AppModel model, BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.save),
      onPressed: () async {

        bool todoActionSuccess = await _pressedSave(model, context);
        if (!todoActionSuccess) {
          //bad input
          print("bad input");
          MessageDialog.show(context);
          return;
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildTitleField(Todo todo) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Title',
        fillColor: Theme.of(context).highlightColor),
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
      decoration: InputDecoration(
        labelText: 'Content',
        fillColor: Theme.of(context).primaryColor),
      initialValue: todo != null ? todo.content : '',
      maxLines: 5,
      onSaved: (value) {
        _formData['content'] = value;
      },
    );
  }

  Widget _buildOthers(Todo todo) {
    final bool snoozed = todo !=null && todo.snoozed;
    if (todo != null) {
      if (todo.isDone) {
        return Row();
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[

        Text("Snooze:   "),
        ToggleFormField(
          initialValue: snoozed,
          hint: "Snooze",
          onSaved: (bool value) {
            _formData['snoozed'] = value;
          },
          color: Colors.yellow
        ),
        //TODO: add image
        // GestureDetector(
        //   onTap: (){
        //     print("1You pressed the image");
        //     //Change image
        //     //notify to change the image asset
        // },
        //   onLongPress: (){
        //     print("You long pressed the image");
        //     //set_state
        //   },
        //   child: 
        //      Image.asset( 
        //         'assets/current.jpg', 
        //        fit: BoxFit.fitWidth
        //     )
        // )
      ],
    );
  }

  Widget _buildSnoozeText(Todo todo) {
    if (todo == null) {
      return Text("");
    }

    if (todo.snoozed) {
      if (todo.snoozedDate != null) {
        int lenght = todo.snoozedDate.toString().length;
        return Text( "Note is snoozed for " + todo.snoozedDate.toString().substring(0, lenght-7) ,
          style: TextStyle (color: Colors.yellow[900], fontSize: 15),
          
          );
      } else {
        print("snooze date is null");
        return Text("");
      }
    } else {
      return Text("");
    }
  }

  Widget _buildForm(AppModel model) {
    Todo todo = model.currentTodo;
    //TODO: set current image

    _formData['title'] = todo != null ? todo.title : null;
    _formData['content'] = todo != null ? todo.content : null;
    _formData['isDone'] = todo != null ? todo.isDone : false;
    _formData['snoozed'] = todo != null? todo.snoozed : false;

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          _buildSnoozeText(todo),
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

  Widget _buildPageContent(AppModel model, BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(model),
      floatingActionButton: _buildFloatingActionButton(model, context),
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
            _buildPageContent(model, context),
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
