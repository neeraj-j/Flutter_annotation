// Implements REST api for getting and setting data from server 
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "Globals.dart";
import 'dart:typed_data';
import "Common.dart";

//String host = "http://122.172.144.91:9000";
//String host = "http://192.168.1.3:9000";
String user = "";
// Edit mode =0; verify mode =1
int mode=0;

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

// writing 1 record at a time to db
Future<void> writeCocoFile() async {
  //if (!dirtyBit) {
  //  return;
  //}
  dirtyBit = false;
  String host = "http://"+user+":9000";
  // update flies annotation record
  List annots = updateCoco(currImgIdx);
  if (annots.isEmpty) {return;}
  String command;
  if (mode ==0){
	command =  "cocosave";
  } else if (mode ==1){
	command =  "verify";
  }else{
	print("mode : $mode");
  }
  // we dont want to sendd them back
  final http.Response response = await http.put(
    host+'/$command/$workerId',
    headers: <String, String>{
      // "Accept": "application/json",
      // 'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    //body: jsonEncode(<String,String>{"a":"b"}),
    body: jsonEncode(annots),
  );
  //final response =  await http.get('https://jsonplaceholder.typicode.com/albums/1');
  if (response.statusCode == 200) {
    toast("Data Saved !!! ");
  } else {
    toast("Error: Failed to save Data");
  }
}


List updateCoco(fidx) {
  List anns=[];
  Map ann={};
  bool _changed=false;
  // If no change then just send the ann id
  ann["id"] = boxList[0]["annId"][0];
  for (int i = 0; i < boxList.length; i++) {
    if (!boxList[i]["changed"][0] && !boxList[i]["changed"][1]) {
      continue;
    }
    int annId = boxList[i]["annId"][0];
    // Todo: id annId is -1, its a new box handle it
    // Find ann id in coco annotations
    for (int j = 0; j < files[fidx]['annotations'].length; j++) {
      if (annId != files[fidx]['annotations'][j]["id"]) {
        continue;
      }
      // update box it it is changed
      if (boxList[i]["changed"][0]) {
		_changed = true;
        Offset top = getBoxCoords(i, 0);
        Offset bot = getBoxCoords(i, 1);
        // box is deleted reove annotations go t nex box
        if (top == null || bot == null) {
		  files[fidx]['annotations'][j]["bbox"] = [0,0,0,0];
        }else{
		  // check which one is tl annd bright
		  if (top.dx > bot.dx || top.dy > bot.dy) {
			//Display toast and return
			toast("Wrong top left point !!! ");
			return [];
		  }
		  //print("Updating box $i");
		  top = top.scale(imgScale, imgScale);
		  bot = bot.scale(imgScale, imgScale);
		  files[fidx]['annotations'][j]["bbox"][0] = top.dx;
		  files[fidx]['annotations'][j]["bbox"][1] = top.dy;
		  files[fidx]['annotations'][j]["bbox"][2] = bot.dx - top.dx;
		  files[fidx]['annotations'][j]["bbox"][3] = bot.dy - top.dy;
		  }
      }
      // update keypooint if it is changed
      if (boxList[i]["changed"][1]) {
		_changed = true;
        //print("Updating Keypoints");
        for (var k = 0; k < 17; k++) {
          // skeleton is from 1-17 so subtract 1
          Offset kp1 = getKpCoords(i, k);
          // it is deleted make is 0
          if (kp1 == null) {
            // set to 0
            files[fidx]['annotations'][j]['keypoints'][k*3] = 0;
            files[fidx]['annotations'][j]['keypoints'][(k*3)+1] = 0;
          } else {
            // keep visibility same
            kp1 = kp1.scale(imgScale, imgScale);
            files[fidx]['annotations'][j]['keypoints'][k*3] = kp1.dx.round();
            files[fidx]['annotations'][j]['keypoints'][(k*3)+1] = kp1.dy.round();
			//print("$kp1");
          }
        }
      }
      // we have found the annid, no nneed to check rest annnids
      break;
    } // annotations for loop
  }
  if (_changed){
	return files[fidx]["annotations"];
  }else{
	ann['bbox'] = [];
	ann['keypoints'] = [];
	anns.add(ann);
	
	return anns; }
}


// Delete image from server and coco list
Future<void> deleteImage(String imName) async {
  // delte from coco list
  String host = "http://"+user+":9000";
  String url = host+'/delete/' + imName;
  final response = await http.delete(url);
  //final response =  await http.get('https://jsonplaceholder.typicode.com/albums/1');
  if (response.statusCode == 200) {
    toast("Image Deleted !!! ");
  } else {
    toast("Error: Delete Failed!!! ");
  }
}

// get the list of file names 
Future <List> getFileList() async{
  if (files.isNotEmpty) {return files;}
  String command;
  if (mode ==0){
	command =  "datalist";
  } else if (mode ==1){
	command =  "verilist";
  }else{
	print("mode : $mode");
  }
  toast("Loading Data ...");
  String host = "http://"+user+":9000";
  final response =  await http.get(host+'/$command/$workerId');
  if (response.statusCode == 200) {
    //print( jsonDecode(response.body));
    return jsonDecode(response.body);
  } else {
	toast("Failed to get file Names");
  }
  return [];
}

// get image by name 
Future<Uint8List> getImage(int idx) async {
  if (idx<0){return null;}
  if (files[idx].containsKey("bytes")){return files[idx]["bytes"];}
  String host = "http://"+user+":9000";
  String url =host+'/images/'+files[idx]['name'] ;
  Map<String, String> requestHeaders = {
       'Accept': 'application/json; charset=utf-8',
     };
  final response =  await http.get(url, headers: requestHeaders);
  Uint8List bytes;
  if (response.statusCode == 200) {
    var _base64 =  jsonDecode(response.body)["image"];
	bytes = base64.decode(_base64);
    files[idx]["bytes"] = bytes;
  } else {
	toast("Error: Failed to get file Names");
  }
  //  new Image.memory(bytes),
  return bytes;
}

// Get performance data
Future <List> getData() async{
  String host = "http://"+user+":9000";
  final response =  await http.get(host+'/perform/$workerId');
  if (response.statusCode == 200) {
    //print( jsonDecode(response.body));
    return jsonDecode(response.body);
  } else {
	toast("Failed to get file Names");
  }
  return [];
}
