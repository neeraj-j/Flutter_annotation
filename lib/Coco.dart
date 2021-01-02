// Implements the Json/coco file read and write
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import "Globals.dart";
import "Common.dart";

// Coco file strcture for decoding
//CocoFile coco; // Glbal variable for holding coco json data
List<dynamic> coco=[];
// Coco indexing
var images = new Map(); // Image id to image name binding ??
var imgToAnns = new Map(); // Image id to annotations list binding
List<Map> annList = List.empty();
var anns = new Map(); // annotation id to annotations list binding
int cocoImgIdx = -1;

class CocoFile {
  // Todo: add info and licences
  final Map info;
  final licenses;
  final List images;
  final List annotations;
  final List categories;

  CocoFile(
      {this.info,
      this.licenses,
      this.images,
      this.annotations,
      this.categories});

  factory CocoFile.fromJson(Map<String, dynamic> json) {
    return CocoFile(
      info: json['info'],
      licenses: json['licenses'],
      images: json['images'],
      annotations: json['annotations'],
      categories: json['categories'],
    );
  }

  Map<String, dynamic> toJson() => {
        'info': info,
        'licenses': licenses,
        'images': images,
        'annotations': annotations, // Todo: change it
        'categories': categories,
      };
}

var _cocoImage = {
  "file_name": String, //list of box icons
  "height": int, //icon and bottom point
  "width": int, //Top and bottom point
  "id": int,
};

var _cocoAnnotation = {
  "segmentation": List<List<int>>.empty(growable: true), //list of box icons
  "num_keypoints": int, //icon and bottom point
  "keypoints": List<int>.empty(growable: true), //Top and bottom point
  "area": double,
  "image_id": int,
  "box": List<double>.empty(growable: true),
  "category_id": int,
  "id": int,
};

// fetch coco file from server
Future<void> readCocoFile() async {
  Fluttertoast.showToast(
      msg: "Waiting for Data to load ",
      timeInSecForIosWeb: 5,
      gravity: ToastGravity.CENTER);
  final response = await http.get('http://192.168.1.3:9000/coco');
  //final response =  await http.get('https://jsonplaceholder.typicode.com/albums/1');
  if (response.statusCode == 200) {
	// for coco
    //coco = CocoFile.fromJson(jsonDecode(response.body));
    coco = jsonDecode(response.body);
    print(jsonDecode(response.body).runtimeType);
   // indexCoco();
    Fluttertoast.showToast(
        msg: "Data loaded !!! ",
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER);
  } else {
    print('Failed to load coco file');
    Fluttertoast.showToast(
        msg: "Failed to load file !!! ",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER);
  }
}

Future<void> writeCocoFile() async {
  if (!dirtyBit) {
    return;
  }
  updateCoco();
  final http.Response response = await http.put(
    'http://192.168.1.3:9000/cocosave',
    headers: <String, String>{
      // "Accept": "application/json",
      // 'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    //body: jsonEncode(<String,String>{"a":"b"}),
    body: jsonEncode(coco),
  );
  //final response =  await http.get('https://jsonplaceholder.typicode.com/albums/1');
  if (response.statusCode == 200) {
    dirtyBit = false;
    Fluttertoast.showToast(
        msg: "Data Saved !!! ",
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER);
  } else {
    Fluttertoast.showToast(
        msg: "Error: Failed to save Data",
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER);
  }
}


void updateCoco() {
  if (cocoImgIdx<0){return;}
  for (int i = 0; i < boxList.length; i++) {
    if (!boxList[i]["changed"][0] && !boxList[i]["changed"][1]) {
      continue;
    }
    int annId = boxList[i]["annId"][0];
    // Todo: id annId is -1, its a new box handle it
    // Find ann id in coco annotations
    for (int j = 0; j < coco[cocoImgIdx]['annotations'].length; j++) {
      if (annId != coco[cocoImgIdx]['annotations'][j]["id"]) {
        continue;
      }
      // update box it it is changed
      if (boxList[i]["changed"][0]) {
        Offset top = getBoxCoords(i, 0);
        Offset bot = getBoxCoords(i, 1);
        // box is deleted reove annotations go t nex box
        if (top == null || bot == null) {
          coco[cocoImgIdx]['annotations'].removeAt(j);
          break;
        }
        // check which one is tl annd bright
        if (top.dx > bot.dx || top.dy > bot.dy) {
          //Display toast and return
          print("Wrong top left point");
          return;
        }
        print("Updating box $i");
        top = top.scale(imgScale, imgScale);
        bot = bot.scale(imgScale, imgScale);
        coco[cocoImgIdx]['annotations'][j]["bbox"][0] = top.dx;
        coco[cocoImgIdx]['annotations'][j]["bbox"][1] = top.dy;
        coco[cocoImgIdx]['annotations'][j]["bbox"][2] = bot.dx - top.dx;
        coco[cocoImgIdx]['annotations'][j]["bbox"][3] = bot.dy - top.dy;
      }
      // update keypooint if it is changed
      if (boxList[i]["changed"][1]) {
        print("Updating Keypoints");
        for (var k = 0; k < 17; k++) {
          // skeleton is from 1-17 so subtract 1
          Offset kp1 = getKpCoords(i, k);
          // it is deleted make is 0
          if (kp1 == null) {
            // set to 0
            coco[cocoImgIdx]['annotations'][j]['keypoints'][k][0] = 0;
            coco[cocoImgIdx]['annotations'][j]['keypoints'][k][1] = 0;
          } else {
            // keep visibility same
            kp1 = kp1.scale(imgScale, imgScale);
            coco[cocoImgIdx]['annotations'][j]['keypoints'][k][0] = kp1.dx.round();
            coco[cocoImgIdx]['annotations'][j]['keypoints'][k][1] = kp1.dy.round();
			//print("$kp1");
          }
        }
      }
      // we have found the annid, no nneed to check rest annnids
      break;
    } // annotations for loop
  }
}


// Delete image from server
Future<void> deleteImage(String imName) async {
  String url = 'http://192.168.1.3:9000/delete/' + imName;
  final response = await http.delete(url);
  //final response =  await http.get('https://jsonplaceholder.typicode.com/albums/1');
  if (response.statusCode == 200) {
    Fluttertoast.showToast(
        msg: "Image Deleted !!! ",
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER);
  } else {
    Fluttertoast.showToast(
        msg: "Delete Failed!!! ",
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER);
    print('Failed to load coco file');
  }
}

