import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:varnaboomapp/base.dart';
import 'package:video_player/video_player.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

class EditeVideo extends StatefulWidget {
  const EditeVideo({Key? key, required this.video, required this.id})
      : super(key: key);
  final XFile video;
  final int id;

  @override
  _EditeVideoState createState() => _EditeVideoState();
}

class _EditeVideoState extends State<EditeVideo> {
  late FlickManager flickManager;

  dio.Dio _dio = dio.Dio();

  bool loadBackButton = true;

  Future<void> UpdateVideo() async {
    loadBackButton = false;
    EasyLoading.show(status: 'منتظر بمانید ...');
    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    dio.FormData formdata = dio.FormData.fromMap({
      "video": await MultipartFile.fromFile(widget.video.path as String,
          filename: widget.video.name.toEnglishDigit())
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
  void initState() {
    super.initState();
    print(widget.video);
    flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.file(File(widget.video.path)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: secColor,
          actions: [
            IconButton(onPressed: () => UpdateVideo(), icon: Icon(Icons.done))
          ],
        ),
        body: Center(
          child: Container(
            height: 300,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: FlickVideoPlayer(flickManager: flickManager),
            ),
          ),
        ),
      ),
    );
  }
}
