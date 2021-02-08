// This file contains the main logic functions
import 'dart:async';
import 'package:flutter/material.dart';
import 'overlay.dart';
import 'Common.dart';
import 'Globals.dart';
import 'Coco.dart';



  // Implements BoundingBox overlays
  void showOverlayBox(BuildContext context, 
      {tAlign = Alignment.center, bAlign = Alignment.center, annId=-1}) async {
    OverlayEntry _overlayTopIcon;
    OverlayEntry _overlayBotIcon;
    OverlayState overlayState = Overlay.of(context);
    final GlobalKey topKey = GlobalKey(); // Icon key to exrect top location from icon
    final GlobalKey botKey =
        GlobalKey(); // Icon key to exrect bottom location from icon
    var _overlayMap = {
      "boxOvrls": new List<OverlayEntry>.filled(2, null), //list of box icons
      "boxKeys": new List<GlobalKey>.filled(2, null), //icon and bottom point
      "kpKeys": new List<GlobalKey>.filled(17, null), //Top and bottom point
      "kpOvrls": new List<OverlayEntry>.filled(17, null),
      "kpPos": new List<Offset>.filled(17, null),
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
    gOverlayState.insertAll(
      [
        _overlayBotIcon,
        _overlayTopIcon,
      ],
    );
  }

  // Implements Keypoint overlays
  void showOverlayKeypoint(BuildContext context, int kpIdx, fidx,
      {align: Alignment.center}) async {
    if (currBoxIdx == -1) {
	  toast("Error: No Box Selected ");
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

	double _w=files[fidx]['width']/imgScale ;
	double _h=files[fidx]['height']/imgScale ;
    // Overlay items
    boxList[currBoxIdx]["kpOvrls"][kpIdx] = _overlayItem;
    boxList[currBoxIdx]["kpPos"][kpIdx] = Offset(align.x*_w/2+_w/2,align.y*_h/2+_h/2);
    // add icon key to extract position of keypoint
    boxList[currBoxIdx]["kpKeys"][kpIdx] = icKey;
    // Insert the overlayEntry on the screen
    gOverlayState.insert(
      _overlayItem,
    );
  //print(getAbsPosition(icKey).center);
}

  void newOverlaySeg({annId=-1}){
    var _overlayMap = {
      "segOvrls": new List<OverlayEntry>.empty(growable: true), //list of box icons
      "segKeys": new List<GlobalKey>.empty(growable: true), //icon and bottom point
	  "kPos": new List<Offset>.empty(growable:true),
	  "changed": List<bool>.filled(1,false),
	  "annId": List<int>.filled(1,0),
    };
  
    int _segIdx = segList.length;
    currSegIdx = _segIdx;
  
    _overlayMap["annId"][0] = annId;
    segList.add(_overlayMap);
  }



  // Load new image and annnotations
  // click on image list and next button
  void loadImage(int fidx, BuildContext context) {
    Rect imgWindow = getPosition(imgColKey);
    double _maxHeight =  imgWindow.height;
    double _maxWidth = imgWindow.width; 
    if (dirtyBit) {
      // Alert box update/discard
      showMyDialog(fidx, context);
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
    // Display annotaiton overlays
	//print("$orgImgWidth, $orgImgHeight, $_maxWidth, $_maxHeight");
	//print("Imscale: $imgScale");
    loadAnns(context, fidx);
    currImgIdx.value = fidx;
	getImage(currImgIdx.value+10);
  }

  // Load annotation from coco file
  void loadAnns(BuildContext lcontext, int fidx) {
    String fName = files[fidx]['name'];

	List<dynamic> annotations=[];
    double _w=files[fidx]['width'] ;
    double _h=files[fidx]['height'] ;
	double kpSize = kpIconSize*imgScale; // for kp icon of 15
	double bbSize = bbIconSize*imgScale; // for box icon of 10

    annotations = files[fidx]['annotations'];
	// check if annotations exists
	if (annotations.isEmpty){return;}
    // process anns for the image
    for (int i = 0; i < annotations.length; i++) {
      List<dynamic> bbox = annotations[i]['bbox'];
      List<dynamic> kps = annotations[i]['keypoints'];
	  int annId = annotations[i]['id'];
	  //print("$bbox");
      // Draw bbox
      Offset tOff = Offset(bbox[0], bbox[1]); //.scale(imgScale, imgScale);
      Offset bOff = Offset(
          bbox[0] + bbox[2], bbox[1] + bbox[3]); //.scale(imgScale, imgScale);
      // Alignment is scale agnostic
      Alignment tAlign =
          Alignment((tOff.dx - (_w / 2)) * 2 / (_w-bbSize), (tOff.dy - (_h / 2)) * 2 / (_h-bbSize));
      Alignment bAlign =
          Alignment((bOff.dx - (_w / 2)) * 2 / (_w-bbSize), (bOff.dy - (_h / 2)) * 2 / (_h-bbSize));
      showOverlayBox(lcontext, tAlign: tAlign, bAlign: bAlign, annId:annId);

      // Draw Keypooints
      for (int i = 0; i < kps.length; i+=3) {
        double x = kps[i];
        double y = kps[i+1];
		//print("$x,$y");
        // vaid keypoints
        if (x != 0 && y !=0) {
		  // compensate for icon size size 15 = 19.8 pixels
          Alignment align =
              Alignment((x - (_w / 2)) * 2 / (_w-kpSize), (y - (_h / 2)) * 2 / (_h-kpSize));
          showOverlayKeypoint(lcontext, (i~/3), fidx, align: align);
        }
      }
    }
    // Once all the loading is complete
    currBoxIdx = -1;
  }


  // confirmation dialoge while changing images
  Future<void> showMyDialog(int index, BuildContext context) async {
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
                Navigator.of(context,rootNavigator: true).pop();
				writeCocoFile();
                loadImage(index, context);
              },
            ),
            TextButton(
              child: Text('Discard'),
              onPressed: () {
                dirtyBit = false;
                loadImage(index, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Implements Statistics overlays
  void showOverlayStats(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    // Generate the overlay entry
    statsOverlayEntry = OverlayEntry(builder: (BuildContext context) {
      return OverlayStats();
    },opaque:true );
    overlayState.insert(statsOverlayEntry);
  }
