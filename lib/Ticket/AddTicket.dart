import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';

class AddTicket extends StatefulWidget {
  AddTicket({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<AddTicket> createState() => _AddTicketState();
}

class _AddTicketState extends State<AddTicket> {
  final _keyForm = GlobalKey<FormState>();
  String titleType = 'انتقادات و پیشنهادات';
  int _type = 1;
  XFile? image = null;
  dio.Dio _dio = dio.Dio();
  XFile? video = null;
  bool loadBackButton = true;
  TextEditingController titrController = TextEditingController();
  TextEditingController textController = TextEditingController();

  int _Personal = 0;
  late int idPersonal;

  Future<List> getPersonalOffice() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    print('$host/api/GetListPersonalOffice/${widget.id}/');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetListPersonalOffice/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List decodeList = jsonDecode(utf8.decode(result.bodyBytes));

    decodeList.insert(0, {'id': -1, 'name': 'انتخاب کنید(مخاطب)'});

    idPersonal = decodeList[0]['id'];

    print(decodeList);

    return decodeList;
  }

  late Future<List> getPersonal;

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

    //Video
  }

  Future<int?> submitTicket() async {
    loadBackButton = false;
    EasyLoading.show(status: 'منتظر بمانید ...');
    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    Map message = {};
    Map ticketMap = {'name': titrController.text, 'office': widget.id};
    message['text'] = textController.text;

    if (_type == 2) {
      ticketMap['personal'] = idPersonal;
      ticketMap['typeask'] = 'complaint';
    } else {
      ticketMap['typeask'] = 'criticism';
    }

    Map<String, dynamic> data = {
      'ticket': json.encode(ticketMap),
      'message': json.encode(message),
    };

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

    var response = await _dio.post("$host/api/CreateTicket/", data: formdata);

    EasyLoading.dismiss();

    return response.statusCode;
  }

  @override
  void initState() {
    getPersonal = getPersonalOffice();
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
          onPressed: () async {
            print(_type);
            print(idPersonal);
            if (_type == 2 && idPersonal == -1) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                          'لطفا مخاطب انتخاب کنید',
                          textAlign: TextAlign.right,
                        ),
                      ));
            } else {
              print('hiiii');
              if (_keyForm.currentState!.validate()) {
                int? codeStatus = await submitTicket();

                if (codeStatus == 201) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: baseWidget())));
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
            }
          },
          child: Icon(Icons.done),
        ),
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: Form(
          key: _keyForm,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                if (_type == 1)
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.yellow.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                            'این پیام تمام اعضای اداره میتوانند ببیند. \nپس از اتمام تیکت این پیام تمام کاربران میبینند.'),
                      ),
                    ),
                  ),
                if (_type == 2)
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                            'این پیام را فقط مسئول مربوطه می تواند رویت کند'),
                      ),
                    ),
                  ),
                SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 50, right: 50),
                      child: OutlinedButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  content:
                                      StatefulBuilder(builder: (context, stat) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Text('انتقادات و پیشنهادات'),
                                            leading: Radio<int>(
                                              focusColor: secColor,
                                              activeColor: secColor,
                                              value: 1,
                                              groupValue: _type,
                                              onChanged: (value) {
                                                setState(() {
                                                  _type = value as int;
                                                  titleType =
                                                      'انتقادات و پیشنهادات';
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                          ListTile(
                                            title: Text('شکایات'),
                                            leading: Radio<int>(
                                              focusColor: secColor,
                                              activeColor: secColor,
                                              value: 2,
                                              groupValue: _type,
                                              onChanged: (value) {
                                                setState(() {
                                                  _type = value as int;
                                                  titleType = 'شکایات';
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                )),
                        child: Text(
                          titleType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )),
                if (_type == 2)
                  FutureBuilder<List>(
                      future: getPersonal,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return new Center(
                            child: new CircularProgressIndicator(
                              color: secColor,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return new Text('Error: ${snapshot.error}');
                        } else {
                          return SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 50, right: 50),
                                child: OutlinedButton(
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            content: StatefulBuilder(
                                                builder: (context, stat) {
                                              return SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    for (int i = 0;
                                                        i <
                                                            snapshot
                                                                .data!.length;
                                                        i++)
                                                      ListTile(
                                                        title: Text(snapshot
                                                            .data![i]['name']),
                                                        leading: Radio<int>(
                                                          focusColor: secColor,
                                                          activeColor: secColor,
                                                          groupValue: _Personal,
                                                          value: i,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _Personal =
                                                                  value as int;
                                                              Navigator.pop(
                                                                  context);
                                                            });

                                                            idPersonal =
                                                                snapshot.data![
                                                                    i]['id'];
                                                          },
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )),
                                  child: Text(
                                    snapshot.data![_Personal]['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                Padding(
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
                      // Expanded(
                      //     child: Column(
                      //   children: [
                      //     IconButton(
                      //       onPressed: getVideo,
                      //       icon: Icon(
                      //         Icons.movie,
                      //         size: 4.h,
                      //         color: video == null
                      //             ? Colors.orangeAccent
                      //             : Colors.greenAccent,
                      //       ),
                      //     ),
                      //     Text(
                      //       'فیلم',
                      //       style: TextStyle(
                      //         color: video == null
                      //             ? Colors.orangeAccent
                      //             : Colors.greenAccent,
                      //       ),
                      //     )
                      //   ],
                      // )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: titrController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "این فیلد نمتواند خالی باشد";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'عنوان پیام',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Padding(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
