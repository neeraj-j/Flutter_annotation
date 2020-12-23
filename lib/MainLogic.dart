// This file contains the main logic functions
import 'dart:html';
import 'dart:async';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:file_picker_web/file_picker_web.dart';
import 'package:image_whisperer/image_whisperer.dart';
//import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:ui' as ui;
import 'overlay.dart';
import 'Common.dart';
import 'Globals.dart';
import 'Coco.dart';
import 'Main_widgets.dart';
import 'dart:typed_data';



  // Implements BoundingBox overlays
  void showOverlayBox(BuildContext context,
      {tAlign = Alignment.center, bAlign = Alignment.center}) async {
    OverlayEntry _overlayTopIcon;
    OverlayEntry _overlayBotIcon;
    OverlayState overlayState = Overlay.of(context);
    GlobalKey topKey = GlobalKey(); // Icon key to exrect top location from icon
    GlobalKey botKey =
        GlobalKey(); // Icon key to exrect bottom location from icon
    var _overlayMap = {
      "boxOvrls": new List<OverlayEntry>.filled(2, null), //list of box icons
      "boxKeys": new List<GlobalKey>.filled(2, null), //icon and bottom point
      "kpKeys": new List<GlobalKey>.filled(17, null), //Top and bottom point
      "kpOvrls": new List<OverlayEntry>.filled(17, null),
      // Todo: add segmentation also
    };
    // Index is 1 less than len
    int _boxIdx = boxList.length;
    currBoxIdx = _boxIdx;
    // Generate the overlay entry
    _overlayTopIcon = OverlayEntry(builder: (BuildContext context) {
      return OverlayBox(
          //     pContext: context,
          boxIdx: _boxIdx,
          ptIdx: 0,
          iconKey: topKey,
          align: tAlign);
    });
    _overlayBotIcon = OverlayEntry(builder: (BuildContext context) {
      return OverlayBox(
          //    pContext: context,
          boxIdx: _boxIdx,
          ptIdx: 1,
          iconKey: botKey,
          align: bAlign);
    });
    // Overlay items ony 1
    _overlayMap["boxOvrls"][0] = _overlayTopIcon;
    _overlayMap["boxOvrls"][1] = _overlayBotIcon;
    _overlayMap["boxKeys"][0] = topKey;
    _overlayMap["boxKeys"][1] = botKey;
    boxList.add(_overlayMap);
    // Todo: append currentBoxIdx to ptIdx
    // add icon key to extract position of keypoint
    // Insert the overlayEntry on the screen
    overlayState.insertAll(
      [
        _overlayBotIcon,
        _overlayTopIcon,
      ],
    );
  }

  // Implements Keypoint overlays
  void showOverlayKeypoint(BuildContext context, int kpIdx,
      {align: Alignment.center}) async {
    if (currBoxIdx == -1) {
      print('Error: No box selected');
      return;
    }
    if (boxList[currBoxIdx]["kpOvrls"][kpIdx] != null) {
      return;
    }
    OverlayEntry _overlayItem;
    GlobalKey icKey = GlobalKey(); // Icon key to exrect KP location from icon
    OverlayState overlayState = Overlay.of(context);
    int _boxIdx = currBoxIdx; // Do not pass curBoxIdx directly to overlayKP
    // Generate the overlay entry
    _overlayItem = OverlayEntry(builder: (BuildContext context) {
      return OverlayKP(
          //   pContext: context,
          boxIdx: _boxIdx,
          kpIdx: kpIdx,
          iconKey: icKey,
          kAlign: align);
    });

    // Overlay items
    boxList[currBoxIdx]["kpOvrls"][kpIdx] = _overlayItem;
    // add icon key to extract position of keypoint
    boxList[currBoxIdx]["kpKeys"][kpIdx] = icKey;
    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayItem,
    );
  }

  // Load new image and annnotations
  // click on image list and next button
  void loadImage(int fidx, BuildContext context, renderImg) {
    Rect imgWindow = getPosition(imgColKey);
    double _maxHeight =  imgWindow.height;
    double _maxWidth = imgWindow.width; 
    if (dirtyBit) {
      // Alert box update/discard
      showMyDialog(fidx, context, renderImg);
      print("Save the current Annotations");
      return;
    }
    orgImgWidth = files[fidx]["width"];
    orgImgHeight = files[fidx]["height"];
    // scale is opposite greater means smaller
    double wScale = orgImgWidth / _maxWidth;
    double hScale = orgImgHeight / _maxHeight;
    imgScale = (wScale > hScale) ? wScale : hScale;
    //Todo: calculate cuurr image size based on windows size
    // remove previous image annotations
    purgeOverlayEntry();
    // display image
    renderImg(fidx);
    // Display annotaiton overlays
    loadAnns(context, fidx);
    currImgIdx = fidx;
  }

  // Load annotation from coco file
  void loadAnns(BuildContext lcontext, int fidx) {
    if (images.isEmpty) {
      return;
    }
    String fName = files[fidx]['name'];
    if (!images.containsKey(fName)) {
      return;
    }
    int id = images[fName]['id'];
    int _w = images[fName]['width'];
    int _h = images[fName]['height'];
    // process anns for the image
    for (int i = 0; i < imgToAnns[id].length; i++) {
      List<dynamic> bbox = imgToAnns[id][i]['bbox'];
      List<dynamic> kps = imgToAnns[id][i]['keypoints'];
      // Draw bbox
      Offset tOff = Offset(bbox[0], bbox[1]); //.scale(imgScale, imgScale);
      Offset bOff = Offset(
          bbox[0] + bbox[2], bbox[1] + bbox[3]); //.scale(imgScale, imgScale);
      // Alignment is scale agnostic
      Alignment tAlign =
          Alignment((tOff.dx - _w / 2) * 2 / _w, (tOff.dy - _h / 2) * 2 / _h);
      Alignment bAlign =
          Alignment((bOff.dx - _w / 2) * 2 / _w, (bOff.dy - _h / 2) * 2 / _h);
      //print(bAlign);
      showOverlayBox(lcontext, tAlign: tAlign, bAlign: bAlign);

      // Draw Keypooints
      for (int i = 0; i < kps.length; i += 3) {
        int x = kps[i];
        int y = kps[i + 1];
        int v = kps[i + 2];
        // vaid keypoints
        if (v != 0) {
          Alignment align =
              Alignment((x - _w / 2) * 2 / _w, (y - _h / 2) * 2 / _h);
          //print(align);
          showOverlayKeypoint(lcontext, (i / 3).round(), align: align);
        }
      }
    }
    // Once all the loading is complete
    currBoxIdx = -1;
  }

  // update annns from boxlist to
  int updateAnns(String fName) {
    int id = images[fName]['id'];
    List<int> delList = []; // index list of deletd boxes
    // process anns for the image
    for (int i = 0; i < boxList.length; i++) {
      //Update box
      List<dynamic> boxKey1 = boxList[i]['boxKey'][0];
      List<dynamic> boxKey2 = boxList[i]['boxKey'][1];
      // box is deleted. cant delete is now.
      // We have to delte it in reverse order
      if (boxKey1 == null || boxKey2 == null) {
        delList.add(i);
        continue;
      }

      Offset pt1 = getBoxCoords(i, 0);
      Offset pt2 = getBoxCoords(i, 1);
      Offset topleft;
      Offset botright;
      // convert them to actual image coordinates
      pt1 = pt1.scale(imgScale, imgScale);
      pt2 = pt2.scale(imgScale, imgScale);
      // check for topleft point
      if (pt1.dx < pt2.dx && pt1.dy < pt2.dy) {
        topleft = pt1;
        botright = pt2;
      } else if (pt2.dx < pt1.dx && pt2.dy < pt1.dy) {
        topleft = pt2;
        botright = pt1;
      } else {
        return -1;
      } // error. points have wrong order

      imgToAnns[id][i]['bbox'][0] = topleft.dx;
      imgToAnns[id][i]['bbox'][1] = topleft.dy;
      imgToAnns[id][i]['bbox'][2] = botright.dx - topleft.dx;
      imgToAnns[id][i]['bbox'][3] = botright.dy - topleft.dy;

      // Copy keypoints
      for (int j = 0; j < 17; j++) {
        if (boxList[i]["kpKeys"][j] == null) {
          imgToAnns[id][i]['keypoints'][j * 3] = 0;
          imgToAnns[id][i]['keypoints'][j * 3 + 1] = 0;
          imgToAnns[id][i]['keypoints'][j * 3 + 2] = 0;
        } else {
          Offset kp = getKpCoords(i, j);
          //convert the kp to image coordinates
          kp = kp.scale(imgScale, imgScale);
          imgToAnns[id][i]['keypoints'][j * 3] = kp.dx;
          imgToAnns[id][i]['keypoints'][(j * 3) + 1] = kp.dx;
          // keep the visibility same
        }
      }
    }
    // Detele the boxes and corresponding annotations in reverse index
    // so as not to change the index order
    for (int k = delList.length - 1; k >= 0; k--) {
      imgToAnns[id].removeAt(delList[k]);
    }
    return 0;
  }

  // confirmation dialoge while changing images
  Future<void> showMyDialog(int index, BuildContext context, renderImg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                dirtyBit = false;
                loadImage(index, context, renderImg);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('DisApprove'),
              onPressed: () {
                dirtyBit = false;
                loadImage(index, context, renderImg);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

