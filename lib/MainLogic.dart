// This file contains the main logic functions
import 'dart:async';
import 'package:flutter/material.dart';
import 'overlay.dart';
import 'Common.dart';
import 'Globals.dart';
import 'Coco.dart';
import 'package:fluttertoast/fluttertoast.dart';



  // Implements BoundingBox overlays
  void showOverlayBox(BuildContext context, 
      {tAlign = Alignment.center, bAlign = Alignment.center, annId=-1}) async {
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
	  "changed": List<bool>.filled(2,false),
	  "annId": List<int>.filled(1,0),
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
	//Todo: new box annid is -1 fix while saving
    _overlayMap["annId"][0] = annId;
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
	  Fluttertoast.showToast(msg: "Error: No Box Selected ",
		  timeInSecForIosWeb: 5,
		  gravity: ToastGravity.CENTER);
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
      return;
    }
    orgImgWidth = files[fidx]["width"];
    orgImgHeight = files[fidx]["height"];
	if (orgImgHeight==0 || orgImgWidth ==0){
	  Fluttertoast.showToast(msg: "Load Image",
		  timeInSecForIosWeb: 5,);
		return;	
	}
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
    int imid = images[fName]['id'];
    int _w = images[fName]['width'];
    int _h = images[fName]['height'];
	print("$_w, $_h");
	// check if annotations exists
	if (!imgToAnns.containsKey(imid)){return;}
    // process anns for the image
    for (int i = 0; i < imgToAnns[imid].length; i++) {
      List<dynamic> bbox = imgToAnns[imid][i]['bbox'];
      List<dynamic> kps = imgToAnns[imid][i]['keypoints'];
	  int annId = imgToAnns[imid][i]['id'];
      // Draw bbox
      Offset tOff = Offset(bbox[0], bbox[1]); //.scale(imgScale, imgScale);
      Offset bOff = Offset(
          bbox[0] + bbox[2], bbox[1] + bbox[3]); //.scale(imgScale, imgScale);
      // Alignment is scale agnostic
      Alignment tAlign =
          Alignment((tOff.dx - (_w / 2)) * 2 / _w, (tOff.dy - (_h / 2)) * 2 / _h);
      Alignment bAlign =
          Alignment((bOff.dx - (_w / 2)) * 2 / _w, (bOff.dy - (_h / 2)) * 2 / _h);
      showOverlayBox(lcontext, tAlign: tAlign, bAlign: bAlign, annId:annId);

      // Draw Keypooints
      for (int i = 0; i < kps.length; i += 3) {
        int x = kps[i];
        int y = kps[i + 1];
        int v = kps[i + 2];
        // vaid keypoints
        if (v != 0) {
		  //print("$x, $y");
          Alignment align =
              Alignment((x - (_w / 2)) * 2 / _w, (y - (_h / 2)) * 2 / _h);
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
          title: Text('Image Modified!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You have changed the Image'),
                Text('Accept or Discard the changes'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                dirtyBit = false;
				// Todo: save changes
				writeCocoFile();
                loadImage(index, context, renderImg);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Discard'),
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

