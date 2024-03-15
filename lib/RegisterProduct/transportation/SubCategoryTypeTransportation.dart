import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/RegisterProduct/transportation/ProductsTransportationEnd.dart';

class SubCategoryTypeTransportation extends StatefulWidget {
  SubCategoryTypeTransportation({Key? key, required this.categoryType})
      : super(key: key);

  final int categoryType;

  @override
  State<SubCategoryTypeTransportation> createState() =>
      _SubCategoryTypeTransportationState();
}

class _SubCategoryTypeTransportationState
    extends State<SubCategoryTypeTransportation> {
  Future<List> getSubCategorys() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetSubTypeTransportation/${widget.categoryType}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List json = jsonDecode(utf8.decode(result.bodyBytes));

    return json;
  }

  List<XFile>? multiImageList = [];
  List asstImages = [];
  late MultipartFile preview;
  late Future<List> listFuture;

  @override
  void initState() {
    listFuture = getSubCategorys();
    super.initState();
  }

  int _val = 0;
  late List categorys;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFFFAFAFA),
          leading: BackButton(
            color: Colors.black,
          )),
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
                          child: ProductsTransportationEnd(
                            image: asstImages,
                            preview: preview,
                          ),
                          textDirection: TextDirection.rtl,
                        )));
          }
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'دسته بندی سواری خود را انتخاب کنید',
                style:
                    TextStyle(fontFamily: Myfont, fontWeight: FontWeight.bold),
              ),
            ),
            flex: 0,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: Card(
                shadowColor: secColor,
                child: FutureBuilder<List>(
                    future: listFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return new Center(
                          child: new CircularProgressIndicator(
                            color: secColor,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Container();
                      } else {
                        if (snapshot.data![_val] != null) {
                          postProduct['SubTypeTransportation'] =
                              snapshot.data![_val]['id'];
                        }

                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
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

                                        postProduct['SubTypeTransportation'] =
                                            snapshot.data![_val]['id'];

                                        print(postProduct);
                                      });
                                    }),
                              );
                            }));
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
