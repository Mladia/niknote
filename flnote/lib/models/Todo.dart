import 'package:flutter/material.dart';
import 'package:niknote/models/Priority.dart';


class Todo {
  final int id;
  final String title;
  final String content;
  final Priority priority;
  final bool isDone;
  final bool snoozed;
  final String snoozed_time;
  final String snoozed_date;
  final List<String> tags;

  Todo({
    @required this.id,
    @required this.title,
    this.content,
    this.priority = Priority.Low,
    this.isDone = false,
    this.snoozed = false,
    this.snoozed_time,
    this.snoozed_date, 
    this.tags
  });

  @override
  String toString() {
    // TODO: implement toString
    return "Note: $id, title: " + this.title;
  }
}
