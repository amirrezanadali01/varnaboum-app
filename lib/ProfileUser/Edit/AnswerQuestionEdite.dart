import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:varnaboomapp/base.dart';
import '../../Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class EditeAnswer extends StatefulWidget {
  const EditeAnswer({Key? key, required this.id, required this.answer})
      : super(key: key);

  final int id;
  final String answer;

  @override
  _EditeAnswerState createState() => _EditeAnswerState();
}

class _EditeAnswerState extends State<EditeAnswer> {
  dio.Dio _dio = dio.Dio();

  late TextEditingController controller;

  Future<void> UpdateAnswer() async {
    EasyLoading.show(status: 'منتظر بمانید ...');

    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    print(controller.text);

    dio.FormData formdata = dio.FormData.fromMap({'answer': controller.text});

    print(widget.id);
    print(controller.text);

    var response =
        await _dio.put("$host/api/UpdateAnswer/${widget.id}/", data: formdata);

    print('mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm');

    if (response.statusCode == 200) {
      print('fffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
      print(controller.text);
      print(response.statusCode);
      print(widget.id);
      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                  textDirection: TextDirection.rtl, child: baseWidget())));
    }

    EasyLoading.dismiss();
  }

  @override
  void initState() {
    controller = TextEditingController(text: widget.answer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(onPressed: () => UpdateAnswer(), icon: Icon(Icons.done))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          autofocus: true,
          controller: controller,
        ),
      ),
    );
  }
}
