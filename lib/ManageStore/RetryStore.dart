import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varnaboomapp/Category/Products/AnotherProductsRetry.dart';
import 'package:varnaboomapp/ProfileUser/violation.dart';
import 'package:varnaboomapp/base.dart';
import '../../Detail.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:line_icons/line_icon.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';

class RetryStore extends StatefulWidget {
  RetryStore({Key? key, required this.id, required this.name})
      : super(key: key);

  final int id;
  final String name;

  @override
  State<RetryStore> createState() => _RetryStoreState();
}

class _RetryStoreState extends State<RetryStore> {
  dio.Dio _dio = dio.Dio();
  Future<void> UpdateDoneStore() async {
    EasyLoading.show(status: 'منتظر بمانید ...');

    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    print(registerInformationShop);

    dio.FormData formdata = dio.FormData.fromMap({"Confirmation": true});

    var response = await _dio.put(
        "$host/api/UpdateInfoUserManagerStore/${widget.id}/",
        data: formdata);

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

  Future<void> removeStore() async {
    EasyLoading.show(status: 'منتظر بمانید ...');
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    print(
        'deletedeletedeletedeletedeletedeletedeletedeletedeletedeletedeletedelete');
    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveStoreInfouserManager/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);
    print(
        'deletedeletedeletedeletedeletedeletedeletedeletedeletedeletedeletedelete');

    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Directionality(
    //             textDirection: TextDirection.rtl, child: baseWidget())));
  }

  Future<void> removeStoreImage() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    print(
        'deletedeletedeletedeletedeletedeletedeletedeletedeletedeletedeletedelete');
    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveImageShopManagerStore/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);
    print(
        'deletedeletedeletedeletedeletedeletedeletedeletedeletedeletedeletedelete');

    EasyLoading.dismiss();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl, child: baseWidget())));
  }

  late List<String> shopImage;
  late Map<String, dynamic> infoUser;
  late List answerUser;
  List<Widget> option = [];

  List itemProducts = [];

  late Timer _timer;
  int _currentPage = 0;
  PageController pageviewcontroller = PageController();

  late String? nextpageUrl;

  Future<bool> GetShopImage(id) async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/ImageShop/$id'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    a.forEach((element) {
      shopImage.add(element['imag']);
    });

    if (result.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  late String categoryName;

  Future<bool> GetInfoUser(id) async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/InfoUser/$id'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    if (a.length > 0) infoUser = a[0];

    if (result.statusCode == 200) {
      if (a[0]['lat'] != null) {
        option.add(
          IconButton(
              icon: Icon(
                Icons.location_on,
                size: 4.20.h,
                color: Colors.redAccent,
              ),
              onPressed: () async => {
                    print(
                        "geo:https://www.google.com/maps/@${a[0]['lat']},${a[0]['lng']}"),
                    await launch("geo:${a[0]['lat']},${a[0]['lng']}")
                  }),
        );
      }

      if (a[0]['number'] != null) {
        option.add(
          IconButton(
            icon: Icon(
              Icons.phone,
              size: 4.20.h,
              color: Colors.greenAccent,
            ),
            onPressed: () async => {await launch("tel:+98${a[0]['number']}")},
          ),
        );
      }

      if (a[0]['video'] != null) {
        option.add(
          IconButton(
            icon: Icon(
              Icons.movie,
              size: 4.20.h,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SampleVideoRetryProfile(
                      url: infoUser['video'],
                    );
                  });
            },
          ),
        );
      }

      if (a[0]['instagram'] != null && a[0]['instagram'] != '') {
        option.add(IconButton(
            icon: LineIcon.instagram(
              size: 4.20.h,
              color: Colors.pinkAccent,
            ),
            onPressed: () async {
              print('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
              print(a[0]['instagram']);
              print('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');

              String result = a[0]['instagram'].replaceAll('@', '');

              await launch("https://www.instagram.com/${result}/");
            }));
      }

      print("CATEGORY IIII ${a[0]} ");

      categoryName = a[0]['CategoryName'];

      return true;
    } else {
      return false;
    }
  }

  Future<bool> GetAnswerQuestion(id) async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/AnswerUser/$id'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    answerUser = a;

    if (result.statusCode == 200) {
      return true;
    } else {
      print('fffffffffffffffffffffffffffffffffffffffffff');
      return false;
    }
  }

  late Future getReady;

  Future<bool> ready() async {
    await updateToken(context);
    final a = await GetInfoUser(widget.id);
    final b = await GetShopImage(widget.id);
    final c = await GetAnswerQuestion(widget.id);

    if (a == true && b == true && c == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    shopImage = [];
    infoUser = {};
    answerUser = [];

    getReady = ready();

    super.initState();

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (pageviewcontroller.hasClients) {
        if (_currentPage < shopImage.length) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        pageviewcontroller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 700),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.name,
            style: TextStyle(
                fontSize: 18, fontFamily: Myfont, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await removeStore();
                  await removeStoreImage();
                }),
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          automaticallyImplyLeading: false,
          leading: GestureDetector(
              child: Icon(
                Icons.done,
                size: 30,
              ),
              onTap: () async => await UpdateDoneStore()),
          backgroundColor: secColor,
        ),
        body: FutureBuilder(
            future: getReady,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return SingleChildScrollView(
                  child: NotificationListener(
                    onNotification: ((ScrollNotification scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        print(scrollNotification);
                      }
                      return true;
                    }),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 15.h,
                      child: NotificationListener(
                        onNotification:
                            (ScrollNotification scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            print(scrollNotification);
                          }
                          return true;
                        },
                        child: ListView(
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 5.h),
                                  width: double.infinity,
                                  child: Container(
                                    height: 25.h,
                                    child: Card(
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        color: Color(0xffeeeeee),
                                        child: PageView(
                                          controller: pageviewcontroller,
                                          children: [
                                            for (var i in shopImage)
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 30.sp,
                                                                  )),
                                                              Image(
                                                                  image:
                                                                      NetworkImage(
                                                                          i)),
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Image(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(i)),
                                              )
                                          ],
                                        )),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 5.h,
                                  backgroundImage:
                                      NetworkImage(infoUser['profile']),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: option,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'آدرس',
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            fontFamily: Myfont,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          infoUser['address'],
                                          style: TextStyle(fontFamily: Myfont),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      for (var i in answerUser)
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              i['questions'],
                                              style: TextStyle(
                                                  fontFamily: Myfont,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(i['answer'],
                                                  style: TextStyle(
                                                    fontFamily: Myfont,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                            SizedBox(height: 20)
                                          ],
                                        ),
                                      if (infoUser['bio'] != null &&
                                          infoUser['bio'] != '')
                                        Text(
                                          'درباره ما',
                                          style: TextStyle(
                                              fontFamily: Myfont,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      if (infoUser['bio'] != null &&
                                          infoUser['bio'] != '')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            infoUser['bio'],
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontFamily: Myfont,
                                            ),
                                          ),
                                        ),
                                      if (infoUser['bio'] != null &&
                                          infoUser['bio'] != '')
                                        SizedBox(height: 20),
                                      Text(
                                        'محصولات و خدمات',
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            fontFamily: Myfont,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          infoUser['tags'],
                                          style: TextStyle(fontFamily: Myfont),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Center(
                  child: CircularProgressIndicator(
                color: secColor,
              ));
            }));
  }
}
