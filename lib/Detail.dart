import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/FirstLogin/loginpage.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';
import 'base.dart';
import 'package:path_provider/path_provider.dart';

String host = 'https://varnaboum.com';

int versionUpdate = 1;

// Colors alll

Color primaryColor = Color(0xFF008594);
Color secColor = Color(0xFF149694);
Color flColor = Color(0xFF400CCCB); // FloatingActionColor

Color labelBorderColor = Colors.greenAccent; // انجام نشده
Color gradint1 = Color(0xff00a6a6);
Color gradint2 = Color(0xff006d84);
Color buttonLogin = Colors.blueGrey;

// HEELLELELELELELELLLELELEL
const Myfont = 'Iran-Sans';

/// Property City
class CityModel {
  CityModel({required this.id, required this.name});

  final int id;
  final String name;
}

class VillageModel {
  VillageModel({required this.id, required this.name});

  final int id;
  final String name;
}

// Property Store
class ItemShop {
  ItemShop(
      {required this.id,
      required this.address,
      required this.name,
      required this.subcategory,
      required this.image});

  final int id;
  final String name;
  final List subcategory;
  final String image;
  final String address;
}

Future<void> loginToken(context,
    {required String username, required String password}) async {
  await EasyLoading.show(status: 'منتظر بمانید ...');

  try {
    http.Response hh = await http.post(
      Uri.parse('$host/api/token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username.toString(),
        'password': password
      }),
    );

    var refreshToken = jsonDecode(hh.body)['refresh'];
    var accessToken = jsonDecode(hh.body)['access'];

    print(hh.body);
    print(hh.statusCode);

    if (hh.statusCode == 200) {
      var box = await Hive.box('token');
      box.put('access', accessToken);
      box.put('refresh', refreshToken);

      EasyLoading.dismiss();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Directionality(
              textDirection: TextDirection.rtl, child: baseWidget());
        }),
      );
    } else {
      EasyLoading.dismiss();
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('نام کاربری یا گذرواژه اشتباه است'),
              ));
    }
  } catch (e) {
    EasyLoading.dismiss();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('خطای اتصال'),
            ));
  }
}

Future<void> updateToken(context) async {
  await Hive.initFlutter();
  var boxToken = await Hive.openBox('token');
  String refresh = boxToken.get('refresh');
  String access = boxToken.get('access');

  http.Response verify_token = await http.post(
    Uri.parse('$host/api/token/verify/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'token': access}),
  );

  print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
  print(verify_token.statusCode);
  print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');

  if (verify_token.statusCode == 401) {
    http.Response hh = await http.post(
      Uri.parse('$host/api/token/refresh/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'refresh': refresh}),
    );

    print('noooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');
    print(hh.body);
    if (hh.statusCode == 401) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => login()));
    }
    print('noooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');

    if (jsonDecode(hh.body)['access'] == null || hh.statusCode == 401) {
      print(
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
      await Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => login()));

      print(
          'TokenTokenTokenTokenTokenTokenTokenTokenTokenTokenTokenTokenTokenToken');
    } else {
      boxToken.put('access', jsonDecode(hh.body)['access']);
    }
  }
  // else {
  //   print('is valied');
  // }
}

/// Property Category
class CategoriesItem {
  const CategoriesItem(
      {Key? key,
      required this.name,
      required this.image,
      required this.id,
      required this.subtitle});

  final String name;
  final String image;
  final int id;
  final List subtitle;
}

Map registerInformationShop = {};

Map postProduct = {};

class InputTextPost extends StatelessWidget {
  const InputTextPost(
      {Key? key,
      required this.controllerName,
      required this.name,
      this.maxlenght = null,
      this.typeKeyboard = TextInputType.multiline})
      : super(key: key);

  final TextEditingController controllerName;
  final String name;
  final TextInputType typeKeyboard;
  final int? maxlenght;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextField(
        keyboardType: typeKeyboard,
        controller: controllerName,
        inputFormatters: maxlenght == null
            ? null
            : [
                LengthLimitingTextInputFormatter(maxlenght),
              ],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15.0),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent)),
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: 17,
            fontFamily: Myfont,
          ),
          labelText: name,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class TemplateItem extends StatelessWidget {
  final String image;
  final String c1;
  final String? c2;

  TemplateItem(
      {Key? key,
      required this.image,
      required this.c1,
      required this.c2,
      this.isNews = false})
      : super(key: key);

  bool isNews;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shadowColor: secColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: 5,
                    ),
                    child: Text(c1,
                        style: TextStyle(
                            fontFamily: Myfont, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right),
                  ),
                  if (c2 != null)
                    Container(
                        margin: EdgeInsets.only(top: 5, right: 4),
                        child: Text(c2!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isNews == true ? Colors.grey : null,
                              fontFamily: Myfont,
                            ),
                            textAlign: TextAlign.right))
                ],
              ),
            ),
            Container(
                height: 12.h,
                width: 23.w,
                child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child:
                        Image(fit: BoxFit.cover, image: NetworkImage(image)))),
          ],
        ),
      ),
    );
  }
}

double CalculateScale(context) {
  late double scale;

  if (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height) {
    scale = MediaQuery.of(context).size.width;
  } else {
    scale = MediaQuery.of(context).size.height;
  }
  double sizeHeight = (scale * 9) / 16;

  return sizeHeight;
}

class TemplateNewses extends StatefulWidget {
  final String image;
  final String titr;
  final String office;
  final String city;
  final String categoty;
  final String text;
  final String? video;

  TemplateNewses(
      {Key? key,
      required this.image,
      required this.titr,
      required this.city,
      required this.categoty,
      required this.office,
      required this.text,
      this.video})
      : super(key: key);

  @override
  State<TemplateNewses> createState() => _TemplateNewsesState();
}

class _TemplateNewsesState extends State<TemplateNewses> {
  Future<void> shareNews(file, text, title) async {
    final uri = Uri.parse(file);
    final response = await http.get(uri);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/NewsVarnaboom.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path], text: '$title \n\n $text', subject: title);
  }

  bool isMore = false;

  late String image;

  @override
  void initState() {
    image = widget.image.replaceAll('$host', '');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shadowColor: secColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          right: 4,
                          top: 5,
                        ),
                        child: Text(widget.titr,
                            style: TextStyle(
                                fontFamily: Myfont,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              widget.office,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              widget.city,
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              widget.categoty,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isMore = !isMore;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('متن خبر',
                                  style: TextStyle(color: Colors.blueAccent)),
                              IconButton(
                                onPressed: () async {
                                  await shareNews("$host${image}", widget.text,
                                      widget.titr);
                                },
                                icon:
                                    Icon(Icons.share, color: Colors.blueAccent),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 12.h,
                    width: 23.w,
                    child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                "$host${image}")))), // hhhhhhhhhrrrrrrrrrrrrrr
              ],
            ),
            if (isMore == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.video != null)
                      SampleVideoRetryProfile(
                        url: widget.video as String,
                        height: 25,
                      ),
                    if (widget.video != null) SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class TemplateBubble extends StatelessWidget {
  const TemplateBubble(
      {Key? key,
      required this.isMe,
      required this.video,
      required this.image,
      required this.text})
      : super(key: key);

  final bool isMe;
  final String? text;
  final String? image;
  final String? video;

  @override
  Widget build(BuildContext context) {
    if (isMe == true) {
      return Bubble(
        // #E8E8EE
        color: Color(0xFFE8E8EE),
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topRight,
        nip: BubbleNip.rightCenter,
        child: SizedBox(
          //text != null ? (text!.length + 13).w : null,
          width: image != null && video != null
              ? 50.w
              : image != null || video != null
                  ? 50.w
                  : text != null
                      ? (text!.length + 13).w
                      : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null)
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Image(image: NetworkImage(image!))),
              if (video != null) SampleVideoPlayerBubble(url: video!),
              SizedBox(
                height: 5.sp,
              ),
              if (text != null) Text(text!)
            ],
          ),
        ),
      );
    } else {
      return Bubble(
        margin: BubbleEdges.only(top: 10),
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftCenter,
        color: Colors.blue,
        child: SizedBox(
          //text != null ? (text!.length + 13).w : null,
          width: image != null && video != null
              ? 50.w
              : image != null || video != null
                  ? 50.w
                  : text != null
                      ? (text!.length + 13).w
                      : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null)
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Image(image: NetworkImage(image!))),
              if (video != null) SampleVideoPlayerBubble(url: video!),
              SizedBox(
                height: 5.sp,
              ),
              if (text != null)
                Text(text!,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      );
    }
  }
}

//  return Bubble(
//         margin: BubbleEdges.only(top: 10),
//         alignment: Alignment.topLeft,
//         nip: BubbleNip.leftCenter,
//         color: Colors.blue,
//         child: Text(
//           text!,
//           textAlign: TextAlign.right,
//           style: TextStyle(color: Colors.white),
//         ),
//       );
