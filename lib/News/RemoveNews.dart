import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/News/UpdateTextNews.dart';
import 'package:varnaboomapp/base.dart';

import '../ProfileUser/Edit/Movie/ShowMovie.dart';

class RemoveNews extends StatefulWidget {
  RemoveNews(
      {Key? key,
      required this.id,
      required this.titr,
      required this.text,
      this.vide,
      required this.image})
      : super(key: key);
  final int id;
  final String titr;
  final String text;
  final String image;
  String? vide;

  @override
  State<RemoveNews> createState() => _RemoveNewsState();
}

class _RemoveNewsState extends State<RemoveNews> {
  Future<int> removeNewsPfofile() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveNews/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    return result.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: secColor,
          actions: [
            IconButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: Text('میخواهید این خبر کامل حذف کنید؟'),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    EasyLoading.show(
                                        status: 'منتظر بمانید ...');
                                    int code = await removeNewsPfofile();
                                    if (code == 204) {
                                      EasyLoading.dismiss();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: baseWidget())));
                                    } else {
                                      EasyLoading.dismiss();
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'لطفا چند دقیفه دیگر مجدد تلاش بکنید'),
                                            );
                                          });
                                    }
                                  },
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(fontFamily: Myfont),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'انصراف',
                                    style: TextStyle(fontFamily: Myfont),
                                  ))
                            ],
                          ),
                        );
                      });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 25.h,
                child: widget.vide == null
                    ? Card(
                        clipBehavior: Clip.antiAlias,
                        child: Image(
                          image: NetworkImage(widget.image),
                          fit: BoxFit.cover,
                        ))
                    : SampleVideoRetryProfile(
                        url: widget.vide as String,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: UpdateTextNews(
                                field: 'titr',
                                id: widget.id,
                                name: 'تیتر',
                                text: widget.titr,
                              )))),
                  child: Card(
                    child: Text(
                      widget.titr,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: UpdateTextNews(
                                  field: 'text',
                                  id: widget.id,
                                  name: 'متن خبر',
                                  text: widget.text,
                                )))),
                    child: Text(
                      widget.text,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
