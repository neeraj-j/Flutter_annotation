// Common functions

import 'package:flutter/material.dart';
import 'Globals.dart';

// Remove overlay keypoint entry
void removeOverlayKpEntry(int boxIdx, int kpIdx) {
  boxList[boxIdx]["kpOvrls"][kpIdx].remove();
  boxList[boxIdx]["kpOvrls"][kpIdx] = null;
  boxList[boxIdx]["kpKeys"][kpIdx] = null;
}

// Remove overlay segment entry
void removeOverlaySegEntry(int segIdx, GlobalKey icKey) {
  for(var i=0; i<segList[segIdx]["segOvrls"].length; i++){
	if ( segList[segIdx]["segKeys"][i] != icKey){ continue;}
	segList[segIdx]["segOvrls"][i].remove();
	segList[segIdx]["segOvrls"][i] = null;
	segList[segIdx]["segKeys"][i] = null;
  }
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
    if (boxList[boxIdx]["kpOvrls"][i] == null) continue;
    boxList[boxIdx]["kpOvrls"][i].remove();
    boxList[boxIdx]["kpOvrls"][i] = null;
    boxList[boxIdx]["kpKeys"][i] = null;
  }
  // Dont remove box entry
 //  boxList.removeAt(boxIdx);
}

// Remove all overlay keypoint entry
// when changing the file
void purgeOverlayEntry() {
  // Travelse thoiught the list
  for (var k = 0; k < boxList.length; k++) {
    // remove 2 points of box
    for (var i = 0; i < 2; i++) {
      if (boxList[k]["boxOvrls"][i] == null) continue;
      boxList[k]["boxOvrls"][i].remove();
      boxList[k]["boxOvrls"][i] = null;
      boxList[k]["boxKeys"][i] = null;
    }
    // remove all 17 keypoints inside it
    for (var i = 0; i < 17; i++) {
      if (boxList[k]["kpOvrls"][i] == null) continue;
      boxList[k]["kpOvrls"][i].remove();
      boxList[k]["kpOvrls"][i] = null;
      boxList[k]["kpKeys"][i] = null;
    }
  }

  for (var k=0;k<segList.length;k++){
	for (var i=0; i<segList[k]["segOvrls"].length; i++){
      if (segList[k]["segOvrls"][i] == null) continue;
      segList[k]["segOvrls"][i].remove();
      segList[k]["segOvrls"][i] = null;
      segList[k]["segKeys"][i] = null;
		
	}
  }
  // remove boxList entries
  boxList.clear();
  segList.clear();
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

// get keypoint coordinates on webpage for painting
Offset getSegCoords(int segIdx, int icidx) {
  GlobalKey key = segList[segIdx]["segKeys"][icidx];
  if (key == null) {
    return null;
  }
  // get relative position on screen for painting
  return getAbsPosition(key).center;
}

// Draw skeleton lines between keypoints
class DrawSkeleton extends CustomPainter {
  int boxIdx;
  int kpIdx;
  // Constructor
  DrawSkeleton(this.boxIdx, this.kpIdx);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (boxIdx == -1) {
      print("Error: -ve");
      return;
    }
    boxList[boxIdx]["kpPos"][kpIdx] = getKpCoords(boxIdx, kpIdx);
    for (var i = 0; i < skeleton.length; i++) {
      List<int> keypair = skeleton[i];
	  if (!keypair.contains(kpIdx)){
		continue;
	  }
      // skeleton is from 1-17 so subtract 1
      //Offset kp1 = getKpCoords(boxIdx, keypair[0] - 1);
      //Offset kp2 = getKpCoords(boxIdx, keypair[1] - 1);
      Offset kp1 = boxList[boxIdx]["kpPos"][keypair[0]-1];
      Offset kp2 = boxList[boxIdx]["kpPos"][keypair[1]-1];
      if (kp1 == null || kp2 == null) {
        continue;
      }
	  //if (i==13){print(kp1*imgScale);}
      canvas.drawLine(kp1, kp2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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
    if (boxList.length == boxIdx) {
      return;
    }
    //if (boxIdx == -1){return;}
    Offset top = getBoxCoords(boxIdx, 0);
    Offset bot = getBoxCoords(boxIdx, 1);
    if (top == null || bot == null) {
      return;
    }
    Rect _rect = Rect.fromLTRB(top.dx, top.dy, bot.dx, bot.dy);
    canvas.drawRect(_rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// Draw polygon lines between keypoints
class DrawPolygon extends CustomPainter {
  int segIdx;
  int icIdx;
  // Constructor
  DrawPolygon(this.segIdx, this.icIdx);

  @override
  void paint(Canvas canvas, Size size) {
	final opacity = 0.1;
    var paint = Paint()
      ..color = Color.fromRGBO(0xFF, 0xF5, 0x9D, opacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    segList[segIdx]["kPos"][icIdx] = getSegCoords(segIdx, icIdx);
	List<Offset> pts = [];
    for (var i = 0; i < segList[segIdx]["segKeys"].length; i++) {
      //Offset pt = getSegCoords(segIdx, i);
      Offset pt = segList[segIdx]["kPos"][i];
      if (pt == null) {
        continue;
      }
	  pts.add(pt);
    }
    Path path = Path();
    path.addPolygon(pts,true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Widget iconButtonBlue(IconData name, Function f, String msg) {
  var status = true;
  return Tooltip(
    message: msg,
    child: IconButton(
      icon: Icon(name, color: Colors.blue[400]),
      onPressed: f,
      alignment: Alignment.centerRight,
	  disabledColor: Colors.grey,
	  splashColor: Colors.blue[900],
      hoverColor: Colors.yellowAccent[100],
    ),
  );
}


// Black color icon button
Widget iconButtonBlack(IconData name, Function f, String msg) {
  return Tooltip(
    message: msg,
    child: IconButton(
      icon: Icon(
        name,
        color: Colors.black,
      ),
      onPressed: f,
      alignment: Alignment.centerRight,
      hoverColor: Colors.yellowAccent[100],
    ),
  );
}





