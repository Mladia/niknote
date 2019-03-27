import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:niknote/models/Todo.dart';
import 'package:niknote/scoped_models/connected_model.dart';
import 'package:niknote/widgets/helpers/message_dialog.dart';

import '../scoped_models/app_model.dart';
import 'Todo.dart';
class Timers {
  AppModel model;
  Timer timer;
  bool showing = false;
  static const duration = const Duration(seconds: 40);
  BuildContext context;

  Timers ({
    @required this.model,
    @required this.context
  });
  //this function gets called every minutes and cehcks for notes to be unsnoozed
  void checkSnoozed () {
      if (showing) {
        return;
      }
      showing = true;

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
      print("Checking snoozed, " + formattedDate);


     List snoozedList = model.snoozedNotes();

     Iterator todosIt = snoozedList.iterator;
     while (todosIt.moveNext()) {
        _actionSnooze(todosIt.current);
     }

      //show for every note dialog
      showing = false;
  }

  void periodical(){
      new Future.delayed(const Duration(seconds: 10), () => checkSnoozed() );

      new Timer.periodic(duration, (Timer t) => checkSnoozed() );
  }

  void _actionSnooze(Todo todo) {
    print("Checking ");
    print(todo.toJson());
    //show dialog

    DateTime now;
    // now = DateTime.now();
    now = DateTime(2020);
    if(now.isAfter(todo.snoozedDate)) {
      print("showing notification");
      MessageDialog.show(context , title: "Note is here!", message: todo.title);
      //unsnooze event
      // model.unsnoozeNote(todo.id);
    }


  }
}