import 'dart:convert';

import 'package:flutter/material.dart';


class Todo {
  final int id;
  final String title;
  final String content;
  bool isDone = false;
  bool snoozed = false;
  String snoozedTime;
  String snoozedDate;
  bool image = false;
  final List<String> tags;

  Todo({
    @required this.id,
    @required this.title,
    this.content,
    this.isDone,
    this.snoozed,
    this.snoozedTime,
    this.snoozedDate,
    this.tags,
    this.image
  });

  @override
  String toString() {
    // TODO: implement toString
    return "Note: $id, title: " + this.title;
  }

  // Map <String, dynamic> toJson (){
  String toJson (){

    String done;
    return  json.encode({
      'id': id,
      'title': title,
      'text': content,
      'done': isDone == null ? false : isDone,
      'image': image == null ? false : image,
      'snoozed': snoozed == null ? false : snoozed,
      'snoozedTime' : snoozedTime == null ? "" : snoozedTime,
      'snoozedDate' : snoozedDate == null ? "" : snoozedDate,
      'tags' : tags == null ? [] : tags
    });
  }
}
