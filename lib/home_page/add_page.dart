import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iswara/authentication_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String uid_string;
  bool _isLoading = false;

  void getUid() {
    final User user = auth.currentUser;
    final uid = user.uid;
    uid_string = uid;
    // here you write the codes to input the data into firestore
  }

  String authorName, title, desc;

  File _image;
  CrudMethods crudMethods = new CrudMethods();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  uploadData() async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      getUid();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("img")
          .child("$uid_string${randomAlphaNumeric(9)}.jpg");

      final UploadTask task = ref.putFile(_image);

      var downloadUrl = await task.snapshot.ref.getDownloadURL();
      print("this is url $downloadUrl");

      Map<String, String> blogMap = {
        "imgUrl": downloadUrl,
        "authorName": authorName,
        "title": title,
        "desc": desc
      };
      crudMethods.addData(blogMap).then((result) {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Flutter",
                style: TextStyle(fontSize: 22),
              ),
              Text(
                "Blog",
                style: TextStyle(fontSize: 22, color: Colors.blue),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                uploadData();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.file_upload)),
            )
          ],
        ),
        body: _isLoading
            ? Container(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              )
            : Container(
                child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: _image != null
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6)),
                            width: MediaQuery.of(context).size.width,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.black45,
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(hintText: "Author Name"),
                          onChanged: (val) {
                            authorName = val;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: "Title"),
                          onChanged: (val) {
                            title = val;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: "Description"),
                          onChanged: (val) {
                            desc = val;
                          },
                        )
                      ],
                    ),
                  )
                ],
              )));
  }
}
