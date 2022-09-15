
// this file implements login screen 

import 'package:flutter/material.dart';
import 'Coco.dart';

// Todo: make it stteful widget

class LoginScreen extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _errText = "";

  _callLogin(info) {
	loginUser(info, context).then((val) => setState(() {
          _errText = val;
        }));
  } 

  @override
  Widget build(BuildContext context){
	var  info = new Map();
	return Material(
		child:Column(
		mainAxisAlignment: MainAxisAlignment.center,
	  children: [
		   Center(
			   child: Text(_errText),
			   ),

		   SizedBox(  // form
			width: 300, 
		    child:  Card(
				 elevation: 5,
				 child:Form(
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
							validator: (value) {
                              if (value.isEmpty) {
                                return "Enter User";
                              }
							  return null;
							},
                            onSaved: (String value) {
                              info["user"] = value;
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Password:",
                            ),
							validator: (value) {
                              if (value.isEmpty) {
                                return "Enter Password";
                              }
							  return null;
							},
                            onSaved: (String value) {
                              info["passwd"] = value;
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
                                 // setState(() {
                                    mode = val;
                                 // });
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
                                 // setState(() {
                                    mode = val;
                                 // });
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
								_callLogin(info);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
				),),
				],
	  ),);

  }
}
