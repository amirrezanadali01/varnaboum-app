import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:line_icons/line_icon.dart';
import 'package:varnaboomapp/Detail.dart';
import '../mapPage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/base.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class EndRegister extends StatefulWidget {
  const EndRegister(
      {Key? key,
      required this.questionAnswer,
      required this.AssetImage,
      required this.imageProfile})
      : super(key: key);

  final List<Map> questionAnswer;
  final List AssetImage;
  final CroppedFile? imageProfile;

  @override
  _EndRegisterState createState() => _EndRegisterState();
}

class _EndRegisterState extends State<EndRegister> {
  String idCategory = registerInformationShop['category'];

  late bool isMap;
  bool is_load = false;

  late dio.FormData formdata;

  late List<Map> questionAnswer;
  late List asstImages;
  late CroppedFile? imageProfile;

  XFile? video;
  late TextEditingController controllerNumber;
  late TextEditingController controllerInstagram;
  late TextEditingController controllerBio;
  late List questionCategory = [];

  bool loadBackButton = true;

  dio.Dio _dio = dio.Dio();

  Future<void> get_video() async {
    final ImagePicker _picker = ImagePicker();
    video = await _picker.pickVideo(source: ImageSource.gallery);

    // Video
    File file = File(video!.path);
    int sizeInBytes = file.lengthSync();
    int sizeInMb = sizeInBytes ~/ (1024 * 1024);
    print('sizzzeeeee movieeeeee $sizeInMb');

    if (sizeInMb <= 5) {
      setState(() {});
    } else {
      print('nooo');
      video = null;
      setState(() {});
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'فایل وارد شده باید کمتر از ۵ مگ باشد',
                  textAlign: TextAlign.right,
                ),
              ));
    }

    //Video
  }

  Future<bool> getQuestion() async {
    if (is_load == false) {
      await updateToken(context);

      var boxToken = await Hive.openBox('token');

      String access = boxToken.get('access');
      http.Response questions = await http.get(
          Uri.parse('$host/api/retryQuestionOptional/$idCategory'),
          headers: <String, String>{'Authorization': 'Bearer $access'});

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
    setState(() {});
  }

  @override
  void initState() {
    questionAnswer = widget.questionAnswer;
    asstImages = widget.AssetImage;
    imageProfile = widget.imageProfile;

    print('fffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    print(registerInformationShop['lat']);
    print('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');

    if (registerInformationShop.containsKey('lat')) {
      print('ffffffffffffffffffffffffffffff');

      isMap = true;
      setState(() {});
    } else {
      isMap = false;
    }

    controllerNumber = TextEditingController();
    controllerInstagram = TextEditingController();
    controllerBio = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (loadBackButton == true) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: flColor,
            child: Icon(Icons.done),
            onPressed: () async {
              loadBackButton = false;
              if (controllerBio.text.isNotEmpty) {
                registerInformationShop['bio'] = controllerBio.text;
              }
              if (controllerNumber.text.isNotEmpty) {
                registerInformationShop['number'] = controllerNumber.text;
              }

              EasyLoading.show(status: 'منتظر بمانید ...');

              updateToken(context);
              var boxToken = await Hive.openBox('token');
              String access = boxToken.get('access');

              registerInformationShop['user'] = access;

              for (var i in questionCategory) {
                if (i['controller'].text.isNotEmpty)
                  questionAnswer.add({
                    'question': i['id'].toString(),
                    'answer': i['controller'].text,
                    'user': access
                  });
              }

              String fileNameProfile =
                  imageProfile?.path.split('/').last as String;

              if (video == null) {
                formdata = dio.FormData.fromMap({
                  "InfoUser": json.encode(registerInformationShop),
                  "AnswerQuestion": json.encode(questionAnswer),
                  "ImageStore": asstImages,
                  "Profile": await MultipartFile.fromFile(
                      imageProfile?.path as String,
                      filename: fileNameProfile.toEnglishDigit()),
                });
              } else {
                String fileNameVideo = video?.path.split('/').last as String;
                formdata = dio.FormData.fromMap({
                  "InfoUser": json.encode(registerInformationShop),
                  "AnswerQuestion": json.encode(questionAnswer),
                  "ImageStore": asstImages,
                  "Profile": await MultipartFile.fromFile(
                      imageProfile?.path as String,
                      filename: fileNameProfile.toEnglishDigit()),
                  "Vido": await MultipartFile.fromFile(video?.path as String,
                      filename: fileNameVideo.toEnglishDigit()),
                });
              }

              _dio.options.headers['content-Type'] = 'application/json';
              _dio.options.headers['Authorization'] = 'Bearer $access';

              print(registerInformationShop);

              var response =
                  await _dio.post("$host/api/registerShop/", data: formdata);

              EasyLoading.dismiss();

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: baseWidget())));

              //fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffklj
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
                        onTap: () => get_video(),
                        child: Column(
                          children: [
                            Icon(Icons.movie,
                                size: 30,
                                color: video?.path != null
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent),
                            Text('تیزر',
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    color: video?.path != null
                                        ? Colors.greenAccent
                                        : Colors.orangeAccent)),
                          ],
                        ),
                      ),
                      VerticalDivider(width: 50, color: Colors.black),
                      GestureDetector(
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: TextField(
                                  controller: controllerInstagram,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.pinkAccent)),
                                    labelStyle: TextStyle(
                                        fontFamily: Myfont,
                                        color: Colors.grey,
                                        fontSize: 17),
                                    labelText: 'نام کاربری اینستاگرام',
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                                content: Text(''),
                                actions: [
                                  OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: secColor),
                                      ),
                                      child: Text(
                                        'ذخیره',
                                        style: TextStyle(fontFamily: Myfont),
                                      ),
                                      onPressed: () => setState(() {
                                            print(
                                                'mmmmmmmmmmmmmmmmmmmmmmmmmmmmm');
                                            Navigator.pop(context);
                                            registerInformationShop[
                                                    'instagram'] =
                                                controllerInstagram.text;
                                          })),
                                ],
                              );
                            }),
                        child: Column(
                          children: [
                            (LineIcon.instagram(
                                size: 30,
                                color: controllerInstagram.text.isEmpty
                                    ? Colors.orangeAccent
                                    : Colors.greenAccent)),
                            Text(
                              'اینستاگرام',
                              style: TextStyle(
                                  fontFamily: Myfont,
                                  color: controllerInstagram.text.isEmpty
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent),
                            )
                          ],
                        ),
                      ),
                      VerticalDivider(width: 50, color: Colors.black),
                      GestureDetector(
                        onTap: () async {
                          final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: mapRegister())));

                          setState(() {});
                        },
                        child: Column(
                          children: [
                            Icon(Icons.location_on,
                                size: 30,
                                color: registerInformationShop['lat'] != null
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent),
                            Text('نقشه',
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    color:
                                        registerInformationShop['lat'] != null
                                            ? Colors.greenAccent
                                            : Colors.orangeAccent))
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
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: controllerBio,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.greenAccent)),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17,
                                    fontFamily: Myfont,
                                  ),
                                  labelText: 'درباره ما',
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
                                controller: controllerNumber,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.greenAccent)),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17,
                                    fontFamily: Myfont,
                                  ),
                                  labelText: 'شماره تماس',
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
                    children: [],
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
                                        top: 20,
                                        bottom: 20,
                                        left: 10,
                                        right: 10),
                                    width: double.infinity,
                                    child: TextField(
                                      controller: i['controller'],
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.greenAccent)),
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 17,
                                          fontFamily: Myfont,
                                        ),
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
      ),
    );
  }
}




// i['question']