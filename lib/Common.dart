// Common functions 

import 'package:flutter/material.dart';
import 'Globals.dart';


// Remove overlay keypoint entry
void removeOverlayKpEntry(int boxIdx, int kpIdx) {
  print(boxIdx);
  boxList[currBoxIdx]["kpOvrls"][kpIdx].remove();	
  boxList[currBoxIdx]["kpOvrls"][kpIdx] = null;	
  boxList[currBoxIdx]["kpKeys"][kpIdx] = null;	
}

// Remove overlay Box entry and enclosed keypoints
void removeOverlayBoxEntry(int boxIdx) {
  // remove 2 points of box 
  for (var i = 0; i < 2; i++) {
	boxList[boxIdx]["boxOvrls"][i].remove();	
	boxList[boxIdx]["boxOvrls"][i] = null;	
	boxList[boxIdx]["boxKeys"][i] = null;	
  }
  // remove all 17 keypoints inside it
  for (var i = 0; i < 17; i++) {
	boxList[boxIdx]["kpOvrls"][i].remove();	
	boxList[boxIdx]["kpOvrls"][i] = null;	
	boxList[boxIdx]["kpKeys"][i] = null;	
  }
}


// Remove all overlay keypoint entry
// when changing the file
void purgeOverlayEntry() {
	// Travelse thoiught the list
  for (var k = 0; k <boxList.length; k++) {
  // remove 2 points of box 
	for (var i = 0; i < 2; i++) {
	  boxList[k]["boxOvrls"][i].remove();	
	  boxList[k]["boxOvrls"][i] = null;	
	  boxList[k]["boxKeys"][i] = null;	
	}
	// remove all 17 keypoints inside it
	for (var i = 0; i < 17; i++) {
	  boxList[k]["kpOvrls"][i].remove();	
	  boxList[k]["kpOvrls"][i] = null;	
	  boxList[k]["kpKeys"][i] = null;	
	}
  }
}

// This funtion willl return relative position of widget
Rect getPosition(GlobalKey key) {
  RenderBox box = key.currentContext.findRenderObject() as RenderBox;
  Offset topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
  Offset bottomRight = box.size.bottomRight(box.localToGlobal(Offset.zero));
  return Rect.fromLTRB(topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
}

// This function will return position with (0,0) coordinate as Topleft
Rect getAbsPosition(GlobalKey key) {
  // subtract topleft position of image to get coords from 0,0
  Rect relativePosition = getPosition(imgKey);
  Rect widgetPosition = getPosition(key).translate(
    -relativePosition.left,
    -relativePosition.top,
  );
  return widgetPosition;
}

// get keypoint coordinates on webpage for painting
Offset getKpCoords(int boxIdx, int kpidx) {
  GlobalKey key = boxList[boxIdx]["kpKeys"][kpidx];
  if (key == null) {
    return null;
  }
  // get relative position on screen for painting
  return getAbsPosition(key).center;
}
// get keypoint coordinates on webpage for painting
Offset getBoxCoords(int boxIdx, int ptIdx) {
  GlobalKey key = boxList[boxIdx]["boxKeys"][ptIdx];	
  if (key == null) {
    return null;
  }
  // get relative position on screen for painting
  // center of box containing the circle icon
  return getAbsPosition(key).center;
}

// Save keypoints. Todo: save to file
// Todo: take scale of image into consideration
void saveKp(double scale) {
}

// Draw skeleton lines between keypoints
class DrawSkeleton extends CustomPainter {
  int boxIdx;
  // Constructor
  DrawSkeleton(this.boxIdx);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

	if (boxIdx == -1){
	  print("-ve");
	  return;}
    for (var i = 0; i < skeleton.length; i++) {
      List<int> keypair = skeleton[i];
      // skeleton is from 1-17 so subtract 1
      Offset kp1 = getKpCoords(boxIdx, keypair[0] - 1);
      Offset kp2 = getKpCoords(boxIdx, keypair[1] - 1);
      if (kp1 == null || kp2 == null) {
        continue;
      }
      canvas.drawLine(kp1, kp2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
// Draw rectangle for bounding Box
class DrawRect extends CustomPainter {
  int boxIdx;
  Color clr;
  // Constructor
   DrawRect(this.boxIdx, this.clr);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = clr
	  ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // entry is nt yet added to boxlist 
	//print(clr);
	if (boxList.length == boxIdx){
	  return;}
	//if (boxIdx == -1){return;}
    Offset top = getBoxCoords(boxIdx,0);
    Offset bot = getBoxCoords(boxIdx,1);
    if (top == null || bot == null) {
      return;
    }
    Rect _rect = Rect.fromLTRB(top.dx, top.dy, bot.dx, bot.dy);
    canvas.drawRect(_rect,paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
