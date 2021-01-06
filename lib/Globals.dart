// Globals variabls used in this project

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final GlobalKey imgKey = GlobalKey();  // sizedBox key
final GlobalKey imgColKey = GlobalKey(); // Image parentbox key
// Image file list with height and width
List files = [];

Color brightCyan = Colors.cyanAccent; // On select
Color dullCyan = Colors.cyanAccent[700]; // On de select
Color white = Colors.white; // On de select

// Image globals
double imgScale = 1.0;
double orgImgWidth;
double orgImgHeight;
// Index of displayed image
int currImgIdx=0;

bool dirtyBit= false; // if annotation has changed
int currBoxIdx = -1; // idx of selected box
// to maintain overlay entries
List<Map> boxList = [];

double bbIconSize = 15; // icon size of box
double kpIconSize = 15; // icon size of keypoint

int workerId = 1;  // used fro getting the coco file

// Skeleton
List<List<int>> skeleton = [
  [16, 14],
  [14, 12],
  [17, 15],
  [15, 13],
  [12, 13],
  [6, 12],
  [7, 13],
  [6, 7],
  [6, 8],
  [7, 9],
  [8, 10],
  [9, 11],
  [2, 3],
  [1, 2],
  [1, 3],
  [2, 4],
  [3, 5],
  [4, 6],
  [5, 7]
];

void toast(mesg){
	Fluttertoast.showToast(
      msg: mesg,
      timeInSecForIosWeb: 5,
      gravity: ToastGravity.CENTER);
}

// annotation (kp and bbox ) globals
/***
  This is the local map strcture
var overlayMap = { 
  "boxOverlayIcons" : new List<OverlayEntry>(2), //list of box icons
  "boxIconKeys": new List<GlobalKey>(2), //icon and bottom point
  "kpIconKeys": new List<GlobalKey>(17), //Top and bottom point
  "kpOverlaysIcons" : new List<OverlayEntry>(17),
  // Todo: add segmentation also
};
*****/


