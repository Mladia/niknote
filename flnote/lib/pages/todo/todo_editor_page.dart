
import 'package:flutter/material.dart';
import 'package:niknote/.env.example.dart';

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



  Widget _buildFloatingActionButton(AppModel model, BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.save),
      onPressed: () async {
        print("Save is pressed");

      if (!_formKey.currentState.validate()) {
          return;
        }

        _formKey.currentState.save();
        bool todoActionSuccess = false;

        if (model.currentTodo != null && model.currentTodo.id != null) {
          todoActionSuccess = await model
              .updateTodo(
            _formData['title'],
            _formData['content']);
        } else {
          todoActionSuccess = await model
              .createTodo(
            _formData['title'],
            _formData['content'],
            _formData['isDone'],
          );
        }

        if (!todoActionSuccess) {
          //bad input
          print("bad input");
          MessageDialog.show(context);
          return;
        } 

        if (_formData['snoozed']) {
          print("showing options");
          Navigator.pushNamed(context, '/snooze_actions');
          print("Done here");
        } else {
          Navigator.pop(context);
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
    final bool snoozed = todo !=null && todo.snoozed;
    final bool image = todo != null && todo.image;
    if (todo == null) {
      return Row();
    }
    if (todo.isDone) {
      return Row();
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
        return Text("Note is snoozed for " + todo.snoozedDate.toString() ,
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
