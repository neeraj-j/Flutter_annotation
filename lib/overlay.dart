//This file implemets overlay widget
import 'package:flutter/material.dart';
import 'Common.dart';
import 'Globals.dart';
import 'dart:typed_data';
import 'Coco.dart';
// Implements overlay class for dots
// This key is used for image widget

var labelText = {
  0: "Nose",
  1: "Left Eye",
  2: "Right Eye",
  3: "Left Ear",
  4: "Right Ear",
  5: "Left Shoulder",
  6: "Right Shoulder",
  7: "Left Elbow",
  8: "Right Elbow",
  9: "Left Wrist",
  10: "Right Wrist",
  11: "Left Hip",
  12: "Right Hip",
  13: "Left Knee",
  14: "Right Knee",
  15: "Left Ankle",
  16: "Right Ankle",
};

var boxText = {
  0: "Top Left",
  1: "Bottom Right",
};

// ------ Image  container Start -------------------//

class ImgContainer extends StatefulWidget {
  ImgContainer({
    Key key,
    @required this.imgIdx,
    @required this.winWidth,
    @required this.winHeight,
    @required this.scale,
    @required this.align,
  }) : super(key: key);

  final int imgIdx;
  final double scale;
  final Alignment align;
  final double winWidth;
  final double winHeight;

  @override
  _ImgContainerState createState() => _ImgContainerState();
}

class _ImgContainerState extends State<ImgContainer> {
  BuildContext myContext;

  @override
  Widget build(BuildContext context) {
    myContext = context;
    return SizedBox(
	  key: imgKey,
      width: widget.winWidth,
      height: widget.winHeight,
      // No gesture detector for image
      child: FutureBuilder<Uint8List>(
          future: getImage(widget.imgIdx),
          builder: (context, snapshot) => snapshot.hasData
              ? GestureDetector(
                  // Pan the image
                  onPanUpdate: (details) {
                    //double x = (details.delta.dx) * (2.0/currImgWidth );
                    //double y = (details.delta.dy) * (2/currImgHeight );
                    // Set globale parameter and reder again
                    //_dxy = _currentImage.alignment.add(Alignment(x,y));
                    // renderImg();
                  },
                  child: Image.memory(snapshot.data,
                      scale: widget.scale,
                      fit: BoxFit.none,
                      alignment: widget.align),
                )
              : CircularProgressIndicator()),
    );
  }
}
// ------ Image  container End -------------------//

// ------ Keypoint overlay container Start -------------------//
class OverlayKP extends StatefulWidget {
  OverlayKP({
    Key key,
    //@required this.pContext,
    @required this.boxIdx,
    @required this.kpIdx,
    @required this.iconKey,
    @required this.kAlign,
  }) : super(key: key);

  //final BuildContext pContext;
  final int boxIdx;
  final int kpIdx;
  final GlobalKey iconKey;
  final Alignment kAlign;

  @override
  _OverlayKPState createState() => _OverlayKPState();
}

class _OverlayKPState extends State<OverlayKP> {
  //Alignment _dragAlignment;
  Alignment _dragAlignment;
  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.kAlign;
  }

  @override
  Widget build(BuildContext context) {
    Rect overlayPos = getPosition(imgKey);
    Color clr = (widget.kpIdx % 2 == 0) ? Colors.green[400] : Colors.red[400];

    return CustomSingleChildLayout(
      delegate: _OverlayableContainerLayout(overlayPos),
      child: Container(
          child: GestureDetector(
        onDoubleTap: () {
          // Long press not working
          removeOverlayKpEntry(widget.boxIdx, widget.kpIdx);
          dirtyBit = true;
		  boxList[widget.boxIdx]["changed"][1] = true;
        },
        //behavior: HitTestBehavior.deferToChild,
        onPanUpdate: (details) {
          setState(() {
			
            double dx = details.delta.dx / (overlayPos.width / 2);
            double dy = details.delta.dy / (overlayPos.height / 2);
            _dragAlignment += Alignment(dx, dy);
            double x = _dragAlignment.x;
            double y = _dragAlignment.y;
            // clip the avalues to -1 to 1
            if (x > 1.0) {
              _dragAlignment = Alignment(1.0, y);
            } else if (x < -1.0) {
              _dragAlignment = Alignment(-1.0, y);
            }
            if (y > 1.0) {
              _dragAlignment = Alignment(x, 1.0);
            } else if (y < -1.0) {
              _dragAlignment = Alignment(x, -1.0);
            }
          });
          dirtyBit = true;
		  boxList[widget.boxIdx]["changed"][1] = true;
        },
        child: CustomPaint(
          foregroundPainter: DrawSkeleton(widget.boxIdx),
          willChange: true,
          child: Align(
              //alignment: _dragAlignment,
			  alignment:_dragAlignment,
              child: Tooltip(
                message: labelText[widget.kpIdx],
                child: Icon(Icons.circle,
                    key: widget.iconKey, size: kpIconSize, color: clr),
              )),
        ),
      ) //Gesture
          ),
    ); // Container
  }
}
// ------ Keypoint overlay container End -------------------//

// ------ Box overlay container Start -------------------//
class OverlayBox extends StatefulWidget {
  OverlayBox({
    Key key,
    // @required this.pContext,
    @required this.boxIdx,
    @required this.ptIdx,
    @required this.iconKey,
    @required this.align,
  }) : super(key: key);

  //final BuildContext pContext;
  final int boxIdx;
  final int ptIdx;
  final GlobalKey iconKey;
  Alignment align;

  @override
  _OverlayBoxState createState() => _OverlayBoxState();
}

class _OverlayBoxState extends State<OverlayBox> {
  //Alignment _dragAlignment = Alignment.center;
  Color clr = dullCyan;
  Alignment _dragAlignment;
  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.align;
  }

  @override
  Widget build(BuildContext context) {
    Rect overlayPos = getPosition(imgKey);
    return CustomSingleChildLayout(
      delegate: _OverlayableContainerLayout(overlayPos),
      child: Container(
          child: GestureDetector(
        onSecondaryLongPress: () {
          // Delete
          removeOverlayBoxEntry(widget.boxIdx);
          dirtyBit = true;
		  // make bbox and Keypoints changed
		  boxList[widget.boxIdx]["changed"][0] = true;
		  boxList[widget.boxIdx]["changed"][1] = true;
        },
        onTap: () {
          // select and heighlight
          setState(() {
            if (currBoxIdx == widget.boxIdx) {
              // Unselect the box
              currBoxIdx = -1;
              clr = dullCyan;
            } else if (currBoxIdx == -1) {
              // No box seleccted select this one
              currBoxIdx = widget.boxIdx;
              clr = brightCyan;
            } else {
              //trying to select this box while another one is selected
              print("Unselect the previous box");
            }
          });
        },
        //behavior: HitTestBehavior.deferToChild,
        onPanUpdate: (details) {
          setState(() {
            double dx = details.delta.dx / (overlayPos.width / 2);
            double dy = details.delta.dy / (overlayPos.height / 2);
            _dragAlignment += Alignment(dx, dy);
            double x = _dragAlignment.x;
            double y = _dragAlignment.y;
            // clip the avalues to -1 to 1
            if (x > 1.0) {
              _dragAlignment = Alignment(1.0, y);
            } else if (x < -1.0) {
              _dragAlignment = Alignment(-1.0, y);
            }
            if (y > 1.0) {
              _dragAlignment = Alignment(x, 1.0);
            } else if (y < -1.0) {
              _dragAlignment = Alignment(x, -1.0);
            }
          });
          dirtyBit = true;
		  boxList[widget.boxIdx]["changed"][0] = true;
        },
        child: CustomPaint(
          foregroundPainter: DrawRect(widget.boxIdx, clr),
          willChange: true,
          child: Align(
              alignment: _dragAlignment,
              child: Tooltip(
                message: boxText[widget.ptIdx],
                child: Icon(Icons.circle,
                    key: widget.iconKey, size: bbIconSize, color: clr),
              )),
        ),
      ) //Gesture
          ),
    ); // Container
  }
}
// ------ Box overlay container End -------------------//

class _OverlayableContainerLayout extends SingleChildLayoutDelegate {
  _OverlayableContainerLayout(this.position);

  final Rect position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(position.width, position.height));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(position.left, position.top);
  }

  @override
  bool shouldRelayout(_OverlayableContainerLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
