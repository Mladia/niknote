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
    String formattedDate;
    String formattedTime;
    if (snoozedDate != null) {
      String month;
      if (snoozedDate.month < 10) {
        month = "0" + snoozedDate.month.toString();
      } else {
        month = snoozedDate.month.toString();
      }

      String day;
      if (snoozedDate.day < 10) {
        day = "0" + snoozedDate.day.toString();
      } else {
        day = snoozedDate.day.toString();
      }

      String hour; 
      if (snoozedDate.hour < 10) {
        hour = "0" + snoozedDate.hour.toString();
      } else {
        hour = snoozedDate.hour.toString();
      }

      String minute;
      if (snoozedDate.minute < 10) {
        minute = "0" + snoozedDate.minute.toString();
      } else {
        minute = snoozedDate.minute.toString();
      }



      formattedDate = "${snoozedDate.year}-$month-$day";
      formattedTime = "$hour:$minute";
      // print(formattedDate + " at " + formattedTime);
    }
    return  json.encode({
      'id': id,
      'title': title,
      'text': content,
      'done': isDone == null ? false : isDone,
      'image': image == null ? false : image,
      'snoozed': snoozed == null ? false : snoozed,
      'snoozed_time' :formattedTime == null ? "" : formattedTime,
      'snoozed_date' : formattedDate == null ? "" : formattedDate,
      'tags' : tags == null ? [] : tags
    });
  }
}
