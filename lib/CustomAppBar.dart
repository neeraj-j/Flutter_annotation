// this file implements main window

import 'package:flutter/material.dart';
import 'overlay.dart';
import 'Coco.dart';
import 'Globals.dart';
import 'Main_widgets.dart';

class CustomAppBar extends StatelessWidget {
  ImgContainer _currentImage = ImgContainer(
      imgIdx: -1,
      winWidth: null,
      winHeight: null,
      scale: 1.0,
      align: Alignment.center);

  final ScrollController lblscroller = ScrollController();

  @override
  Widget build(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
	gOverlayState = overlayState;
    return Material(
      // Leave as it is. chaning it removes custom panint skeleton
		// refresh happens whitchout listview also
      child: ListView(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width ,
            height: MediaQuery.of(context).size.height ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MenuColumn(), // Icon columns
				ImgColumn(),  // Main image window
				labelList(context, lblscroller), // Lables
				ImgList(),
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
 /****
   Toggle switch implementaiton
  List<bool> isSelected = [true, false];
  // Mode Toggle button
  Widget modeToggle() {
	  return RotatedBox(
		  quarterTurns:1,
		  child: ToggleButtons(
		  children: <Widget>[
			  Tooltip(message:"Modify",
			    child:RotatedBox(quarterTurns:3, child:Icon(Icons.edit))),
			  Tooltip(message: "Verify",
			    child:RotatedBox(quarterTurns:3, child:Icon(Icons.domain_verification))),
		  ],
		  onPressed: (int index) {
			  print("Toggle $index");
			  setState(() {
				 for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
					  if (buttonIndex == index) {
						  isSelected[buttonIndex] = true;
					  } else {
						  isSelected[buttonIndex] = false;
					  }
				  }
			  });
		  },
		  isSelected: isSelected,
	  ),
	);
  }
*****/
