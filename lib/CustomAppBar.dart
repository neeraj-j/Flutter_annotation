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

// Get json data from url
// https://flutter.dev/docs/cookbook/networking/fetch-data

class CustomAppBar extends StatefulWidget {
  CustomAppBar({Key key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  //var _currentItemSelected = 'Dollars';/name

  List<html.File> _files = [];

  AlignmentGeometry _dxy = Alignment(0, 0);
  String _currImgUrl = "";

  //Image _currentImage = Image.asset('Images/logo.jpg');
  ImgContainer _currentImage = ImgContainer(
      imgUrl: "Images/logo.jpg",
      winWidth: null,
      winHeight: null,
      scale: 2.2,
      align: Alignment.center);

  var labelItems = {
    "nose": 0,
    "left_eye": 1,
    "right_eye": 2,
    "left_ear": 3,
    "right_ear": 4,
    "left_shoulder": 5,
    "right_shoulder": 6,
    "left_elbow": 7,
    "right_elbow": 8,
    "left_wrist": 9,
    "right_wrist": 10,
    "left_hip": 11,
    "right_hip": 12,
    "left_knee": 13,
    "right_knee": 14,
    "left_ankle": 15,
    "right_ankle": 16,
  };

  void renderImg() {
    setState(() {
      //	_currentImage = Image.network(_currImgUrl, scale:_scale, fit:BoxFit.none, alignment: _dxy);
      _currentImage = new ImgContainer(
          imgUrl: _currImgUrl,
          winWidth: null,
          winHeight: null,
          scale: imgScale,
          align: _dxy);
    });
  }

  //Using this as I need image size
  Future<ui.Image> getImage(File _file) async {
    Completer<ImageInfo> completer = Completer();
    BlobImage blobImage = new BlobImage(_file, name: _file.name);
    var img = new NetworkImage(blobImage.url);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  // not used
  Future<List<int>> fileAsBytes(html.File _file) async {
    final Completer<List<int>> bytesFile = Completer<List<int>>();
    final html.FileReader reader = html.FileReader();
    reader.onLoad.listen((event) => bytesFile.complete(reader.result));
    reader.readAsArrayBuffer(_file);
    return await bytesFile.future;
  }

  void _pickFiles() async {
    _files = await FilePicker.getMultiFile() ?? [];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // this is the max space allocated for image windows
    double maxWidth = MediaQuery.of(context).size.width * 0.8;
    double maxHeight = MediaQuery.of(context).size.height * 0.70;
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
                // Icons column
                Material(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.04,
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.04,
                          height: MediaQuery.of(context).size.height,
                          decoration: myBoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              iconButtonBlue(Icons.folder_open, () {
                                _pickFiles();
                              }, "Open Images"),
                              iconButtonBlue(Icons.upload_file,
                                  () => {readCocoFile()}, "Load Coco File"),
                              iconButtonBlue(Icons.save,
                                  () => {writeCocoFile()}, "Save Coco file"),
                              iconButtonBlue(
                                  Icons.crop_square_outlined,
                                  () => {_showOverlayBox(context)},
                                  "Insert Bounding Box"),
                              iconButtonBlue(Icons.skip_next, () async {
                                // Todo: check for index overflow
                                if (currImgIdx + 1 < _files.length) {
                                  currImgIdx++;
                                } else {
                                  print("Last file");
                                }

                                ui.Image img =
                                    await getImage(_files[currImgIdx]);
                                loadImage(currImgIdx, img, maxWidth, maxHeight);
								loadAnns(context, _files[currImgIdx].name); 
                              }, "Next Image"),
                              iconButtonBlue(Icons.skip_previous, () async {
                                if (currImgIdx - 1 >= 0) {
                                  currImgIdx--;
                                } else {
                                  print("First file");
                                }
                                ui.Image img =
                                    await getImage(_files[currImgIdx]);
                                loadImage(currImgIdx, img, maxWidth, maxHeight);
								loadAnns(context, _files[currImgIdx].name); 
                                //coco.categories[0]['supercategory'] = "new";
                                //print(coco.categories[0]['supercategory']);
                              }, "Previous Image"),
                              //arrow_left_sharp, arrow_right (next image)
                              Padding(
                                padding: const EdgeInsets.only(top: 100.0),
                                child: Column(
                                  children: [
                                    iconButtonBlack(Icons.zoom_in_rounded, () {
                                      imgScale -= 0.1;
                                      renderImg();
                                    }, "Zoom In"),
                                    iconButtonBlack(Icons.zoom_out_rounded, () {
                                      imgScale += 0.1;
                                      renderImg();
                                    }, "Zoom Out"),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                /*center image and bottom images scroll bar*/
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Center image
                    _currentImage,

                    /*SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.70,
						  child:
							GestureDetector(
								// Show overlay icon
								onLongPress: () {
									//_showOverlayIcon(context, width, height);
									 _showOverlayIcon(context);
								},
								// Pan the image
								onPanUpdate: (details){ 
									 double x = (details.delta.dx) * (2.0/currImgWidth );
									 double y = (details.delta.dy) * (2/currImgHeight );
									 // Set globale parameter and reder again
									 _dxy = _currentImage.alignment.add(Alignment(x,y));
									 renderImg(); 
								},
								child: _currentImage,
							),
					), */
                    // Display all selected images
                    Scrollbar(
                      controller: _scrollcontroller,
                      isAlwaysShown: true,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.black54),
                              onPressed: () {},
                              alignment: Alignment.centerRight,
                              hoverColor: Colors.amber[200],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.19,
                              child: Container(
                                // color: Colors.deepOrange,
                                //child: Expanded(
                                child: _files.isNotEmpty
                                    ? ListView.separated(
                                        padding: EdgeInsets.all(10.0),
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                Column(
                                          children: [
                                            FutureBuilder<ui.Image>(
                                                future: getImage(_files[index]),
                                                builder: (context, snapshot) =>
                                                    snapshot.hasData
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              loadImage(
                                                                  index,
                                                                  snapshot.data,
                                                                  maxWidth,
                                                                  maxHeight);
															  //loadAnns(context, _files[index].name); 
                                                            },
                                                            child: SizedBox(
                                                              width: 150,
                                                              height: 75,
                                                              child: RawImage(
                                                                  image: snapshot
                                                                      .data),
                                                            ),
                                                          )
                                                        : CircularProgressIndicator()),
                                            SizedBox(
                                                width: 150,
                                                height: 30,
                                                child: Text(
                                                  " ${_files[index].name}",
                                                  style:
                                                      TextStyle(fontSize: 10.0),
                                                )),
                                          ],
                                        ),
                                        itemCount: _files.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                          indent: 10,
                                          thickness: 10.0,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'No images selected',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.black54),
                              onPressed: () {},
                              alignment: Alignment.centerRight,
                              hoverColor: Colors.amber[200],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                /*todo---for end list*/
                // End column for Labels and File list
                Material(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.16,
                      height: MediaQuery.of(context).size.height * 0.9,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Scrollbar(
                            controller: _scrollcontroller,
                            isAlwaysShown: true,
                            child: Container(
                              child: Text(
                                'Labels',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.16,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Container(
                              //color: Colors.blue,
                              // Labels list
                              child: ListView(
                                children: labelItems.keys
                                    .map((data) => ListTile(
                                        title: Text(data),
                                        onTap: () {
                                          _showOverlayKeypoint(
                                              context, labelItems[data]);
                                        }))
                                    .toList(),
                              ),

                              /*child: ListView.builder(
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: myBoxDecoration(),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.label_important_rounded,
                                        color: Colors.indigo[300],
                                        size: 20.0,
                                      ),
                                      hoverColor: Colors.amber,
                                      title: Text(
                                        'Label $index',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  );
                                },
                              ),  */
                            ),
                          ),
                          Container(
                            //color: Colors.blue[100],
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.016,
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ),
                          Container(
                            child: Text(
                              'Images',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.16,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              itemCount: 5,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: myBoxDecoration1(),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.image,
                                      color: Colors.green,
                                      size: 15,
                                    ),
                                    //  hoverColor: Colors.green,
                                    title: Text(
                                      'Image $index',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Implements BoundingBox overlays
  void _showOverlayBox(BuildContext context,
      {tAlign = Alignment.center, bAlign = Alignment.center}) async {
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
      // Todo: add segmentation also
    };
    // Index is 1 less than len
    int _boxIdx = boxList.length;
	currBoxIdx = _boxIdx;
    // Generate the overlay entry
    _overlayTopIcon = OverlayEntry(builder: (BuildContext context) {
      return OverlayBox(
          pContext: context,
          boxIdx: _boxIdx,
          ptIdx: 0,
          iconKey: topKey,
          align: tAlign);
    });
    _overlayBotIcon = OverlayEntry(builder: (BuildContext context) {
      return OverlayBox(
          pContext: context,
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
  void _showOverlayKeypoint(BuildContext context, int kpIdx,
      {align: Alignment.center}) async {
    if (currBoxIdx == -1) {
      print('Error: No box selected');
      return;
    }
	print(currBoxIdx);
    if (boxList[currBoxIdx]["kpOvrls"][kpIdx] != null) {
      return;
    }
    OverlayEntry _overlayItem;
    GlobalKey icKey = GlobalKey(); // Icon key to exrect KP location from icon
    OverlayState overlayState = Overlay.of(context);
    int _boxIdx = currBoxIdx; // Do not pass cuurBoxIdx directly to overlayKP
    // Generate the overlay entry
    _overlayItem = OverlayEntry(builder: (BuildContext context) {
      return OverlayKP(
          pContext: context,
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
  void loadImage(int index, ui.Image img, double maxWidth, double maxHeight) {
    BlobImage blobImage =
        new BlobImage(_files[index], name: _files[index].name);
    orgImgWidth = img.width.toDouble();
    orgImgHeight = img.height.toDouble();
    // scale is opposite greater means smaller
    double wScale = orgImgWidth / maxWidth;
    double hScale = orgImgHeight / maxHeight;
    imgScale = (wScale > hScale) ? wScale : hScale;
    //Todo: calculate cuurr image size based on windows size
    _currImgUrl = blobImage.url;
    // remove previous image annotations
    purgeOverlayEntry();
    // display image
    renderImg();
    // Display annotaiton overlays
	//loadAnns(_files[index].name);
  }

  // Load annotation from coco file
  void loadAnns(BuildContext lcontext, String fName) {
	if (images.isEmpty){return;}
	if (!images.containsKey(fName)){return;}
	print("????");
    int id = images[fName]['id'];
    int _w = images[fName]['width'];
    int _h = images[fName]['height'];
    // process anns for the image
    for (int i = 0; i < imgToAnns[id].length; i++) {
      List<dynamic> bbox = imgToAnns[id][i]['bbox'];
      List<dynamic> kps = imgToAnns[id][i]['keypoints'];
      // Draw bbox
      Offset tOff = Offset(bbox[0], bbox[1]); //.scale(imgScale, imgScale);
      Offset bOff = Offset(
          bbox[0] + bbox[2], bbox[1] + bbox[3]); //.scale(imgScale, imgScale);
      // Alignment is scale agnostic
      Alignment tAlign =
          Alignment((tOff.dx - _w / 2) * 2 / _w, (tOff.dy - _h / 2) * 2 / _h);
      Alignment bAlign =
          Alignment((bOff.dx - _w / 2) * 2 / _w, (bOff.dy - _h / 2) * 2 / _h);
	  //print(bAlign);
      _showOverlayBox(lcontext, tAlign: tAlign, bAlign: bAlign);

      // Draw Keypooints
      for (int i = 0; i < kps.length; i += 3) {
        int x = kps[i];
        int y = kps[i + 1];
        int v = kps[i + 2];
        // vaid keypoints
        if (v != 0) {
          Alignment align = Alignment((x - _w / 2) * 2 / _w, (y - _h / 2) * 2 / _h);
		  //print(align);
          _showOverlayKeypoint(lcontext, (i / 3).round(), align: align);
        }
      }
    }
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
    );
  }

  BoxDecoration myBoxDecoration1() {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      // color: Colors.blue[100],
      border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
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
