import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/base.dart';
import 'package:dio/dio.dart' as dio;

class UpdateproductAnotherText extends StatefulWidget {
  UpdateproductAnotherText(
      {Key? key,
      required this.field,
      required this.text,
      this.isNumber = false,
      required this.id,
      required this.name})
      : super(key: key);

  final String field;
  final String? text;
  final int id;
  final String name;
  final bool isNumber;

  @override
  State<UpdateproductAnotherText> createState() =>
      _UpdateproductAnotherTextState();
}

class _UpdateproductAnotherTextState extends State<UpdateproductAnotherText> {
  late TextEditingController controller;
  dio.Dio _dio = dio.Dio();

  Future<void> UpdateText() async {
    // EasyLoading.show(status: 'منتظر بمانید ...');

    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    dio.FormData formdata = dio.FormData.fromMap({});

    if (controller.text != '') {
      formdata = dio.FormData.fromMap({
        widget.field: widget.isNumber == true
            ? int.parse(controller.text)
            : controller.text,
      });
    } else {
      formdata = dio.FormData.fromMap({
        widget.field: '',
      });
    }

    print("$host/api/AnotherProductsUpdate/${widget.id}");
    var response = await _dio
        .put("$host/api/AnotherProductsUpdate/${widget.id}", data: formdata);

    print(response.statusCode);
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

    // EasyLoading.dismiss();
  }

  @override
  void initState() {
    print(widget.field);
    if (widget.text == null) {
      controller = TextEditingController();
    } else {
      controller = TextEditingController(text: widget.text);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
        actions: [
          IconButton(
              onPressed: () {
                if (widget.field == 'name' || widget.field == 'price') {
                  if (widget.field.trim() == '') {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('این فیلد نمیتواند خالی باشد'),
                            ));
                  } else {
                    UpdateText();
                  }
                } else {
                  UpdateText();
                }
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
              keyboardType: widget.isNumber == true
                  ? TextInputType.number
                  : TextInputType.multiline,
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
                labelText: widget.name,
                enabledBorder: InputBorder.none,
              ),
            )
          ],
        ),
      ),
    );
  }
}
