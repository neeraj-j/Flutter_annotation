//import 'dart:async';
//import 'dart:html';
import 'package:flutter/material.dart';
//import 'dart:html' as html;
import 'package:flutter_web/CustomAppBar.dart';
//import 'dart:io';
import 'package:path_provider/path_provider.dart'; 
import 'dart:html';

void main() {
  window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: CustomAppBar());
  }

}
