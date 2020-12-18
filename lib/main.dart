//import 'dart:async';
//import 'dart:html';
import 'package:flutter/material.dart';
//import 'dart:html' as html;
import 'package:flutter_web/CustomAppBar.dart';
//import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: CustomAppBar());
  }
}



