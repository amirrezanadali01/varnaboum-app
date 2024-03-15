import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:varnaboomapp/Detail.dart';
import '../mapPage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/base.dart';
import './EndRegisterPage.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

import 'package:image_cropper/image_cropper.dart';

class endregister extends StatefulWidget {
  @override
  _endregisterState createState() => _endregisterState();
}

class _endregisterState extends State<endregister> {
  var box;

  dio.Dio _dio = dio.Dio();

  String idCategory = registerInformationShop['category'];

  late bool is_trailer;
  bool is_adress = false;
  bool is_tags = false;

  bool is_load = false;

  bool is_name = false;
  XFile? video;
  CroppedFile? imageProfile;

  late List questionCategory = [];
  late TextEditingController controllerAddress;
  late TextEditingController controllerName;
  late TextEditingController controllerTags;
  List<XFile>? multiImageList = [];

  Future<void> get_MultiImage() async {
    final ImagePicker _picker = ImagePicker();
    multiImageList =
        await _picker.pickMultiImage(maxWidth: 1000, imageQuality: 85);

    // multiImageList = await MultiImagePicker.pickImages(
    //   maxImages: 6,
    //   enableCamera: true,
    //   materialOptions: MaterialOptions(
    //     actionBarTitle: "Varnaboom",
    //   ),
    // );
    setState(() {});
  }

  //For Trailer
  Future<void> get_video() async {
    final ImagePicker _picker = ImagePicker();
    video = await _picker.pickVideo(source: ImageSource.gallery);
    registerInformationShop['trailer'] = video;
    setState(() {});
  }

  Future<void> get_ImageProfile() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagepicker = await _picker.pickImage(source: ImageSource.gallery);

    imageProfile = await ImageCropper().cropImage(
        maxWidth: 1000,
        compressQuality: 85,
        sourcePath: imagepicker!.path,
        aspectRatioPresets: [CropAspectRatioPreset.square]);

    setState(() {});
  }

  Future<bool> getQuestion() async {
    if (is_load == false) {
      await updateToken(context);

      var boxToken = await Hive.openBox('token');

      String access = boxToken.get('access');
      http.Response questions = await http.get(
          Uri.parse('$host/api/retryQuestionRequired/$idCategory'),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
      print(questions.body);
      print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

      questionCategory = jsonDecode(utf8.decode(questions.bodyBytes));
      createTextField(questionCategory);
    }

    is_load = true;

    return true;
  }

  void createTextField(result) {
    for (var i in result) {
      i['controller'] = TextEditingController();
    }
  }

  @override
  void initState() {
    if (registerInformationShop.containsKey('trailer')) {
      is_trailer = true;
      setState(() {});
    } else {
      is_trailer = false;
    }

    controllerTags = TextEditingController();
    controllerAddress = TextEditingController();
    controllerName = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(registerInformationShop);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.navigate_next),
          onPressed: () async {
            var status_all = true;

            if (is_name == false) {
              if (controllerName.text.isEmpty) {
                status_all = false;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "نام فروشگاه وارد نشده است",
                          style: TextStyle(fontFamily: Myfont),
                        ),
                        content: Text(''),
                        actions: [
                          OutlinedButton(
                              child: Text('ok',
                                  style: TextStyle(fontFamily: Myfont)),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      );
                    });
              } else {
                registerInformationShop['name'] = controllerName.text;
              }
            }
            if (status_all == true) if (is_adress == false) {
              if (controllerAddress.text.isEmpty) {
                status_all = false;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("آدرس صنف وارد نشده است",
                            style: TextStyle(fontFamily: Myfont)),
                        content: Text(''),
                        actions: [
                          OutlinedButton(
                              child: Text('ok',
                                  style: TextStyle(fontFamily: Myfont)),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      );
                    });
              } else {
                registerInformationShop['address'] = controllerAddress.text;
              }
            }
            if (status_all == true) if (is_tags == false) {
              if (controllerTags.text.isEmpty) {
                status_all = false;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("چه خدمات و محصولاتی ارائه می دهی",
                            style: TextStyle(fontFamily: Myfont)),
                        content: Text(''),
                        actions: [
                          OutlinedButton(
                              child: Text('ok',
                                  style: TextStyle(fontFamily: Myfont)),
                              onPressed: () => Navigator.pop(context)),
                        ],
                      );
                    });
              } else {
                registerInformationShop['tags'] = controllerTags.text;
              }
            }

            if (status_all == true) if (imageProfile == null) {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("لطفا عکس پروفایل را وارد کنید",
                          style: TextStyle(fontFamily: Myfont)),
                      content: Text(''),
                      actions: [
                        OutlinedButton(
                            child: Text('ok',
                                style: TextStyle(fontFamily: Myfont)),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    );
                  });
            } else if (status_all == true) if (multiImageList!.isEmpty) {
              status_all = false;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("لطفا عکس فروشگاهتون را وارد کنید",
                          style: TextStyle(fontFamily: Myfont)),
                      content: Text(''),
                      actions: [
                        OutlinedButton(
                            child: Text('ok',
                                style: TextStyle(fontFamily: Myfont)),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    );
                  });
            } else {
              print(
                  'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
              if (status_all == true)
                for (var i in questionCategory) {
                  if (i['controller'].text.isEmpty) {
                    status_all = false;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                                "لطفا به سوال زیر پاسخ دهید : \n ${i['question']}",
                                style: TextStyle(fontFamily: Myfont)),
                            content: Text(''),
                            actions: [
                              OutlinedButton(
                                  child: Text('ok',
                                      style: TextStyle(fontFamily: Myfont)),
                                  onPressed: () => Navigator.pop(context)),
                            ],
                          );
                        });
                    break;
                  }
                }
            }

            List<Map> questionAnswer = [];
            List asstImages = [];

            // if (status_all == true) {
            //   registerInformationShop['qustionsCategory'] = questionCategory;

            // }

            // questionAnswer
            // registerInformationShop
            // multiImageList

            if (status_all == true) {
              updateToken(context);
              var boxToken = await Hive.openBox('token');
              String access = boxToken.get('access');

              registerInformationShop['user'] = access;

              for (var i in questionCategory) {
                questionAnswer.add({
                  'question': i['id'].toString(),
                  'answer': i['controller'].text,
                  'user': access
                });
              }

              for (var i in multiImageList ?? []) {
                String fileNameProfile = i?.path.split('/').last as String;

                var hi = await MultipartFile.fromFile(i?.path as String,
                    filename: fileNameProfile.toEnglishDigit());

                final planetsByDiameter = {"image": hi};

                asstImages.add(planetsByDiameter);

                // ByteData bytedata = await i.getByteData();
                // List<int> imageData = bytedata.buffer.asUint8List();
                // MultipartFile multipartFile = MultipartFile.fromBytes(imageData,
                //     filename: '${i.name}'.toEnglishDigit(),
                //     contentType: MediaType("image", "png"));
                // asstImages.add({'image': multipartFile});

              }

              // String fileName = imageProfile?.path.split('/').last as String;

              // dio.FormData formdata = dio.FormData.fromMap({
              //   "InfoUser": json.encode(registerInformationShop),
              //   "AnswerQuestion": json.encode(questionAnswer),
              //   "ImageStore": asstImages,
              //   "Profile": await MultipartFile.fromFile(
              //       imageProfile?.path as String,
              //       filename: fileName),
              // });

              // _dio.options.headers['content-Type'] = 'application/json';
              // _dio.options.headers['Authorization'] = 'Bearer $access';

              // print(registerInformationShop);

              // var response =
              //     await _dio.post("$host/api/registerShop/", data: formdata);

              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => baseWidget()));

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: EndRegister(
                                questionAnswer: questionAnswer,
                                AssetImage: asstImages,
                                imageProfile: imageProfile),
                          )));
            }
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: IntrinsicHeight(
                    child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => get_ImageProfile(),
                      child: Column(
                        children: [
                          Icon(Icons.person_pin,
                              size: 30,
                              color: imageProfile?.path != null
                                  ? Colors.greenAccent
                                  : Colors.redAccent),
                          Text(
                            'تصویر پروفایل',
                            style: TextStyle(
                                fontFamily: Myfont,
                                color: imageProfile?.path != null
                                    ? Colors.greenAccent
                                    : Colors.redAccent),
                          )
                        ],
                      ),
                    ),
                    VerticalDivider(width: 50, color: Colors.black),
                    GestureDetector(
                      onTap: () => get_MultiImage(),
                      child: Column(
                        children: [
                          Icon(Icons.store,
                              size: 30,
                              color: multiImageList!.isEmpty
                                  ? Colors.red
                                  : Colors.greenAccent),
                          Text(
                            'تصاویر صنف',
                            style: TextStyle(
                                fontFamily: Myfont,
                                color: multiImageList!.isEmpty
                                    ? Colors.red
                                    : Colors.greenAccent),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: controllerName,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.greenAccent)),
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontFamily: Myfont,
                                ),
                                labelText: 'نام فروشگاه',
                                enabledBorder: InputBorder.none,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: controllerAddress,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.greenAccent)),
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontFamily: Myfont,
                                ),
                                labelText: 'آدرس صنف',
                                enabledBorder: InputBorder.none,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: controllerTags,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.greenAccent)),
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontFamily: Myfont,
                                ),
                                labelText: 'چه خدمات و محصولاتی ارائه میدهی',
                                enabledBorder: InputBorder.none,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                  future: getQuestion(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        is_load == false) {
                      return new Center(
                        child: new CircularProgressIndicator(
                          color: secColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Container();
                    } else {
                      return Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            for (var i in questionCategory)
                              Card(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  margin: EdgeInsets.only(
                                      top: 20, bottom: 20, left: 10, right: 10),
                                  width: double.infinity,
                                  child: TextField(
                                    controller: i['controller'],
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.greenAccent)),
                                      labelStyle: TextStyle(
                                          fontFamily: Myfont,
                                          color: Colors.grey,
                                          fontSize: 17),
                                      labelText: i['question'],
                                      enabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
