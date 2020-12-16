//This file implemets overlay widget
import 'package:flutter/material.dart';
import 'Common.dart';
import 'Globals.dart';
// Implements overlay class for dots
// This key is used for image widget

    var labelText = {
	  0:"Nose",
      1:"Left Eye",
      2:"Right Eye",
      3:"Left Ear",
      4:"Right Ear",
      5:"Left Shoulder",
      6:"Right Shoulder",
      7:"Left Elbow",
      8:"Right Elbow",
      9:"Left Wrist",
      10:"Right Wrist",
      11:"Left Hip",
      12:"Right Hip",
      13:"Left Knee",
      14:"Right Knee",
      15:"Left Ankle",
      16:"Right Ankle",
  };

var boxText = {
  0:"Top Left",
  1: "Bottom Right",
};


// ------ Image  container Start -------------------//

class ImgContainer extends StatefulWidget {
  ImgContainer({
    Key key,
    @required this.imgUrl,
    @required this.winWidth,
    @required this.winHeight,
    @required this.scale,
    @required this.align,
  }) : super(key: key);

  final String  imgUrl;
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
      //child: Image.network(widget.imgUrl,
      //  scale: widget.scale, fit: BoxFit.none, alignment: widget.align),
	  
		 // No gesture detector for image
      child: GestureDetector(
        // Show overlay icon
        onLongPress: () {
          //showOverlayIcon();
        },
        // Pan the image
        onPanUpdate: (details) {
          // double x = (details.delta.dx) * (2.0/currImgWidth );
          // double y = (details.delta.dy) * (2/currImgHeight );
          // Set globale parameter and reder again
          // _dxy = _currentImage.alignment.add(Alignment(x,y));
          // renderImg();
        },
		child: Image.network(widget.imgUrl,
				  scale: widget.scale, fit: BoxFit.none, alignment: widget.align),
      ), 
    );
  }
}
// ------ Image  container End -------------------//

// ------ Keypoint overlay container Start -------------------//
class OverlayKP extends StatefulWidget {
  OverlayKP({
    Key key,
    @required this.pContext,
    @required this.kpIdx,
	@required this.iconKey,
  }) : super(key: key);

  final BuildContext pContext;
  final int kpIdx;
  final GlobalKey iconKey;


  @override
  _OverlayKPState createState() => _OverlayKPState();
}

class _OverlayKPState extends State<OverlayKP> {
  Alignment _dragAlignment = Alignment.center;

  @override
  Widget build(BuildContext pContext) {
    Rect overlayPos = getPosition(imgKey);
	Color clr = (widget.kpIdx %2 == 0)? Colors.green[400]: Colors.red[400];

    return CustomSingleChildLayout(
		delegate: _OverlayableContainerLayout(overlayPos),
		child: Container(
			child: GestureDetector(
				onLongPress: (){
					removeOverlayKpEntry(widget.kpIdx);
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
				  if (x > 1.0){_dragAlignment = Alignment(1.0,y) ;}
				  else if (x < -1.0){_dragAlignment = Alignment(-1.0,y);}
				  if (y > 1.0){_dragAlignment = Alignment(x,1.0) ;}
				  else if (y < -1.0){_dragAlignment = Alignment(x,-1.0);}

				});
			  },
			  child: CustomPaint( 
					  foregroundPainter: DrawSkeleton(),
					  willChange: true,
					  child: Align(
						alignment: _dragAlignment,
						child: Tooltip(
						   message: labelText[widget.kpIdx],
						   child: Icon( Icons.circle, key:widget.iconKey,size:15, color: clr),
						)
					  ),
					  ),
		)//Gesture
	),
	); // Container
  }
}
// ------ Keypoint overlay container End -------------------//

// ------ Box overlay container Start -------------------//
class OverlayBox extends StatefulWidget {
  OverlayBox({
    Key key,
    @required this.pContext,
    @required this.ptIdx,
	@required this.iconKey,
  }) : super(key: key);

  final BuildContext pContext;
  final int ptIdx;
  final GlobalKey iconKey;

  @override
  _OverlayBoxState createState() => _OverlayBoxState();
}

class _OverlayBoxState extends State<OverlayBox> {
  Alignment _dragAlignment = Alignment.center;

  @override
  Widget build(BuildContext pContext) {
    Rect overlayPos = getPosition(imgKey);
	Color bright = Colors.cyanAccent; // On select
	Color dull = Colors.cyanAccent[700]; // On de select

    return CustomSingleChildLayout(
		delegate: _OverlayableContainerLayout(overlayPos),
		child: Container(
			child: GestureDetector(
				onDoubleTap: (){
					//removeOverlayEntry(widget.ptIdx);
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
				  if (x > 1.0){_dragAlignment = Alignment(1.0,y) ;}
				  else if (x < -1.0){_dragAlignment = Alignment(-1.0,y);}
				  if (y > 1.0){_dragAlignment = Alignment(x,1.0) ;}
				  else if (y < -1.0){_dragAlignment = Alignment(x,-1.0);}

				});
			  },
			  child: CustomPaint( 
					  foregroundPainter: DrawSkeleton(),
					  willChange: true,
					  child: Align(
						alignment: _dragAlignment,
						child: Tooltip(
						   message: boxText[widget.ptIdx],
						   child: Icon( Icons.circle, key:widget.iconKey,size:15, color: dull),
						)
					  ),
					  ),
		)//Gesture
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
