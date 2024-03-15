// import 'package:dio/dio.dart' as dio;
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:multi_image_picker2/multi_image_picker2.dart';
// import 'package:path/path.dart';
// import 'package:async/async.dart';
// import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';

// import 'Detail.dart';
// import 'package:flutter/material.dart';
// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:video_player/video_player.dart';

// class TestImage extends StatefulWidget {
//   @override
//   _TestImageState createState() => _TestImageState();
// }

// class _TestImageState extends State<TestImage> {
//   List multiImageLis = [];
//   dio.Dio _dio = dio.Dio();

//   Future<void> get_MultiImage() async {
//     multiImageLis = await MultiImagePicker.pickImages(
//       maxImages: 300,
//       enableCamera: true,
//       materialOptions: MaterialOptions(
//         actionBarTitle: "FlutterCorner.com",
//       ),
//     );

//     // multiImageLis = await FilePicker.platform.pickFiles(
//     //   allowMultiple: true,
//     //   type: FileType.custom,
//     //   allowedExtensions: ['jpg', 'pdf', 'doc'],
//     // ) as FilePickerResult;

//     //aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
//   }

//   Future<void> uploadImage(Asset file) async {
//     ByteData bytedata = await file.getByteData();
//     List<int> imageData = bytedata.buffer.asUint8List();

//     print(imageData);

//     MultipartFile multipartFile = MultipartFile.fromBytes(imageData,
//         filename: file.name, contentType: MediaType("image", "png"));

//     dio.FormData formdata =
//         dio.FormData.fromMap({"imag": multipartFile, "user": 1});

//     print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
//     var response = await _dio.post("$host/api/TestImage/", data: formdata);

//     print('jjjjjjjjjjjjjjjjjjjjj');
//     print(response.statusCode);
//   }

//   // Future<void> gettttttt(Asset pathFile) async {
//   //   //create multipart request for POST or PATCH method
//   //   var request =
//   //       await http.MultipartRequest("POST", Uri.parse("$host/api/TestImage/"));
//   //   print(request.fields);

//   //   ByteData bytedata = await pathFile.getByteData();
//   //   List<int> imageData = bytedata.buffer.asUint8List();
//   //   //add text fields
//   //   request.fields["name"] = 'hiiiii';
//   //   //create multipart using filepath, string or bytes

//   //   http.MultipartFile pic = http.MultipartFile.fromBytes('icon', imageData,
//   //       filename: pathFile.name, contentType: MediaType("image", "jpeg"));

//   //   print('----------------------------------------------');
//   //   print(pic);
//   //   print('###################################');

//   //   // //add multipart to request
//   //   await request.send().then((response) {
//   //     if (response.statusCode != 200) print(response.statusCode);
//   //   });

//   //   print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');

//   //   // // //Get the response from the server
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       children: [
//         GestureDetector(
//           child: Container(width: 100, height: 100, color: Colors.red),
//           onTap: () => get_MultiImage(),
//         ),
//         GestureDetector(
//             child: Container(width: 100, height: 100, color: Colors.blue),
//             onTap: () {
//               uploadImage(multiImageLis[0]);
//             }),
//       ],
//     ));
//   }
// }

// class SamplePlayer extends StatefulWidget {
//   @override
//   _SamplePlayerState createState() => _SamplePlayerState();
// }

// class _SamplePlayerState extends State<SamplePlayer> {
//   late FlickManager flickManager;
//   @override
//   void initState() {
//     super.initState();
//     flickManager = FlickManager(
//       videoPlayerController: VideoPlayerController.network(
//           "https://varnaboum.com/media/Trailer/81e5ea1c14f0a9e5164bde02b1898d0e38322858-144p.mp4"),
//     );
//   }

//   @override
//   void dispose() {
//     flickManager.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: FlickVideoPlayer(flickManager: flickManager),
//       ),
//     );
//   }
// }

