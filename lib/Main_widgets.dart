// This file contains the layut widhets used in main file

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
double _labelsWidth = 150;
double _imgListWidth = 160;

Widget menuColumn(context, renderImg, _pickFiles) {
  return SizedBox(
      width: _menuWidth,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          iconButtonBlue(Icons.folder_open, () {
            _pickFiles();
          }, "Open Images"),
          iconButtonBlue(
              Icons.upload_file, () => {readCocoFile()}, "Load Coco File"),
          iconButtonBlue(Icons.save, () => {writeCocoFile()}, "Save Coco file"),
          iconButtonBlue(Icons.crop_square_outlined,
              () => {showOverlayBox(context)}, "Insert Bounding Box"),
          iconButtonBlue(Icons.skip_next, () async {
            // Todo: check for index overflow
            if (currImgIdx + 1 < files.length) {
              currImgIdx++;
            } else {
              print("Last file");
            }

            //ui.Image img =
            loadImage(currImgIdx, context, renderImg);
          }, "Next Image"),
          iconButtonBlue(Icons.skip_previous, () async {
            if (currImgIdx - 1 >= 0) {
              currImgIdx--;
            } else {
              print("First file");
            }
            //ui.Image img =
            loadImage(currImgIdx, context, renderImg);
          }, "Previous Image"),
          //arrow_left_sharp, arrow_right (next image)
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                iconButtonBlack(Icons.zoom_in_rounded, () {
                  imgScale -= 0.1;
                  renderImg(currImgIdx);
                }, "Zoom In"),
                iconButtonBlack(Icons.zoom_out_rounded, () {
                  imgScale += 0.1;
                  renderImg(currImgIdx);
                }, "Zoom Out"),
              ],
            ),
          ),
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
      ],
    ),
  );
}

Widget labelList(context, _scrollcontroller) {
  return Material(
    child: SizedBox(
        width: _labelsWidth, 
        height: MediaQuery.of(context).size.height,
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
              width: _labelsWidth,
              height: MediaQuery.of(context).size.height * .8,
              child: Container(
                //color: Colors.blue,
                // Labels list
                child: ListView(
                  children: labelItems.keys
                      .map((data) => ListTile(
                          title: Text(data),
                          onTap: () {
                            showOverlayKeypoint(context, labelItems[data]);
                          }))
                      .toList(),
                ),
              ),
            ),
          ],
        )),
  );
}

Widget imgList(context, _scrollcontroller, renderImg) {
  return Scrollbar(
    controller: _scrollcontroller,
    isAlwaysShown: true,
    child: SizedBox(
      width: _imgListWidth,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Container(
        // color: Colors.deepOrange,
        child: files.isNotEmpty
            ? ListView.separated(
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
