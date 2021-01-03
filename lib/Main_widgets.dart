// This file contains the layut widhets used in main file

import 'package:flutter/material.dart';
import 'Common.dart';
import 'Globals.dart';
import 'Coco.dart';
import 'MainLogic.dart';
import 'dart:typed_data';

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

Widget menuColumn(context, renderImg, _pickFiles, remImgs) {
  return SizedBox(
      width: _menuWidth,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          iconButtonBlue(Icons.filter_1,
              () => {workerForm(context)}, 
			  "File Id"),
          iconButtonBlue(Icons.folder_open, () {
				readCocoFile(_pickFiles);
          }, "Load Data"),
          //iconButtonBlue(Icons.download_outlined,
          //    !coco.isEmpty ? null : () => {readCocoFile(_pickFiles)}, "Load Coco File"),
          iconButtonBlue(Icons.save, () => {writeCocoFile()}, "Save Image"),
          Divider(indent: 1, thickness: 2, height: 2),
          iconButtonBlue(Icons.crop_square_outlined,
              () => {showOverlayBox(context)}, "Insert Bounding Box"),
          Divider(indent: 2, thickness: 2, height: 2),
          iconButtonBlue(Icons.skip_next, () async {
            // Todo: check for index overflow
            if (currImgIdx + 1 < files.length) {
              currImgIdx++;
            } else {
              print("Last file");
			  toast("Last File");
            }

            //ui.Image img =
            loadImage(currImgIdx, context, renderImg);
          }, "Next Image"),
          iconButtonBlue(Icons.skip_previous, () async {
            if (currImgIdx - 1 >= 0) {
              currImgIdx--;
            } else {
              print("First file");
			  toast("First File");
            }
            //ui.Image img =
            loadImage(currImgIdx, context, renderImg);
          }, "Previous Image"),
          iconButtonBlue(Icons.call_missed_outgoing,
              () => gotoForm(context, remImgs), "Goto Image"),
          Divider(indent: 2, thickness: 2, height: 40),
		  /*
          iconButtonBlack(Icons.zoom_in_rounded, () {
            imgScale -= 0.1;
            renderImg(currImgIdx);
          } , "Zoom In"),
          iconButtonBlack(Icons.zoom_out_rounded, () {
            imgScale += 0.1;
            renderImg(currImgIdx);
          }, "Zoom Out"), */
          Divider(indent: 2, thickness: 2, height: 40),
          iconButtonBlack(Icons.delete, () {
            //delete from server and coco list
            deleteImage(files[currImgIdx]['name']);
            // delete from file list
            remImgs(-1);
            loadImage(currImgIdx, context, renderImg);
			dirtyBit = true;
          }, "Delete Image"),
        ],
      ));
}

Widget imgColumn(context, _currentImage) {
  return Expanded(
    key: imgColKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Center image
        _currentImage,
		fileName(_currentImage.imgIdx),
      ],
    ),
  );
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
                                showOverlayKeypoint(context, labelItems[data]);
                              })))
                      .toList(),
                ),
              ),
            ),
          ],
        )),
  );
}

Widget imgList(context, renderImg) {
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
                                  loadImage(fidx, context, renderImg);
                                },
                                child: SizedBox(
                                  width: 150,
                                  height: 75,
                                  //child: RawImage(
                                  child: Image.memory(snapshot.data),
                                ),
                              )
                            : CircularProgressIndicator()),
                    SizedBox(
                        width: 150,
                        height: 15,
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
  );
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
                        List list = files.map((file) => file["name"]).toList();
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

void workerForm(context) {
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
							labelText: "Enter File Id (0-6):", 
						 ),
						  onSaved: (String value) {
                        if (value.isEmpty) {
                          return;
                        }
						int val = int.parse(value);
						if (val<0 || val >6){
						  toast("Error: Invalid File ID");
						  return;
						}
						workerId = val;
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

Widget fileName(int idx){
	return SizedBox(height:20,
		//child: Text(files[idx]['name'],
		child: idx<0 ? Text("load file"): Text(files[idx]["name"],
			textAlign: TextAlign.center,),
		);
}
