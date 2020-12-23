// this file implements main window

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

// Get json data from url
// https://flutter.dev/docs/cookbook/networking/fetch-data

class CustomAppBar extends StatefulWidget {
  CustomAppBar({Key key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  //var _currentItemSelected = 'Dollars';/name

  AlignmentGeometry _dxy = Alignment(0, 0);

  ImgContainer _currentImage = ImgContainer(
      imgIdx: -1,
      winWidth: null,
      winHeight: null,
      scale: 2.2,
      align: Alignment.center);

  void renderImg(imIdx) {
    setState(() {
      //	_currentImage = Image.network(_currImgUrl, scale:_scale, fit:BoxFit.none, alignment: _dxy);
      _currentImage = new ImgContainer(
          imgIdx: imIdx,
          winWidth: null,
          winHeight: null,
          scale: imgScale,
          align: _dxy);
    });
  }

  void _pickFiles() async {
    files = await getFileList();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    // this is the max space allocated for image windows
    final ScrollController _scrollcontroller = ScrollController();
    return Material(
      // Top container
      child: ListView(
        //     shrinkWrap: true,
        children: <Widget>[
          // Menu Row
          // Second Row: 3 columns: Icons, image, labels/Filelist
          //Container(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                menuColumn(context, renderImg, _pickFiles), // Icon columns
				imgColumn(context, _currentImage),  // Main image window
				labelList(context, _scrollcontroller), // Lables
				imgList(context, _scrollcontroller, renderImg),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return val;
}

/*
     Future<ui.Image> getImage(String path) async {
    Completer<ImageInfo> completer = Completer();
    var img = new NetworkImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }
  */
// onPressed: calculateWhetherDisabledReturnsBool() ? null : () => whatToDoOnPressed,
//      child: Text('Button text')
