import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'package:varnaboomapp/base.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

import '../../Detail.dart';

class ImageShop extends StatefulWidget {
  const ImageShop({Key? key, required this.Images}) : super(key: key);

  final List Images;

  @override
  _ImageShopState createState() => _ImageShopState();
}

class _ImageShopState extends State<ImageShop> {
  List removeImage = [];
  List<XFile>? multiImageList = [];
  dio.Dio _dio = dio.Dio();

  Future<void> addImage() async {
    EasyLoading.show(status: 'منتظر بمانید ...');

    if (multiImageList!.isNotEmpty) {
      for (var i in multiImageList ?? []) {
        await updateToken(context);
        var boxToken = await Hive.openBox('token');
        String access = boxToken.get('access');
        _dio.options.headers['content-Type'] = 'application/json';
        _dio.options.headers['Authorization'] = 'Bearer $access';

        MultipartFile multipartFile = await MultipartFile.fromFile(i.path,
            filename: i.name.toString().toEnglishDigit(),
            contentType: MediaType("image", "png"));

        dio.FormData formdata =
            dio.FormData.fromMap({"imag": multipartFile, "user": access});

        var response =
            await _dio.post("$host/api/CreateShopImage/", data: formdata);

        print(response.statusCode);
      }
    }

    if (removeImage.length != widget.Images.length && removeImage.isNotEmpty) {
      for (var i in removeImage) {
        var boxToken = await Hive.openBox('token');
        await updateToken(context);
        String access = boxToken.get('access');
        _dio.options.headers['content-Type'] = 'application/json';
        _dio.options.headers['Authorization'] = 'Bearer $access';
        _dio.delete("$host/api/RemoveShopImage/$i/delete/");
      }
    }

    EasyLoading.dismiss();
  }

  Future<void> get_MultiImage() async {
    final ImagePicker _picker = ImagePicker();
    multiImageList =
        await _picker.pickMultiImage(maxWidth: 1000, imageQuality: 85);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () async {
              await addImage();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: baseWidget())));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 50),
              child: IconButton(
                  onPressed: get_MultiImage,
                  icon: Icon(
                    Icons.add_a_photo_rounded,
                    size: 60,
                  )),
            ),
            if (multiImageList!.isNotEmpty)
              Text(
                '${multiImageList!.length} عکس اضافه شده',
                style: TextStyle(color: Colors.greenAccent),
              ),
            if (removeImage.isNotEmpty)
              Text(
                '${removeImage.length} عکس حذف شد',
                style: TextStyle(color: Colors.redAccent),
              ),
            for (var i in widget.Images)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Color(0xffeeeeee),
                      child: Image(
                        image: NetworkImage(i['imag']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (removeImage.contains(i['id']) == false) {
                          print(removeImage.contains(i['id']));
                          removeImage.add(i['id']);
                          setState(() {});
                        } else {
                          removeImage.remove(i['id']);
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.remove_circle_sharp,
                        color: Colors.redAccent,
                      ))
                ],
              )
          ],
        ),
      ),
    );
  }
}
