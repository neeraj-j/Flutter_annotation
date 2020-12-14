//This file implemets overlay widget
import 'package:flutter/material.dart';
// Implements overlay class for dots

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
  Image getImg() {
    Image _currentImage = Image.network(widget.imgUrl,
        scale: widget.scale, fit: BoxFit.none, alignment: widget.align);
    return _currentImage;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.winWidth, 
      height: widget.winHeight, 
      child: Image.network(widget.imgUrl,
        scale: widget.scale, fit: BoxFit.none, alignment: widget.align),
	  /*
		 // No gesture detector for image
      child: GestureDetector(
        // Show overlay icon
        onLongPress: () {
          //_showOverlayIcon(context, width, height);
          //_showOverlayIcon(context);
        },
        // Pan the image
        onPanUpdate: (details) {
          // double x = (details.delta.dx) * (2.0/currImgWidth );
          // double y = (details.delta.dy) * (2/currImgHeight );
          // Set globale parameter and reder again
          // _dxy = _currentImage.alignment.add(Alignment(x,y));
          // renderImg();
        },
        /*
								child: CustomPaint( 
										foregroundPainter: ShapePainter(),
										child: _currentImage,
										//size: Size(currImgWidth,currImgHeight), 
										size: Size(100,100), 
										willChange: true,
										),
								*/
      ), */
    );
  }

  void showOverlayIcon(){
	_showOverlayIcon(context, widget.winWidth, widget.winHeight);
  }

  OverlayEntry _overlayItem;
  final List<OverlayEntry> _overlayItemList = new List<OverlayEntry>(17);
  int _overlayIdx = -1;
  // Implements overlays
  void _showOverlayIcon(BuildContext context, double width, double height) async {
    OverlayState overlayState = Overlay.of(context);
    // Generate the overlay entry
    _overlayItem = OverlayEntry(builder: (BuildContext context) {
      return OverlayKP(pContext: context, width:width, height: height);
    });
    // Starting from -1
    _overlayIdx++;
    _overlayItemList[_overlayIdx] = _overlayItem;
    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayItemList[_overlayIdx],
    );
  }

  void _removeOverlayEntry() {
    _overlayItemList[_overlayIdx]?.remove();
    _overlayIdx--;
    //_overlayEntry = null;
  }
}

class OverlayKP extends StatefulWidget {
  OverlayKP({
    Key key,
    @required this.pContext,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final BuildContext pContext;
  final double width;
  final double height;


  @override
  _OverlayKPState createState() => _OverlayKPState();
}

class _OverlayKPState extends State<OverlayKP> {
  Alignment _dragAlignment = Alignment.center;

  @override
  Widget build(BuildContext pContext) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (widget.width / 2),
            details.delta.dy / (widget.height / 2),
          );
        });
      },
      child: Align(
        alignment: _dragAlignment,
        child: Icon(Icons.circle, color: Colors.red),
      ),
    );
  }
}
