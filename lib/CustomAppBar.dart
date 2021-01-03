// this file implements main window

import 'package:flutter/material.dart';
import 'overlay.dart';
import 'Coco.dart';
import 'Globals.dart';
import 'Main_widgets.dart';

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
      scale: 1.0,
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

  void _updateFiles(int idx) async {
	if (idx == -1){ 
		files.removeAt(currImgIdx);
	}else{ // remove range
	  files.removeRange(0, idx);
	}
    setState(() {});
  }

  final ScrollController lblscroller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Material(
      // Leave as it is. chaning it removes custom panint skeleton
      child: ListView(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width ,
            height: MediaQuery.of(context).size.height ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                menuColumn(context, renderImg, _pickFiles, _updateFiles), // Icon columns
				imgColumn(context, _currentImage),  // Main image window
				labelList(context, lblscroller), // Lables
				imgList(context, renderImg),
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
