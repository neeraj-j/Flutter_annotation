// Globals variabls used in this project

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final GlobalKey imgKey = GlobalKey();  // sizedBox key
final GlobalKey imgColKey = GlobalKey(); // Image parentbox key
// Image file list with height and width
List files = [];
ValueNotifier<int> fileNotifier = ValueNotifier(0);

Color brightCyan = Colors.cyanAccent; // On select
Color dullCyan = Colors.cyanAccent[700]; // On de select
Color white = Colors.white; // On de select

// Image globals
double imgScale = 1.0;
double orgImgWidth;
double orgImgHeight;
// Index of displayed image
//int currImgIdx=0;
ValueNotifier<int> currImgIdx = ValueNotifier(-1);

bool dirtyBit= false; // if annotation has changed
int currBoxIdx = -1; // idx of selected box
// to maintain overlay entries
List<Map> boxList = [];

int currSegIdx = -1; // idx of selected box
// to maintain overlay entries
List<Map> segList = [];

double bbIconSize = 15; // icon size of box
double kpIconSize = 15; // icon size of keypoint
double segIconSize = 10; // icon size of keypoint

String workerId = "";  // used fro getting the coco file

OverlayEntry statsOverlayEntry;
OverlayState gOverlayState;

// Skeleton
List<List<int>> skeleton = [
  [15, 13],   //left_ankle, left_knee
  [13, 11],   //Left_knee, left_hip
  [16, 14],    // rt_ankle, rt knee
  [14, 12],   // rtknee, rt_hip 
  [11, 12],   // lt_hip, rt_hip
  [5, 11],    // lt_shoulderr, lt_hip
  [6, 12],   // rt_soulder, rt_hip
  [5, 6],    // lt_sholder, rt_hip
  [5, 7],   // lt_shoulder, lt_elbow
  [6, 8],   // rt_shulder, rt_elbow
  [7, 9],   // lt_elbow, lt_wrist
  [8, 10],   // rt_elbow, rt_wrist
  [1, 2],   // 
  [0, 1],
  [0, 2],
  [1, 3],
  [2, 4],
  [3, 5],
  [4, 6]
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


