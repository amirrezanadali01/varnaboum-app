import 'dart:convert';

import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/RegisterProduct/estate/EndPostEstate.dart';

class PostTypeEstate extends StatefulWidget {
  PostTypeEstate({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<PostTypeEstate> createState() => _PostTypeEstateState();
}

class _PostTypeEstateState extends State<PostTypeEstate> {
  Future<List> getTypeEstate() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetTypeEstate/${widget.type}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print('$host/api/GetTypeEstate/${widget.type}/');

    List json = jsonDecode(utf8.decode(result.bodyBytes));

    print(widget.type);

    print(json);

    return json;
  }

  late Future<List> listFuture;
  List<XFile>? multiImageList = [];
  List asstImages = [];
  late MultipartFile preview;

  @override
  void initState() {
    listFuture = getTypeEstate();
    super.initState();
  }

  Future<void> get_ImagePost() async {
    final ImagePicker _picker = ImagePicker();
    multiImageList = await _picker.pickMultiImage();

    // multiImageList =
    //    await _picker.pickMultiImage(maxWidth: 1000, imageQuality: 85);

    //   for (var i in multiImageList ?? []) {
    // String fileNameProfile = i?.path.split('/').last as String;

    // var hi = await MultipartFile.fromFile(i?.path as String,
    //     filename: fileNameProfile.toEnglishDigit());

    // final planetsByDiameter = {"image": hi};

    // asstImages.add(planetsByDiameter);

    if (multiImageList != null) {
      for (var i in multiImageList ?? []) {
        print('here1');
        CroppedFile? imageCropper = await ImageCropper().cropImage(
            maxWidth: 1000,
            compressQuality: 85,
            sourcePath: i!.path,
            aspectRatioPresets: [CropAspectRatioPreset.square]);

        if (imageCropper != null) {
          String fileNameProfile = imageCropper.path.split('/').last;

          var hi = await MultipartFile.fromFile(imageCropper.path,
              filename: fileNameProfile.toEnglishDigit());

          final planetsByDiameter = {"image": hi};

          asstImages.add(planetsByDiameter);

          if (i == multiImageList![0]) {
            preview = await MultipartFile.fromFile(imageCropper.path,
                filename: fileNameProfile.toEnglishDigit());
          }
        }
      }
    }
  }

  int _val = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFAFAFA),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () async {
          await get_ImagePost();

          if (asstImages.isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                          child: EndPostEstate(
                            image: asstImages,
                            preview: preview,
                          ),
                          textDirection: TextDirection.rtl,
                        )));
          }
        },
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ملکتون در کدام دسته بندی است؟',
                  style: TextStyle(
                      fontFamily: Myfont, fontWeight: FontWeight.bold),
                ),
              ),
              flex: 0,
            ),
            Expanded(
              child: Card(
                  shadowColor: secColor,
                  child: FutureBuilder<List>(
                      future: listFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return new Center(
                            child: new CircularProgressIndicator(
                              color: secColor,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          print('Error: ${snapshot.error}');
                          return Container();
                        } else {
                          print(
                              'tyyyyyyyyyyyyyyytyyyyyyyyyyyyyyytyyyyyyyyyyyyyyy');
                          print(widget.type);
                          print('$host/api/GetTypeEstate/${widget.type}/');
                          print(snapshot.data);
                          print(
                              'tyyyyyyyyyyyyyyytyyyyyyyyyyyyyyytyyyyyyyyyyyyyyy');
                          postProduct['TypeEstate'] =
                              snapshot.data![_val]['id'];
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(snapshot.data![index]['name'],
                                      style: TextStyle(fontFamily: Myfont)),
                                  leading: Radio(
                                      focusColor: secColor,
                                      activeColor: secColor,
                                      value: index,
                                      groupValue: _val,
                                      onChanged: (_value) {
                                        setState(() {
                                          _val = _value as int;
                                        });
                                        postProduct['TypeEstate'] =
                                            snapshot.data![index]['id'];

                                        print(postProduct);
                                      }),
                                );
                              });
                        }
                      })),
            ),
          ],
        ),
      ),
    );
  }
}
