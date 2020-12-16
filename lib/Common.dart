// Common functions 

import 'package:flutter/material.dart';
import 'Globals.dart';


// Remove overlay keypoint entry
void removeOverlayKpEntry(int kpIdx) {
  overlayKpList[kpIdx].remove();
  overlayKpList[kpIdx] = null;
  kpKeyList[kpIdx] = null;
}
/*
// Remove overlay Box entry
void removeOverlayBoxEntry(int boxIdx) {
  // Todo make it 2D for multipe boxes
  overlayBoxList[0].remove();
  overlayBoxList[0] = null;
  boxKeyList[0] = null;
  boxKeyList[1] = null;
}
*/

// Remove all overlay keypoint entry
// when changing the file
void purgeOverlayEntry() {
  for (var i = 0; i < 17; i++) {
    if (overlayKpList[i] == null) {
      continue;
    }
    overlayKpList[i].remove();
    overlayKpList[i] = null;
    kpKeyList[i] = null;
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
Offset getKpCoords(int idx) {
  if (kpKeyList[idx] == null) {
    return null;
  }
  // get relative position on screen for painting
  return getAbsPosition(kpKeyList[idx]).center;
}

// Save keypoints. Todo: save to file
// Todo: take scale of image into consideration
void saveKp(double scale) {
  for (var i = 0; i < kpKeyList.length; i++) {
    if (kpKeyList[i] == null) {
      continue;
    }
    if (kpKeyList[i].currentContext == null) {
      continue;
    }
    //print(kpKeyList[i].currentContext.findRenderObject());
    Rect pos = getAbsPosition(kpKeyList[i]);
    print(pos.center);
  }
}

// Draw skeleton lines between keypoints
class DrawSkeleton extends CustomPainter {
  //int size;
  // Constructor
  // ShapePainter({this.size});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < skeleton.length; i++) {
      List<int> keypair = skeleton[i];
      // skeleton is from 1-17 so subtract 1
      Offset kp1 = getKpCoords(keypair[0] - 1);
      Offset kp2 = getKpCoords(keypair[1] - 1);
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
