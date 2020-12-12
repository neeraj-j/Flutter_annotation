import 'dart:html' ;
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:file_picker_web/file_picker_web.dart';
import 'package:image_whisperer/image_whisperer.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:ui' as ui;

class CustomAppBar extends StatefulWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  //var _currentItemSelected = 'Dollars';/name
  
  Image _currentImage = Image.asset('Images/logo.jpg');
  List<html.File> _files = [];

  double _scale = 1.0;
  AlignmentGeometry _dxy = Alignment(0,0);
  String _currImgUrl = "";
  int currImgWidth = 0;
  int currImgHeight = 0;


  void renderImg() {
	setState(() {
		_currentImage = Image.network(_currImgUrl, scale:_scale, fit:BoxFit.none, alignment: _dxy);
	});
  }
  //Using this as I need image size
   Future<ui.Image> getImage(File _file) async {
    Completer<ImageInfo> completer = Completer();
	BlobImage blobImage = new BlobImage( _file, name: _file.name);
    var img = new NetworkImage(blobImage.url);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

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

    final ScrollController _scrollcontroller = ScrollController();
    return Material(
      // Top container
      child: ListView(
        //     shrinkWrap: true,
        children: <Widget>[
          // Menu Row
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.08,
            child: Row(children: <Widget>[
              /*todo---for logo*/
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    padding: const EdgeInsets.all(5.0),
                    width: 40,
                    height: 20,
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      //  color: Colors.pink,
                      image:
                          DecorationImage(image: AssetImage('Images/logo.jpg')),
                    )),
              ),

              // File dropdown
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: myBoxDecoration(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.09,
                  height: MediaQuery.of(context).size.height * 0.03,
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      child: DropdownButton(
                        iconEnabledColor: Colors.blue,
                        hint: Text(
                          'File',
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        disabledHint: Text(
                          'File',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: TextStyle(
                          decorationColor: Colors.white,
                          color: Colors.black,
                        ),
                        iconDisabledColor: Colors.blue,
                        elevation: 6,
                        onTap: () {},
                        items: [
                          DropdownMenuItem(
                            child: Text("Open Files"),
                            value: 1,
                            onTap: () {},
                          ),
                          DropdownMenuItem(
                            child: Text("Save"),
                            value: 2,
                          ),
                          DropdownMenuItem(
                              child: Text("Close Directory"), value: 3),
                          DropdownMenuItem(child: Text("Edit"), value: 4),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == 1) {
                              _pickFiles();
                            }
                          });
                        },
                        isExpanded: false,
                        underline: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
              // Edit dropdown
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                  //margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: myBoxDecoration(),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.09,
                    height: MediaQuery.of(context).size.height * 0.03,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          iconEnabledColor: Colors.blue,
                          hint: Text(
                            'Edit',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          disabledHint: Text(
                            'Edit',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: TextStyle(
                            decorationColor: Colors.white,
                            color: Colors.black,
                          ),
                          iconDisabledColor: Colors.blue,
                          elevation: 6,
                          onTap: () {},
                          items: [
                            DropdownMenuItem(
                              child: Text("Cut"),
                              value: 1,
                              onTap: () {},
                            ),
                            DropdownMenuItem(
                              child: Text("Copy"),
                              value: 2,
                            ),
                            DropdownMenuItem(child: Text("Paste"), value: 3),
                            DropdownMenuItem(child: Text("Delete"), value: 4),
                          ],
                          onChanged: (value) {
                            setState(() {});
                          }),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              /*todo---this is for end icon*/

              IconButton(
                icon: Icon(Icons.delete, color: Colors.grey),
                onPressed: () {},
                alignment: Alignment.centerRight,
                hoverColor: Colors.amber[200],
              ),
            ]),
          ),
          // Second Row: 3 columns: Icons, image, labels/Filelist
          Container(
            width: MediaQuery.of(context).size.width * 0.01,
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
                              IconButton(
                                icon: Icon(Icons.play_arrow_outlined,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              IconButton(
                                icon: Icon(Icons.brush_outlined,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              IconButton(
                                icon: Icon(Icons.crop_square_rounded,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              IconButton(
                                icon: Icon(Icons.house_siding_rounded,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              IconButton(
                                icon: Icon(Icons.search_rounded,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              IconButton(
                                icon: Icon(Icons.contact_support_sharp,
                                    color: Colors.blue[400]),
                                onPressed: () {},
                                alignment: Alignment.centerRight,
                                hoverColor: Colors.amber[200],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 150.0),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.comment_rounded,
                                        color: Colors.black26,
                                      ),
                                      onPressed: () {},
                                      alignment: Alignment.centerRight,
                                      hoverColor: Colors.amber[200],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.zoom_in_rounded,
                                        color: Colors.black87,
                                        size: 30.0,
                                      ),
                                      onPressed: () {
										_scale -= 0.1;
										renderImg(); 

									  },
                                      alignment: Alignment.centerRight,
                                      hoverColor: Colors.amber[200],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.zoom_out_rounded,
                                        color: Colors.black87,
                                        size: 30.0,
                                      ),
                                      onPressed: () {
										_scale += 0.1;
										renderImg(); 
									  },
                                      alignment: Alignment.centerRight,
                                      hoverColor: Colors.amber[200],
                                    ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.70,
                      child:
							GestureDetector(
								onPanUpdate: (details){ 
									 double x = (details.delta.dx) * (2.0/currImgWidth );
									 double y = (details.delta.dy) * (2/currImgHeight );
									 // Set globale parameter and reder again
									 _dxy = _currentImage.alignment.add(Alignment(x,y));
									 renderImg(); 
								},
								child: 
										_currentImage,
										//_overlay,
							),
							//Image.asset('Images/logo.jpg'),
                    ),
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
                                          itemBuilder: (BuildContext context,
                                                  int index) =>
                                              Column(
                                            children: [
                                              FutureBuilder<ui.Image>(
                                                  future: getImage(
                                                      _files[index]),
                                                  builder: (context,
                                                          snapshot) =>
                                                      snapshot.hasData
                                                          ? GestureDetector(
                                                              onTap: () {
																   BlobImage
                                                                      blobImage =
                                                                      new BlobImage(
                                                                          _files[index],
                                                                          name: _files[index].name);
																	double winWidth= MediaQuery.of(context).size.width * 0.8;
																	double winHeight= MediaQuery.of(context).size.height * 0.65;
																	currImgWidth = snapshot.data.width;
																	currImgHeight = snapshot.data.height;
																	_currImgUrl = blobImage.url;
																	renderImg();
                                                              },
                                                              child: SizedBox(
                                                                width: 150,
                                                                height: 75,
                                                                child: RawImage (
                                                                        image:snapshot
                                                                            .data),
                                                              ),
                                                            )
                                                          : CircularProgressIndicator()),
                                              SizedBox(
                                                  width: 150,
                                                  height: 30,
                                                  child: Text(
                                                    " ${_files[index].name}",
                                                    style: TextStyle(
                                                        fontSize: 10.0),
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
                                //), // Expand
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
                              child: ListView.builder(
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
                              ),
                            ),
                          ),
                          Container(
                            //color: Colors.blue[100],
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.016,
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ),
                          /* MatrixGestureDetector(
                            onMatrixUpdate: (m, tm, sm, rm) {
                              setState(() {
                                matrix = a;
                              });
                            },
                            child: Transform(
                              transform: matrix,*/
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
