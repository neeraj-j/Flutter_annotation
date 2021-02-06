//This file implemets overlay widget
import 'package:flutter/material.dart';
import 'Common.dart';
import 'Globals.dart';
import 'dart:typed_data';
import 'Coco.dart';
import 'package:flutter/rendering.dart';
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
              ? MouseRegion(
				  // or use onHover to paint cross hair for bbox
				  cursor: SystemMouseCursors.basic,    //precise,
				  //onHover:
				  child: GestureDetector(
					onTapUp: (details){
				      // print("${details.localPosition.dx}, ${details.localPosition.dy}");	
					  dirtyBit=true;
					  addOverlaySeg(context, details.localPosition.dx, details.localPosition.dy) ;
					},
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
                ),)
              : CircularProgressIndicator()),
    );
  }

  // add points to segmentation overlay at the end
  void addOverlaySeg(BuildContext context, dx, dy) async {
    if (currSegIdx == -1) {
	  toast("Error: No Segment Created");
      return;
    }
	double icSize = segIconSize*imgScale; // for box icon of 10
	double _w=files[currImgIdx]['width'] ;
	double _h=files[currImgIdx]['height'] ;
	Alignment align =
		Alignment((dx - (_w / 2)) * 2 / (_w-icSize), (dy - (_h / 2)) * 2 / (_h-icSize));

    OverlayEntry _overlayItem;
    GlobalKey icKey = GlobalKey(); // Icon key to exrect KP location from icon
    OverlayState overlayState = Overlay.of(context);
    int _segIdx = currSegIdx; // Do not pass curBoxIdx directly to overlayKP
	int icidx = segList[currSegIdx]["segOvrls"].length;
    // Generate the overlay entry
    _overlayItem = OverlayEntry(builder: (BuildContext context) {
      return OverlaySeg(
          //   pContext: context,
          segIdx: _segIdx,
		  icIdx: icidx,
          iconKey: icKey,
          sAlign: align);
    });

    // Overlay items
    segList[currSegIdx]["segOvrls"].add(_overlayItem);
    // add icon key to extract position of keypoint
    segList[currSegIdx]["segKeys"].add(icKey);
    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayItem,
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
              alignment: _dragAlignment,
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

// ------ segment overlay container Start -------------------//
class OverlaySeg extends StatefulWidget {
  OverlaySeg({
    Key key,
    //@required this.pContext,
    @required this.segIdx,
    @required this.icIdx,
    @required this.iconKey,
    @required this.sAlign,
  }) : super(key: key);

  //final BuildContext pContext;
  final int segIdx;
  final int icIdx;
  final GlobalKey iconKey;
  final Alignment sAlign;

  @override
  _OverlaySegState createState() => _OverlaySegState();
}

class _OverlaySegState extends State<OverlaySeg> {
  //Alignment _dragAlignment;
  Alignment _dragAlignment;
  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.sAlign;
  }

  @override
  Widget build(BuildContext context) {
    Rect overlayPos = getPosition(imgKey);
    Color clr;
	if (widget.icIdx ==0){
	  clr = Colors.redAccent;
	}else if (widget.icIdx == segList[widget.segIdx]["segKeys"].length-1){
	  clr = Colors.greenAccent;
	}else{
	  clr = Colors.white;
	}

    return CustomSingleChildLayout(
      delegate: _OverlayableContainerLayout(overlayPos),
      child: Container(
          child: GestureDetector(
        // Remove point on double tap
		onDoubleTap: (){
			removeOverlaySegEntry(widget.segIdx, widget.iconKey);
		} ,
		onSecondaryTapUp: (details){
			dirtyBit=true;
			// insert new point after   this
			insertOverlaySeg(context, widget.sAlign+Alignment(0.05,0.05), widget.iconKey) ;
		},
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
          segList[widget.segIdx]["changed"][0] = true;
        },
        child: CustomPaint(
          foregroundPainter: DrawPolygon(widget.segIdx),
          willChange: true,
          child: Align(
              alignment: _dragAlignment,
                child: Icon(Icons.circle,
                    key: widget.iconKey, size: segIconSize, color: clr),
              ),
        ),
      ) //Gesture
          ),
    ); // Container
  }

  // insert points to segmentation overlay in the middie 
  void insertOverlaySeg(BuildContext context, Alignment align, GlobalKey prevKey ) async {
    if (currSegIdx == -1) {
	  toast("Error: No Segment Created");
      return;
    }
	double icSize = segIconSize*imgScale; // for box icon of 10
	double _w=files[currImgIdx]['width'] ;
	double _h=files[currImgIdx]['height'] ;

    OverlayEntry _overlayItem;
    GlobalKey icKey = GlobalKey(); // Icon key to exrect KP location from icon
    OverlayState overlayState = Overlay.of(context);
    int _segIdx = currSegIdx; // Do not pass curBoxIdx directly to overlayKP
	int icidx = segList[currSegIdx]["segOvrls"].length;
    // Generate the overlay entry
    _overlayItem = OverlayEntry(builder: (BuildContext context) {
      return OverlaySeg(
          //   pContext: context,
          segIdx: _segIdx,
		  icIdx: icidx,
          iconKey: icKey,
          sAlign: align);
    });
	// insertin the middle of the list for path draw
	for(var i=0; i<segList[currSegIdx]["segOvrls"].length; i++){
		if ( segList[currSegIdx]["segKeys"][i] != prevKey){ continue;}
		// Overlay items
		segList[currSegIdx]["segOvrls"].insert(i+1, _overlayItem);
		// add icon key to extract position of keypoint
		segList[currSegIdx]["segKeys"].insert(i+1, icKey);
	}
    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayItem,
    );
  }
}
// ------ Keypoint overlay container End -------------------//
// ------ Statistics overlay container Start -------------------//
class OverlayStats extends StatefulWidget {
  OverlayStats({
    Key key,
    // @required this.pContext,
  }) : super(key: key);

  @override
  _OverlayStatState createState() => _OverlayStatState();
}

class _OverlayStatState extends State<OverlayStats> {
  //Alignment _dragAlignment = Alignment.center;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Rect imgPos = getPosition(imgKey);
	Rect overlayPos = imgPos.topLeft & const Size(400,400);
    return CustomSingleChildLayout(
      delegate: _OverlayableContainerLayout(overlayPos),
       child: FutureBuilder<List>(
              future: getData(),
              builder: (context, snapshot) => snapshot.hasData
      ? Container(
        child: Column(children: <Widget>[
          dataTable(snapshot.data),
          RaisedButton(
            onPressed: () {statsOverlayEntry.remove();},
            child: const Text('Back', style: TextStyle(fontSize: 20)),
          ),
        ]),
      ):CircularProgressIndicator()),
    ); // Container
  }

  DataRow dataRow(rec){
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(rec['Name'])),
            DataCell(Text(rec['count'].toString())),
            DataCell(Text(Duration(seconds:rec['seconds'].round()).toString().split('.')[0])),
          ],
        );
  }

  Widget dataTable(data) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Images',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Time (HH:MM:SS)',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: <DataRow>[
		dataRow(data[0]),
		//dataRow(data[1]),
		//dataRow(data[2]),
		//dataRow(data[3]),
		//dataRow(data[4]),
      ],
    );
  }
}

// ------ Stats overlay container End -------------------//

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
