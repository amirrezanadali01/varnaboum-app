import 'dart:io';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:varnaboomapp/base.dart';
import '../../Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({Key? key, required this.imageProfile, required this.id})
      : super(key: key);

  final int id;
  final XFile imageProfile;

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  dio.Dio _dio = dio.Dio();
  Future<void> UpdateProfile() async {
    EasyLoading.show(status: 'منتظر بمانید ...');

    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    print(registerInformationShop);

    // dio.FormData formdata = dio.FormData.fromMap({
    //   "name": await MultipartFile.fromFile(
    //       widget.imageProfile.path as String,
    //       filename: widget.imageProfile.name),
    // });
    dio.FormData formdata = dio.FormData.fromMap({
      "profile": await MultipartFile.fromFile(widget.imageProfile.path,
          filename: widget.imageProfile.name.toEnglishDigit()),
    });

    var response =
        await _dio.put("$host/api/UpdateInfoUser/${widget.id}", data: formdata);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                  textDirection: TextDirection.rtl, child: baseWidget())));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('خطایی رخ داده است'),
              ));
    }

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(onPressed: () => UpdateProfile(), icon: Icon(Icons.done))
        ],
      ),
      body: Center(
          child: CircleAvatar(
              radius: 100,
              backgroundImage: FileImage(File(widget.imageProfile.path)))),
    );
  }
}
