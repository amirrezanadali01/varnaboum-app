import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/base.dart';

class Violation extends StatefulWidget {
  Violation({Key? key, required this.infouser}) : super(key: key);

  final int infouser;

  @override
  State<Violation> createState() => _ViolationState();
}

class _ViolationState extends State<Violation> {
  TextEditingController controller = TextEditingController();
  dio.Dio _dio = dio.Dio();

  Future<void> createViolation() async {
    if (controller.text.isNotEmpty) {
      EasyLoading.show(status: 'منتظر بمانید ...');
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      dio.FormData formdata = dio.FormData.fromMap({
        'infouser': widget.infouser,
        'text': controller.text,
        'user': access
      });

      var response =
          await _dio.post("$host/api/CreateViolation/", data: formdata);

      EasyLoading.dismiss();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                  textDirection: TextDirection.rtl, child: baseWidget())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(
              onPressed: () {
                createViolation();
              },
              icon: Icon(Icons.done))
        ],
      ),
      body: Container(
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.multiline,
              autofocus: true,
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent)),
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontFamily: Myfont,
                ),
                labelText: 'تخلف',
                enabledBorder: InputBorder.none,
              ),
            )
          ],
        ),
      ),
    );
  }
}
