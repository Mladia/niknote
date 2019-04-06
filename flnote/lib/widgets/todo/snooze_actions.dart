import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:niknote/scoped_models/app_model.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../.env.example.dart';
import '../helpers/message_dialog.dart';

class SnoozeActions extends StatefulWidget {
  final AppModel model;
  SnoozeActions(this.model);

  @override
  State<StatefulWidget> createState() {
    print("Create state is called");
    return _SnoozeActionsState();
  }
}

class _SnoozeActionsState extends State<SnoozeActions> {
  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;
  bool dateInfoFilled = false;

  @override
  void initState() {
    // widget.model.fetchTodos();
    print("init state in snozoe actions");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print("calling build method");
  return ScopedModelDescendant<AppModel>(
    builder: (BuildContext context, Widget child, AppModel model) {
      return Scaffold(
      appBar: AppBar(title: Text(Configure.AppName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Text('Format: "${formats[inputType].pattern}"'),
            Text("Choose a snooze time and date"),

            //
            // The widget.
            //
            DateTimePickerFormField(
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                  labelText: 'Date/Time', hasFloatingPlaceholder: false),
              onChanged: (dt) => setState(() { 
                date = dt;
                if (valid(dt)) {
                  date = dt;
                } else {
                  date = null;
                }
              }
              ),
            ),

            // Text('Date value: $date'),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              splashColor: Colors.blueGrey,
              onPressed: () async {
                if (date == null) {
                  //do nothing
                  print("Date is null, doing nothing");
                } else {
                  print(date);
                  // Scaffold.of(context)
                  //     .showSnackBar(SnackBar(content: Text("Setting snoozed date to " + date.toString())));
                  Navigator.pop(context, date);
                  //TODO: do we need 2?
                  // Navigator.pop(context);
                }
              },
              child: Text( date == null ? "Please choose a valid time and date" : "Snooze note" ),
            ),
          ],
        ),
      ));
    }
    );
      }

  void updateInputType({bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
    setState(() => inputType =
        date ? time ? InputType.both : InputType.date : InputType.time);
  }

  bool valid(DateTime date) {
    if (date == null)  {
      return false;
    }
    DateTime now = DateTime.now();
    print(now);
    if (date.isBefore(now)) {
      print("Date in the past");
      return false;
    }


    return true;
  }
}

