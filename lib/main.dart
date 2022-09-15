import 'package:flutter/material.dart';
import 'package:flutter_web/CustomAppBar.dart';
import 'package:path_provider/path_provider.dart'; 
import 'dart:html';
import 'auth.dart';

void main() {
  window.document.onContextMenu.listen((evt) => evt.preventDefault());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    //return MaterialApp(debugShowCheckedModeBanner: false, home: CustomAppBar());
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }

}
