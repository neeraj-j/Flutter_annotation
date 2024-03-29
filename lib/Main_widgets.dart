// This file contains the layut widhets used in main file

import 'package:flutter/material.dart';
import 'Common.dart';
import 'Globals.dart';
import 'Coco.dart';
import 'MainLogic.dart';
import 'dart:typed_data';
import 'overlay.dart';

var labelItems = {
  "Nose": 0,
  "Left Eye": 1,
  "Right Eye": 2,
  "Left Ear": 3,
  "Right Ear": 4,
  "Left Shoulder": 5,
  "Right Shoulder": 6,
  "Left Elbow": 7,
  "Right Elbow": 8,
  "Left Wrist": 9,
  "Right Wrist": 10,
  "Left Hip": 11,
  "Right Hip": 12,
  "Left Knee": 13,
  "Right Knee": 14,
  "Left Ankle": 15,
  "Right Ankle": 16,
};

double _menuWidth = 50;
double _labelsWidth = 180;
double _imgListWidth = 160;
int _fileCount = 1;
var _now = new DateTime.now();


class MenuColumn extends StatelessWidget {

  List<IconData> icos = [Icons.save, Icons.verified_user];
  List<String> strs = ["Save Image", "Verify Image"];

  void _pickFiles() async {
	files = await getFileList();
	if (files.isEmpty){
	  toast("Data not 1 found");
	}
	fileNotifier.value = files.length;
  }
  
  void _remImgs(int idx) async {
	if (idx == -1){ 
		files.removeAt(currImgIdx.value);
	}else{ // remove range
	  files.removeRange(0, idx);
	}
	fileNotifier.value = files.length;
  }


 Widget build(BuildContext context) {
  bool status=true;
  return SizedBox(
      width: _menuWidth,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
		  /*
          iconButtonBlue(
			  // oly if files is empty
              Icons.login_outlined, () => {files.isEmpty?loginForm(context):null}, "Login"),*/
          iconButtonBlue(Icons.folder_open, () {
            _pickFiles();
          }, "Load Data"),
          //iconButtonBlue(Icons.download_outlined,
          //    !coco.isEmpty ? null : () => {readCocoFile(_pickFiles)}, "Load Coco File"),
          iconButtonBlue(icos[mode], () async {
              writeCocoFile();
              if (currImgIdx.value + 1 < files.length) {
                _fileCount++; // count to show
                loadImage(currImgIdx.value + 1, context);
              } else {
                toast("Last File");
              }
            }, strs[mode]),
          Divider(indent: 1, thickness: 2, height: 2),
          iconButtonBlue(Icons.crop_square_outlined,
              () => {showOverlayBox(context)}, "Insert Bounding Box"),
		  // Todo: uncomment for segmentation
          //iconButtonBlue(Icons.gesture_outlined,
          //    () => {newOverlaySeg()}, "New Segment"),
          Divider(indent: 2, thickness: 2, height: 2),
          iconButtonBlue(Icons.skip_next, () async {
            // Todo: check for index overflow
            if (currImgIdx.value + 1 < files.length) {
              // dont increse currImgidx here
              loadImage(currImgIdx.value + 1, context);
            } else {
              toast("Last File");
            }
            //ui.Image img =
          }, "Next Image"),
          iconButtonBlue(Icons.skip_previous, () async {
            if (currImgIdx.value - 1 >= 0) {
              loadImage(currImgIdx.value - 1, context);
            } else {
              toast("First File");
            }
            //ui.Image img =
          }, "Previous Image"),
          iconButtonBlue(Icons.call_missed_outgoing,
              () => gotoForm(context, _remImgs), "Goto Image"),
          Divider(indent: 2, thickness: 2, height: 40),
          /*
          iconButtonBlack(Icons.zoom_in_rounded, () {
            imgScale -= 0.1;
            renderImg(currImgIdx.value);
          } , "Zoom In"),
          iconButtonBlack(Icons.zoom_out_rounded, () {
            imgScale += 0.1;
            renderImg(currImgIdx.value);
          }, "Zoom Out"), */
          iconButtonBlack(Icons.assessment, () {
            showOverlayStats(context);
          }, "Performance"),
          Divider(indent: 2, thickness: 2, height: 40),
		  // Delete button disbale too fast
		  Tooltip(
			message: "Delete Image",
			child: IconButton(
			  icon: Icon(Icons.delete, color: Colors.blue[400]),
			  onPressed: (){
				if (!status){
					return;
				}
				status = false;
				//delete from server and coco list
				deleteImage(files[currImgIdx.value]['name']);
				// delete from file list
				_remImgs(-1);
				loadImage(currImgIdx.value, context);
				// force repaint image
				currImgIdx.value++;
				currImgIdx.value--;
				_fileCount++;
				status = true;
			  },
			  alignment: Alignment.centerRight,
			  disabledColor: Colors.grey,
			  splashColor: Colors.blue[900],
			  hoverColor: Colors.yellowAccent[100],
			),
		  ),
          Divider(indent: 2, thickness: 2, height: 40),
        ],
      ));

	} //build
}

//Widget imgColumn(context, _currentImage) {
class ImgColumn extends StatelessWidget {

 Widget build(BuildContext context) {
  return ValueListenableBuilder(
	valueListenable: currImgIdx,
	builder: (context, imgIdx, _){ 
	  return Expanded(
    key: imgColKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Center image
         ImgContainer(
          imgIdx: imgIdx,
          winWidth: null,
          winHeight: null,
          scale: imgScale,
          align: Alignment.center),
        fileName(imgIdx),
      ],
    ),
  );
	});
}
}

Widget labelList(context, _scrollcontroller) {
  return Material(
    child: SizedBox(
        width: _labelsWidth,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            Text(
              'Labels',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            Scrollbar(
              controller: _scrollcontroller,
              isAlwaysShown: true,
              child: SizedBox(
                width: _labelsWidth,
                height: MediaQuery.of(context).size.height * .8,
                child: ListView(
                  controller: _scrollcontroller,
                  children: labelItems.keys
                      .map((data) => Card(
                          child: ListTile(
                              hoverColor: Colors.limeAccent[100],
                              selectedTileColor: Colors.limeAccent[400],
                              leading: Icon(Icons.circle,
                                  size: 15,
                                  color: (labelItems[data] % 2 == 0)
                                      ? Colors.green[400]
                                      : Colors.red[400]),
                              title: Text(data),
                              onTap: () {
                                showOverlayKeypoint(context, labelItems[data], currImgIdx.value);
                              })))
                      .toList(),
                ),
              ),
            ),
          ],
        )),
  );
}

//Widget imgList(context, renderImg) {
class ImgList extends StatelessWidget {

 Widget build(BuildContext context) {
  return ValueListenableBuilder(
	valueListenable: fileNotifier,
	builder: (context, imgIdx, _){ 
	 return Scrollbar(
    // scroller is giving error
    //controller: _scrollcontroller,
    //isAlwaysShown: true,
    child: SizedBox(
      width: _imgListWidth,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Container(
        // color: Colors.deepOrange,
        child: files.isNotEmpty
            ? ListView.separated(
                //           controller: _scrollcontroller,
                padding: EdgeInsets.all(2.0),
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int fidx) => Column(
                  children: [
                    FutureBuilder<Uint8List>(
                        future: getImage(fidx),
                        builder: (context, snapshot) => snapshot.hasData
                            ? GestureDetector(
                                onTap: () {
                                  loadImage(fidx, context);
                                },
                                child: SizedBox(
                                  width: 150,
                                  height: 75,
                                  child: Image.memory(snapshot.data),
                                ),
                              )
                            : CircularProgressIndicator()),
                    SizedBox(
                        height: 15,
                        width: 150,
                        child: Text(
                          " ${files[fidx]['name']}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.0),
                        )),
                  ],
                ),
                itemCount: files.length,
                separatorBuilder: (_, __) => const Divider(
                  indent: 5,
                  thickness: 2.0,
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
  );});}
}

//----------- supporting functions ---------------------//

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

Widget divider(height, thickness) {
  return Divider(indent: 1, thickness: 5);
}

final _formKey = GlobalKey<FormState>();

// Goto file name
void gotoForm(context, remImgs) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Goto File (xxxx_xxxxxx.jpg):",
                          ),
                          onSaved: (String value) {
                            if (value.isEmpty) {
                              return;
                            }
                            //remote all images before this image
                            // make list of filenames and find the index
                            List list =
                                files.map((file) => file["name"]).toList();
                            int idx = list.indexOf(value);
                            if (idx > 0) {
                              remImgs(idx);
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
}

void loginForm(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //content: Stack(
          // overflow: Overflow.visible,
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Stack(
              clipBehavior: Clip.antiAlias,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter User:",
                            ),
                            onSaved: (String value) {
                              if (value.isEmpty) {
                                return;
                              }
                              user = value;
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Password:",
                            ),
                            onSaved: (String value) {
                              if (value.isEmpty) {
                                return;
                              }
                              workerId = value;
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Edit:',
                                style: new TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 15.0),
                              ),
                              Radio(
                                value: 0,
                                groupValue: mode,
                                onChanged: (val) {
								  //refresh();
                                  setState(() {
                                    mode = val;
                                  });
                                },
                              ),
                              Text(
                                'Verify:',
                                style: new TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 15.0),
                              ),
                              Radio(
                                value: 1,
                                groupValue: mode,
                                onChanged: (val) {
								  //refresh();
                                  setState(() {
                                    mode = val;
                                  });
                                },
                              ),
                            ]),
                        // Todo add Radio button
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Submit"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      });
}

Widget fileName(int idx) {
  return Row(
    children: <Widget>[
      SizedBox(
        height: 20,
        width: 150,
        //child: Text(files[idx]['name'],
        child: idx < 0
            ? Text("Load file")
            : Text(
                files[idx]["name"],
                textAlign: TextAlign.center,
              ),
      ),
      SizedBox(
          height: 20,
          width: 100,
          child: Text(
            "Count: ${_fileCount}",
            textAlign: TextAlign.center,
            //style: TextStyle(fontSize: 10.0),
          )),
      SizedBox(
          height: 20,
          width: 100,
          child: Text(
            "Time: ${DateTime.now().difference(_now).toString().split('.')[0]}",
            textAlign: TextAlign.center,
            //style: TextStyle(fontSize: 10.0),
          )),
      SizedBox(
          height: 20,
          width: 100,
          child: Text(
            "Total: ${files.length}",
            textAlign: TextAlign.center,
            //style: TextStyle(fontSize: 10.0),
          )),
    ],
  );
}
