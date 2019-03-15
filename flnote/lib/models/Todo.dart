import 'dart:convert';

import 'package:flutter/material.dart';


class Todo {
  final int id;
  final String title;
  final String content;
  final bool isDone;
  final bool snoozed;
  final String snoozedTime;
  final String snoozedDate;
  final bool image;
  final List<String> tags;

  Todo({
    @required this.id,
    @required this.title,
    this.content,
    this.isDone = false,
    this.snoozed = false,
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
    return  json.encode({
      'id': id,
      'title': title,
      'text': content,
      'done': isDone,
      'image': image,
      'snoozed': snoozed,
      'snoozedTime' : snoozedTime == null ? "" : snoozedTime,
      'snoozedDate' : snoozedDate == null ? "" : snoozedDate,
      'tags' : tags
    });
  }
}
