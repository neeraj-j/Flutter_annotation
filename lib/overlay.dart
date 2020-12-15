//This file implemets overlay widget
import 'package:flutter/material.dart';
import 'Globals.dart';
// Implements overlay class for dots

final GlobalKey _imgKey = GlobalKey();

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
	  key: _imgKey,
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
        /*
								child: CustomPaint( 
										foregroundPainter: ShapePainter(),
										child: _currentImage,
										//size: Size(currImgWidth,currImgHeight), 
										size: Size(100,100), 
										willChange: true,
										),
								*/
      ), 
    );
  }


}

class OverlayKP extends StatefulWidget {
  OverlayKP({
    Key key,
    @required this.pContext,
    @required this.kpIdx,
    @required this.overlayList,
  }) : super(key: key);

  final BuildContext pContext;
  final int kpIdx;
  final List<OverlayEntry> overlayList; 


  @override
  _OverlayKPState createState() => _OverlayKPState();
}

class _OverlayKPState extends State<OverlayKP> {
  Alignment _dragAlignment = Alignment.topRight;

  Rect _getPosition() {
	RenderBox box = _imgKey.currentContext.findRenderObject() as RenderBox;
	Offset topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
	Offset bottomRight =
	   box.size.bottomRight(box.localToGlobal(Offset.zero));
	return Rect.fromLTRB(
	   topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  }

  void _removeOverlayEntry() {
    widget.overlayList[widget.kpIdx].remove();
    widget.overlayList[widget.kpIdx] = null;
    //_overlayEntry = null;
  }

  @override
  Widget build(BuildContext pContext) {
    Rect overlayPos = _getPosition();
	Color clr = (widget.kpIdx %2 == 0)? Colors.green[400]: Colors.red[400];
    // Get the coordinates of the item
    Rect widgetPosition = _getPosition().translate(
        -overlayPos.left, 
        -overlayPos.top,
    );
    return CustomSingleChildLayout(
		delegate: _OverlayableContainerLayout(overlayPos),
		child: Container(
			child: GestureDetector(
				onDoubleTap: (){
					_removeOverlayEntry();
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
			  child: Align(
				alignment: _dragAlignment,
				child: Icon(Icons.circle, color: clr),
			  ),
		)//Gesture
	),
	); // Container
  }
}

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
