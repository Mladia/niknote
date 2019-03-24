import 'dart:convert';

import 'package:flutter/material.dart';


class Todo {
  final int id;
  final String title;
  final String content;
  bool isDone = false;
  bool snoozed = false;
  DateTime snoozedDate;
  bool image = false;
  final List<String> tags;

  Todo({
    @required this.id,
    @required this.title,
    this.content,
    this.isDone,
    this.snoozed,
    this.snoozedDate,
    this.tags,
    this.image
  });

  @override
  String toString() {
    return "Note: $id, title: " + this.title + " ,snoozed:" + snoozed.toString() + ", " + snoozedDate.toString();
  }

  String toJson (){
    //TODO: check to see if it works
    String formattedDate;
    String formattedTime;
    if (snoozedDate != null) {
      formattedDate = "${snoozedDate.year}-${snoozedDate.month}-${snoozedDate.day}";
      formattedTime = "${snoozedDate.hour}:${snoozedDate.minute}" + (snoozedDate.minute < 10 ? "0" + snoozedDate.minute.toString() : snoozedDate.minute ) ;
      print(formattedDate + " at " + formattedTime);
    }
    return  json.encode({
      'id': id,
      'title': title,
      'text': content,
      'done': isDone == null ? false : isDone,
      'image': image == null ? false : image,
      'snoozed': snoozed == null ? false : snoozed,
      'snoozedTime' :formattedTime == null ? "" : formattedTime,
      'snoozedDate' : formattedDate == null ? "" : formattedDate,
      'tags' : tags == null ? [] : tags
    });
  }
}
