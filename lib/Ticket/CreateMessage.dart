import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';

class CreateMessage extends StatefulWidget {
  CreateMessage({Key? key, required this.ticket, required this.isOffice})
      : super(key: key);

  final int ticket;
  final bool isOffice;

  @override
  State<CreateMessage> createState() => _CreateMessageState();
}

class _CreateMessageState extends State<CreateMessage> {
  final _keyForm = GlobalKey<FormState>();
  XFile? image = null;
  XFile? video = null;
  TextEditingController textController = TextEditingController();
  bool loadBackButton = true;

  dio.Dio _dio = dio.Dio();

  Future<void> getImage() async {
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000, imageQuality: 85);

    setState(() {});
  }

  Future<void> getVideo() async {
    final ImagePicker _picker = ImagePicker();
    video = await _picker.pickVideo(source: ImageSource.gallery);

    // Video
    if (video != null) {
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
    }
  }

  Future<int?> createChat() async {
    loadBackButton = false;
    EasyLoading.show(status: 'منتظر بمانید ...');
    if (video == null && image == null && textController.text.isEmpty) {
      print('heeeeerrrrrrr');
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text('پیام خالی است'),
                ),
              ));
    } else {
      Map<String, dynamic> data = {'ticket': widget.ticket};
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');

      if (textController.text.isNotEmpty) {
        data['text'] = textController.text;
      }
      if (image != null) {
        String fileNameImage = image?.path.split('/').last as String;
        data['image'] = await MultipartFile.fromFile(image?.path as String,
            filename: fileNameImage.toEnglishDigit());
      }

      if (video != null) {
        String fileNameVideo = video?.path.split('/').last as String;
        data['video'] = await MultipartFile.fromFile(video?.path as String,
            filename: fileNameVideo.toEnglishDigit());
      }

      dio.FormData formdata = dio.FormData.fromMap(data);
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      var response =
          await _dio.post("$host/api/CreateMessage/", data: formdata);

      EasyLoading.showSuccess('پیام با موفقیت ثبت شد');
      return response.statusCode;
    }
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
        appBar: AppBar(backgroundColor: primaryColor),
        floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          onPressed: () async {
            if (_keyForm.currentState!.validate()) {
              int? codeStatus = await createChat();

              if (codeStatus == 201) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: baseWidget())));

                // Navigator.pop(context);
              } else {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(
                            'لطفا چند دقیقه بعد دوباره امتحان کنید',
                            textDirection: TextDirection.rtl,
                          ),
                        ));
              }
            }
          },
          child: Icon(Icons.done),
        ),
        body: Form(
          key: _keyForm,
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: getImage,
                                icon: Icon(
                                  Icons.photo,
                                  color: image == null
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent,
                                  size: 4.h,
                                )),
                            Text(
                              'تصویر',
                              style: TextStyle(
                                  color: image == null
                                      ? Colors.orangeAccent
                                      : Colors.green),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          IconButton(
                            onPressed: getVideo,
                            icon: Icon(
                              Icons.movie,
                              size: 4.h,
                              color: video == null
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent,
                            ),
                          ),
                          Text(
                            'فیلم',
                            style: TextStyle(
                              color: video == null
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent,
                            ),
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: textController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "این فیلد نمتواند خالی باشد";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    labelText: 'متن پیام',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
