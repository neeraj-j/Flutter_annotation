// Implements the Json/coco file read and write
import 'package:flutter/material.dart';
//import 'dart:io';
import 'dart:html' ;
import 'dart:html' as html;
import 'dart:async';
//import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';
import 'dart:convert';

// Coco file strcture for decoding
// Todo add coco structure
var coco; // Glbal variable for holding coco json data
html.File _jsonFile; 
class CocoFile {
  // Todo: add info and licences
  final Map info;
  final licenses;
  final List images ;
  final List annotations ;
  final List categories ;

  CocoFile({this.info, this.licenses, this.images, this.annotations, this.categories});
  
  factory CocoFile.fromJson(Map<String, dynamic> json) {
    return CocoFile(
      info: json['info'],
      licenses: json['licenses'],
      images: json['images'],
      annotations: json['annotations'],
      categories: json['categories'],
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'info': info,
      'licenses': licenses,
      'images': images,
      'annotations': annotations,
      'categories': categories,
    };
}


var _cocoImage = { 
  "file_name" : String, //list of box icons
  "height": int, //icon and bottom point
  "width": int, //Top and bottom point
  "id" : int,
};


var _cocoAnnotation = { 
  "segmentation" : List<List<int>>.empty(growable: true), //list of box icons
  "num_keypoints": int, //icon and bottom point
  "keypoints": List<int>.empty(growable: true), //Top and bottom point
  "area": double,
  "image_id": int,
  "box": List<double>.empty(growable: true),
  "category_id": int,
  "id" : int,
};

// Read coco file
void readCocoFile() async {
    _jsonFile = await FilePicker.getFile();
	final Completer<String> bytesFile = Completer<String>();
    final html.FileReader reader = html.FileReader();
    reader.onLoad.listen((event) => bytesFile.complete(reader.result));
    reader.readAsText(_jsonFile);
    String jStr =  await bytesFile.future;
	coco = CocoFile.fromJson(jsonDecode(jStr));
	print("Json Read");
	// readd file File('file.txt').readAsString()
	// File(filename).writeAsString('some content')
}

// srite coco file
void writeCocoFile() async {
   // prepare
  final bytes = utf8.encode(jsonEncode(coco));
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
	..href = url
	..style.display = 'none'
	..download = _jsonFile.name;
  html.document.body.children.add(anchor);

  // download
  anchor.click();

  // cleanup
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

