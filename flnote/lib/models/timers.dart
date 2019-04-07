import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:niknote/models/Todo.dart';
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

  Future _actionSnooze(Todo todo) async {
    print("Checking ");
    print(todo.toJson());
    //show dialog

    DateTime now;
    now = DateTime.now();
    print("now is " + now.toString());
    try {
      if(now.isAfter(todo.snoozedDate)) {
        print("showing notification");
        // bool value = MessageDialog.show(context , title: "Note is here!", message: todo.title);
        model.vibrationPattern();
        MessageDialog.showSnoozeOptions(context , unsnoozeNote: model.unsnoozeNote, todo: todo);
      } else {
        print("Not unsnoozing");
      }
    } catch (Error){
      print("ERROR: Not correct date...");
    }
      
  }

}