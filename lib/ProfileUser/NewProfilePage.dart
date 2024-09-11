import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/Products/AnotherProductsRetryUpdate.dart';
import 'package:varnaboomapp/Category/Products/Estate/EstateProductsRetryUpdate.dart';
import 'package:varnaboomapp/Category/Products/Transportation/TransportationRetryUpdate.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/CityRegister.dart';
import 'package:varnaboomapp/FirstLogin/loginpage.dart';
import 'package:varnaboomapp/ManageStore/ListMangeStore.dart';
import 'package:varnaboomapp/News/AddNews.dart';
import 'package:varnaboomapp/News/RemoveNews.dart';
import 'package:varnaboomapp/ProfileUser/Edit/AnswerQuestionEdite.dart';
import 'package:varnaboomapp/ProfileUser/Edit/ImagePrfileEdite.dart';
import 'package:varnaboomapp/ProfileUser/Edit/ImageShopEdite.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/EditeMovie.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';
import 'package:varnaboomapp/ProfileUser/Edit/TxtProfileEdit.dart';
import 'package:varnaboomapp/ProfileUser/Edit/mapPageEditor.dart';
import 'package:varnaboomapp/RegisterProduct/another/EndProductAnother.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostCityEstate.dart';
import 'package:varnaboomapp/RegisterProduct/transportation/TypeTransportatio.dart';

class ProfileUser extends StatefulWidget {
  ProfileUser({Key? key}) : super(key: key);

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

enum statusUser { nothing, registered, confirmation, office }

class _ProfileUserState extends State<ProfileUser> {
  final ImagePicker _picker = ImagePicker();
  XFile? video;
  late String status;
  List listItme = [];
  XFile? imageProfile;
  int? userID;
  late String userCategory;
  ScrollController _scrollController = ScrollController();
  late Future getNews;
  String? urlNews = '$host/api/ListProfileNews/';

  String? nextpageUrl;
  List<XFile>? multiImageList = [];

  late MultipartFile preview; //PRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
  List asstImages = [];
  List itemNews = [];

  Future<void> get_video(int id) async {
    video = await _picker.pickVideo(source: ImageSource.gallery);

    File file = File(video!.path);
    int sizeInBytes = file.lengthSync();
    int sizeInMb = sizeInBytes ~/ (1024 * 1024);

    if (video != null && sizeInMb <= 5) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: EditeVideo(
                      id: id,
                      video: video as XFile,
                    ),
                  )));
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'فایل وارد شده باید کمتر از ۵ مگ باشد',
                  textAlign: TextAlign.right,
                ),
              ));
    }
  }

  Future<void> getNewsProfile(bool isPageinition) async {
    if (isPageinition == false) {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlNews!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      itemNews = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlNews = jsonDecode(utf8.decode(result.bodyBytes))['next'];
    } else {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlNews!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlNews = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      print(items);

      for (var i in items) {
        itemNews.add(i);
      }
      setState(() {});
    }
  }

  Future<bool> statusMangerStore() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse("$host/api/StatusManagerProduct/"),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print('reeeeeeeessssreeeeeeeessssreeeeeeeessssreeeeeeeessss');
    print(result.body);

    bool stauts = jsonDecode(utf8.decode(result.bodyBytes))['status'];

    return stauts;
  }

  Future<List> getShopImage() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/ImageShopUser/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    return a;
  }

  Future<Map> getInfoUser() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    //retryuser/

    http.Response result = await http.get(Uri.parse('$host/api/retryuser/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    userID = a[0]['id'];
    userCategory = a[0]['CategoryName'];
    if (a[0]['CategoryName'] == 'املاک') {
      productsEstate = getProductsProfileEstate(a[0]['id']);
    } else if (a[0]['CategoryName'] == 'وسایل نقلیه') {
      productsTransportation = getProductsProfileTransportation(a[0]['id']);
    } else {
      print("CATEGOTY ${a[0]['CategoryName']}");
      productsAnother = getProductsProfileAnother(a[0]['id']);
    }

    return a[0];
  }

  Future<void> getProductsProfileEstate(id, {bool isFirst = true}) async {
    var boxToken = await Hive.openBox('token');

    String access = boxToken.get('access');

    if (isFirst == true) {
      http.Response result = await http.get(
        Uri.parse('$host/api/GetProductsEstateProfile/$id/'),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      listItme = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      setState(() {});
    } else {
      http.Response result = await http.get(
        Uri.parse(nextpageUrl as String),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      List newData = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      for (var i in newData) {
        listItme.add(i);
      }
      setState(() {});
    }
  }

  Future<void> getProductsProfileAnother(id, {bool isFirst = true}) async {
    var boxToken = await Hive.openBox('token');

    String access = boxToken.get('access');

    if (isFirst == true) {
      print('$host/api/GetProductsAnotherProfile/$id/');
      http.Response result = await http.get(
        Uri.parse('$host/api/GetProductsAnotherProfile/$id/'),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      listItme = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      setState(() {});
    } else {
      http.Response result = await http.get(
        Uri.parse(nextpageUrl as String),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      List newData = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      for (var i in newData) {
        listItme.add(i);
      }
      setState(() {});
    }
  }

  // HHHHHHHHHHHHH

  Future<void> getProductsProfileTransportation(id,
      {bool isFirst = true}) async {
    var boxToken = await Hive.openBox('token');

    String access = boxToken.get('access');

    if (isFirst == true) {
      print('SITTTE $host/api/GetProductsTransportationProfile/$id/');
      http.Response result = await http.get(
        Uri.parse('$host/api/GetProductsTransportationProfile/$id/'),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      print(result.body);

      listItme = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      setState(() {});
    } else {
      http.Response result = await http.get(
        Uri.parse(nextpageUrl as String),
        headers: <String, String>{'Authorization': 'Bearer $access'},
      );

      List newData = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      for (var i in newData) {
        listItme.add(i);
      }
      setState(() {});
    }
  }

  Future<void> getImagePostAnother() async {
    final ImagePicker _picker = ImagePicker();
    multiImageList = await _picker.pickMultiImage();

    if (multiImageList != null) {
      for (var i in multiImageList ?? []) {
        print('here1');
        CroppedFile? imageCropper = await ImageCropper().cropImage(
            maxWidth: 1000,
            compressQuality: 85,
            sourcePath: i!.path,
            aspectRatioPresets: [CropAspectRatioPreset.square]);

        if (imageCropper != null) {
          String fileNameProfile = imageCropper.path.split('/').last;

          var hi = await MultipartFile.fromFile(imageCropper.path,
              filename: fileNameProfile.toEnglishDigit());

          final planetsByDiameter = {"image": hi};

          asstImages.add(planetsByDiameter);

          if (i == multiImageList![0] && asstImages != []) {
            print('hiiiiiiiiii');
            preview = await MultipartFile.fromFile(imageCropper.path,
                filename: fileNameProfile.toEnglishDigit());
          }
        }
      }
    }
  }

  Future<void> logout() async {
    // Hive.deleteBoxFromDisk('token');
    // Hive.
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => login()));

    var box = Hive.box('token');
    box.delete('access');
    box.delete('token');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => login()));
  }

  Future<void> getImageProfile(int id) async {
    final ImagePicker _picker = ImagePicker();
    imageProfile = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000, imageQuality: 85);

    if (imageProfile != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: ProfileImage(
                      id: id,
                      imageProfile: imageProfile!,
                    ),
                  )));
    }
  }

  Future<List> GetShopImage() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/ImageShopUser/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    return a;
  }

  Future<String> setStatusUser() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response statusUserRequest = await http.get(
      Uri.parse('$host/api/retryuser/'),
      headers: <String, String>{'Authorization': 'Bearer $access'},
    );

    await Hive.openBox('InfUser');
    var boxStatus = Hive.box('InfUser');

    switch (statusUserRequest.statusCode) {
      case 500:
        http.Response statusUserOffice = await http.get(
          Uri.parse('$host/api/retryOffice/'),
          headers: <String, String>{'Authorization': 'Bearer $access'},
        );
        print(
            'statusofficestatusofficestatusofficestatusoffice${statusUserOffice.body}');
        if (statusUserOffice.statusCode == 200) {
          getNews = getNewsProfile(false);
          boxStatus.put('StatusUser', "office");
          return 'office';
        } else {
          boxStatus.put('StatusUser', "nothing");
          return 'nothing';
        }

      case 200:
        print(statusUserRequest.body);
        infousers = getInfoUser();
        if (jsonDecode(statusUserRequest.body)[0]['Confirmation'] == false) {
          boxStatus.put('StatusUser', "registered");
          return 'registered';
        } else {
          boxStatus.put('StatusUser', "confirmation");
          return 'confirmation';
        }
    }

    return '';
  }

  late Future<String> statususer;
  late Future<List> shopimages;
  late Future<Map> infousers;
  late Future<List> answerquestion;
  late Future productsEstate;
  late Future productsAnother;
  late Future productsTransportation;

  @override
  void initState() {
    statususer = setStatusUser();
    shopimages = GetShopImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () async => await logout(),
            icon: Icon(
              Icons.logout_rounded,
              size: 40,
              color: secColor,
            )),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<String>(
          future: statususer,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new CircularProgressIndicator(
                  color: secColor,
                ),
              );
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Container();
            } else {
              if (snapshot.data == 'nothing') {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                          width: double.infinity,
                          child: Center(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: secColor),
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: RegisterCategory()))),
                                child: Text(
                                  'ثبت صنف',
                                  style: TextStyle(
                                    color: secColor,
                                    fontFamily: Myfont,
                                  ),
                                )),
                          )),
                    ),
                    FutureBuilder<bool>(
                        future: statusMangerStore(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return new Center(
                              child: new CircularProgressIndicator(
                                color: secColor,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Container();
                          } else {
                            if (snapshot.data == true) {
                              return Expanded(
                                child: Container(
                                    width: double.infinity,
                                    child: Center(
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: secColor),
                                          ),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child:
                                                              ListMangerStore()))),
                                          child: Text(
                                            'مدیریت اصناف',
                                            style: TextStyle(
                                              color: secColor,
                                              fontFamily: Myfont,
                                            ),
                                          )),
                                    )),
                              );
                            } else {
                              return Container();
                            }
                          }
                        }),
                  ],
                );
              } else if (snapshot.data == 'registered') {
                return Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: Text('در انتظار تایید',
                              style: TextStyle(
                                  fontFamily: Myfont, color: secColor))),
                    ),
                    FutureBuilder<bool>(
                        future: statusMangerStore(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return new Center(
                              child: new CircularProgressIndicator(
                                color: secColor,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Container();
                          } else {
                            if (snapshot.data == true) {
                              return Expanded(
                                child: Container(
                                    width: double.infinity,
                                    child: Center(
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: secColor),
                                          ),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child:
                                                              ListMangerStore()))),
                                          child: Text(
                                            'مدیریت اصناف',
                                            style: TextStyle(
                                              color: secColor,
                                              fontFamily: Myfont,
                                            ),
                                          )),
                                    )),
                              );
                            } else {
                              return Container();
                            }
                          }
                        }),
                  ],
                );
              } else if (snapshot.data == 'office') {
                print('yeeeeeeeeeeeeeessssssssssssss');
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                              width: double.infinity,
                              child: Center(
                                child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: secColor),
                                    ),
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child: AddNews()))),
                                    child: Text(
                                      'ثبت خبر',
                                      style: TextStyle(
                                        color: secColor,
                                        fontFamily: Myfont,
                                      ),
                                    )),
                              )),
                        ),
                        FutureBuilder<bool>(
                            future: statusMangerStore(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return new Center(
                                  child: new CircularProgressIndicator(
                                    color: secColor,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                print('Error: ${snapshot.error}');
                                return Container();
                              } else {
                                if (snapshot.data == true) {
                                  return Expanded(
                                    child: Container(
                                        width: double.infinity,
                                        child: Center(
                                          child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side:
                                                    BorderSide(color: secColor),
                                              ),
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Directionality(
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl,
                                                              child:
                                                                  ListMangerStore()))),
                                              child: Text(
                                                'مدیریت اصناف',
                                                style: TextStyle(
                                                  color: secColor,
                                                  fontFamily: Myfont,
                                                ),
                                              )),
                                        )),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                            }),
                      ],
                    ),

                    //Now Here
                    FutureBuilder(
                        future: getNews,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return new Center(
                              child: new CircularProgressIndicator(
                                color: secColor,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Container();
                          } else {
                            return ConstrainedBox(
                                constraints: BoxConstraints(
                                    //maxHeight: 13.50.h * listItme.length,
                                    maxHeight: itemNews.length != 0
                                        ? 76.50.h
                                        : 70.50.h,
                                    minHeight: 56.0),
                                child: NotificationListener(
                                  onNotification:
                                      (ScrollNotification scrollNotification) {
                                    if (scrollNotification
                                        is ScrollEndNotification) {
                                      print(scrollNotification);
                                      if (urlNews != null) {
                                        // urlNews = nextpageUrl;
                                        getNewsProfile(true);
                                      }
                                    }
                                    return true;
                                  },
                                  child: ListView.builder(
                                      itemCount: itemNews.length + 1,
                                      itemBuilder: (context, indext) {
                                        if (indext == itemNews.length) {
                                          if (urlNews == null) {
                                            return Container();
                                          } else {
                                            return Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                color: secColor,
                                              ),
                                            );
                                          }
                                        } else {
                                          return (GestureDetector(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Directionality(
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        child: RemoveNews(
                                                            vide:
                                                                itemNews[indext]
                                                                    ['video'],
                                                            id: itemNews[indext]
                                                                ['id'],
                                                            titr:
                                                                itemNews[indext]
                                                                    ['titr'],
                                                            text:
                                                                itemNews[indext]
                                                                    ['text'],
                                                            image: itemNews[
                                                                    indext]
                                                                ['image'])))),
                                            child: TemplateItem(
                                                isNews: true,
                                                image: itemNews[indext]
                                                    ['image'],
                                                c1: itemNews[indext]['titr'],
                                                c2: itemNews[indext]
                                                        ['UserOfiice']
                                                    .toString()),
                                          ));
                                        }
                                      }),
                                ));
                          }
                        })
                  ],
                );
              } else if (snapshot.data == 'confirmation') {
                return NotificationListener(
                  onNotification: (ScrollNotification scrollNotification) {
                    if (scrollNotification is ScrollEndNotification &&
                        userID != null) {
                      if (nextpageUrl != null) {
                        if (userCategory == 'املاک') {
                          getProductsProfileEstate(userID, isFirst: false);
                        } else if (userCategory == 'وسایل نقلیه') {
                          getProductsProfileTransportation(userID,
                              isFirst: false);
                        } else {
                          getProductsProfileAnother(userID, isFirst: false);
                        }
                      }
                    }
                    return true;
                  },
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      FutureBuilder<List>(
                          future: shopimages,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return new Center(
                                child: new CircularProgressIndicator(
                                  color: secColor,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              print('Error: ${snapshot.error}');
                              return Container();
                            } else {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: ImageShop(
                                                Images: snapshot.data!,
                                              ),
                                            ))),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 50),
                                  width: double.infinity,
                                  height: 200,
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: Color(0xffeeeeee),
                                    child: PageView(
                                      children: [
                                        for (var i in snapshot.data!)
                                          Image(
                                            image: NetworkImage(i['imag']),
                                            fit: BoxFit.cover,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                      FutureBuilder<Map>(
                          future: infousers,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return new Center(
                                child: new CircularProgressIndicator(
                                  color: secColor,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              print('Error: ${snapshot.error}');
                              return Container();
                            } else {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        getImageProfile(snapshot.data!['user']),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          snapshot.data!['profile']),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconsSocial(
                                          icon: Icons.location_on,
                                          propertyName: snapshot.data!['lng'],
                                          pageNavigator: snapshot
                                                      .data!['lng'] ==
                                                  null
                                              ? mapEditor(
                                                  id: snapshot.data!['user'],
                                                )
                                              : mapEditor(
                                                  id: snapshot.data!['user'],
                                                  lat: double.parse(
                                                      snapshot.data!['lat']),
                                                  lng: double.parse(
                                                      snapshot.data!['lng']),
                                                ),
                                        ),
                                        IconsSocial(
                                          icon: Icons.phone,
                                          propertyName:
                                              snapshot.data!['number'],
                                          pageNavigator: snapshot
                                                      .data!['number'] ==
                                                  null
                                              ? TextEdite(
                                                  id: snapshot.data!['user'],
                                                  field: "number",
                                                  name: 'شماره تماس',
                                                )
                                              : TextEdite(
                                                  id: snapshot.data!['user'],
                                                  field: "number",
                                                  name: 'شماره تماس',
                                                  text: snapshot.data!['number']
                                                      .toString(),
                                                ),
                                        ),
                                        IconsSocial(
                                            lineIcon: LineIcons.instagram,
                                            propertyName:
                                                snapshot.data!['instagram'],
                                            pageNavigator: snapshot
                                                        .data!['instagram'] ==
                                                    null
                                                ? TextEdite(
                                                    id: snapshot.data!['user'],
                                                    field: "instagram",
                                                    name: 'اینستاگرام',
                                                  )
                                                : TextEdite(
                                                    id: snapshot.data!['user'],
                                                    field: "instagram",
                                                    name: 'اینستاگرام',
                                                    text: snapshot
                                                        .data!['instagram']
                                                        .toString(),
                                                  )),
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          snapshot.data![
                                                                      'video'] !=
                                                                  null
                                                              ? OutlinedButton(
                                                                  child: Text(
                                                                    'نمایش ویدیو',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Myfont),
                                                                  ),
                                                                  onPressed: () => Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => Directionality(
                                                                                textDirection: TextDirection.rtl,
                                                                                child: SamplePlayer(url: snapshot.data!['video']),
                                                                              ))))
                                                              : Container(),
                                                          OutlinedButton(
                                                              child: snapshot.data![
                                                                          'video'] !=
                                                                      null
                                                                  ? Text(
                                                                      'عوض کردن ویدیو',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              Myfont),
                                                                    )
                                                                  : Text(
                                                                      'اضافه کردن ویدیو',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              Myfont)),
                                                              onPressed: () =>
                                                                  get_video(snapshot
                                                                          .data![
                                                                      'user'])),
                                                        ],
                                                      ),
                                                      content: Text(''),
                                                    );
                                                  });
                                            },
                                            icon: Icon(
                                              Icons.movie,
                                              size: 30,
                                              color: snapshot.data!['video'] !=
                                                      null
                                                  ? Colors.black
                                                  : Colors.orangeAccent,
                                            )),
                                        if (snapshot
                                                .data!['CategoryProducts'] ==
                                            'True')
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: AlertDialog(
                                                        title: EditInfoShop(
                                                          info: snapshot.data!,
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            icon: Icon(
                                              Icons.info,
                                              size: 30,
                                              color: Color(0xFF2AABEE),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (snapshot.data!['CategoryProducts'] ==
                                      'False')
                                    FutureBuilder<List>(
                                        future: answerquestion,
                                        builder: (context, snapshop) {
                                          if (snapshop.hasData) {
                                            return ListView.builder(
                                                itemCount:
                                                    snapshop.data!.length,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child: EditeAnswer(
                                                                      id: snapshop
                                                                              .data![index]
                                                                          [
                                                                          'id'],
                                                                      answer: snapshop
                                                                              .data![index]
                                                                          [
                                                                          'answer']),
                                                                ))),
                                                    child: Container(
                                                      width: double.infinity,
                                                      child: Card(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 10,
                                                                    top: 20,
                                                                    bottom: 10),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  snapshop.data![
                                                                          index]
                                                                      [
                                                                      'questions'],
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          Myfont,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Text(
                                                                    snapshop.data![
                                                                            index]
                                                                        [
                                                                        'answer'],
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Myfont))
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                });
                                          }

                                          return Center(
                                            child:
                                                new CircularProgressIndicator(
                                              color: secColor,
                                            ),
                                          );
                                        }),
                                  if (snapshot.data!['CategoryProducts'] ==
                                      'False')
                                    Column(
                                      children: [
                                        EditInfoShop(info: snapshot.data!),
                                        FutureBuilder<List>(
                                            future: answerquestion,
                                            builder: (context, snapshop) {
                                              if (snapshop.hasData) {
                                                return ListView.builder(
                                                    itemCount:
                                                        snapshop.data!.length,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Directionality(
                                                                              textDirection: TextDirection.rtl,
                                                                              child: EditeAnswer(id: snapshop.data![index]['id'], answer: snapshop.data![index]['answer']),
                                                                            ))),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          child: Card(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 20),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10,
                                                                        top: 20,
                                                                        bottom:
                                                                            10),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      snapshop.data![
                                                                              index]
                                                                          [
                                                                          'questions'],
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              Myfont,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                        snapshop.data![index]
                                                                            [
                                                                            'answer'],
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Myfont))
                                                                  ],
                                                                ),
                                                              )),
                                                        ),
                                                      );
                                                    });
                                              }

                                              return Center(
                                                child:
                                                    new CircularProgressIndicator(
                                                  color: secColor,
                                                ),
                                              );
                                            }),
                                      ],
                                    ),

                                  //PRODUCTSSSSSSSSSS
                                  if (snapshot.data!['CategoryProducts'] ==
                                      'True')
                                    Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 20),
                                        child: Center(
                                          child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side:
                                                    BorderSide(color: secColor),
                                              ),
                                              onPressed: () async {
                                                if (snapshot.data![
                                                        'CategoryName'] ==
                                                    'املاک') {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      PostCityEstate()))));
                                                } else if (snapshot.data![
                                                        'CategoryName'] ==
                                                    'وسایل نقلیه') {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child:
                                                                      TypeTransportation()))));
                                                } else {
                                                  await getImagePostAnother();

                                                  if (asstImages.isNotEmpty) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  child: EndProductAnother(
                                                                      preview:
                                                                          preview,
                                                                      images:
                                                                          asstImages,
                                                                      is_price: snapshot.data!['CtegoryPrice'] ==
                                                                              "True"
                                                                          ? true
                                                                          : false),
                                                                )));
                                                  }
                                                }
                                              },
                                              child: Text(
                                                'ثبت محصول',
                                                style: TextStyle(
                                                  color: secColor,
                                                  fontFamily: Myfont,
                                                ),
                                              )),
                                        )),

                                  if (snapshot.data!['CategoryName'] == 'املاک')
                                    FutureBuilder(
                                        future: productsEstate,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return new Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                color: secColor,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return new Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      listItme.length != 0
                                                          ? 13.50.h *
                                                              listItme.length
                                                          : 13.50.h,
                                                  minHeight: 56.0),
                                              child: ListView.builder(
                                                  controller: _scrollController,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      listItme.length + 1,
                                                  itemBuilder:
                                                      (context, indext) {
                                                    if (indext ==
                                                        listItme.length) {
                                                      if (nextpageUrl == null) {
                                                        return Container();
                                                      } else {
                                                        return Center(
                                                          child:
                                                              new CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF149694),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Directionality(
                                                                              textDirection: TextDirection.rtl,
                                                                              child: EstateProductRetryUpdate(id: listItme[indext]['id'], data: listItme[indext]),
                                                                            ))),
                                                        child: TemplateItem(
                                                            image:
                                                                listItme[indext]
                                                                    ['image'],
                                                            c1: listItme[indext]
                                                                ['name'],
                                                            c2: listItme[indext]
                                                                ['address']),
                                                      );
                                                    }
                                                  }),
                                            );
                                          }
                                        }),

                                  if (snapshot.data!['CategoryName'] !=
                                          'املاک' &&
                                      snapshot.data!['CategoryName'] !=
                                          'وسایل نقلیه')
                                    FutureBuilder(
                                        future: productsAnother,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return new Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                color: secColor,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return new Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      listItme.length != 0
                                                          ? 13.50.h *
                                                              listItme.length
                                                          : 13.50.h,
                                                  minHeight: 56.0),
                                              child: ListView.builder(
                                                  controller: _scrollController,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      listItme.length + 1,
                                                  itemBuilder:
                                                      (context, indext) {
                                                    if (indext ==
                                                        listItme.length) {
                                                      if (nextpageUrl == null) {
                                                        return Container();
                                                      } else {
                                                        return Center(
                                                          child:
                                                              new CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF149694),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Directionality(
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                    child:
                                                                        AnotherProductsRetryUpdate(
                                                                      description:
                                                                          listItme[indext]
                                                                              [
                                                                              'description'],
                                                                      id: listItme[
                                                                              indext]
                                                                          [
                                                                          'id'],
                                                                      name: listItme[
                                                                              indext]
                                                                          [
                                                                          'name'],
                                                                      price: listItme[indext]
                                                                              [
                                                                              'price']
                                                                          .toString(),
                                                                    ),
                                                                  ),
                                                                )),
                                                        child: TemplateItem(
                                                            image:
                                                                listItme[indext]
                                                                    ['preview'],
                                                            c1: listItme[indext]
                                                                ['name'],
                                                            c2: listItme[indext]
                                                                [
                                                                'description']),
                                                      );
                                                    }
                                                  }),
                                            );
                                          }
                                        }),

                                  if (snapshot.data!['CategoryName'] ==
                                      'وسایل نقلیه')
                                    FutureBuilder(
                                        future: productsTransportation,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return new Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                color: secColor,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return new Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight:
                                                      listItme.length != 0
                                                          ? 13.50.h *
                                                              listItme.length
                                                          : 13.50.h,
                                                  minHeight: 56.0),
                                              child: ListView.builder(
                                                  controller: _scrollController,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      listItme.length + 1,
                                                  itemBuilder:
                                                      (context, indext) {
                                                    if (indext ==
                                                        listItme.length) {
                                                      if (nextpageUrl == null) {
                                                        return Container();
                                                      } else {
                                                        return Center(
                                                          child:
                                                              new CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF149694),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      return GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Directionality(
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                    child:
                                                                        AnotherProductsRetryUpdate(
                                                                      description:
                                                                          listItme[indext]
                                                                              [
                                                                              'description'],
                                                                      id: listItme[
                                                                              indext]
                                                                          [
                                                                          'id'],
                                                                      name: listItme[
                                                                              indext]
                                                                          [
                                                                          'name'],
                                                                      price: listItme[
                                                                              indext]
                                                                          [
                                                                          'price'],
                                                                    ),
                                                                  ),
                                                                )),
                                                        child: GestureDetector(
                                                          onTap: () =>
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => Directionality(
                                                                        textDirection:
                                                                            TextDirection
                                                                                .rtl,
                                                                        child: TransportationRetryUpdate(
                                                                            data:
                                                                                listItme[indext],
                                                                            id: listItme[indext]['id'])),
                                                                  )),
                                                          child: TemplateItem(
                                                              image: listItme[
                                                                      indext]
                                                                  ['image'],
                                                              c1: listItme[
                                                                      indext]
                                                                  ['name'],
                                                              c2: listItme[
                                                                      indext][
                                                                  'description']),
                                                        ),
                                                      );
                                                    }
                                                  }),
                                            );
                                          }
                                        }),
                                ],
                              );
                            }
                          })
                    ],
                  ),
                );
              }
              return Text(snapshot.data.toString());
            }
          }),
    );
  }
}

class EditInfoShop extends StatelessWidget {
  const EditInfoShop({
    required this.info,
    Key? key,
  }) : super(key: key);

  final Map info;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextEdite(
                        id: info['user'],
                        field: 'name',
                        text: info['name'],
                        name: 'نام',
                      ),
                    ))),
        child: Container(
          width: double.infinity,
          child: Card(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نام',
                      style: TextStyle(
                          fontFamily: Myfont, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        info['name'],
                        style: TextStyle(fontFamily: Myfont),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextEdite(
                        id: info['user'],
                        field: 'tags',
                        text: info['tags'],
                        name: 'چه خدمات و محصولاتی ارائه میدهی',
                      ),
                    ))),
        child: Container(
          width: double.infinity,
          child: Card(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'چه خدمات و محصولاتی ارائه می دهید',
                      style: TextStyle(
                          fontFamily: Myfont, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        info['tags'],
                        style: TextStyle(fontFamily: Myfont),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextEdite(
                        id: info['user'],
                        field: 'address',
                        text: info['address'],
                        name: 'ادرس',
                      ),
                    ))),
        child: Container(
          width: double.infinity,
          child: Card(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آدرس صنف',
                      style: TextStyle(
                          fontFamily: Myfont, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(info['address'],
                          style: TextStyle(fontFamily: Myfont)),
                    )
                  ],
                ),
              )),
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextEdite(
                        id: info['user'],
                        field: 'bio',
                        text: info['bio'],
                        name: 'درباره ما',
                      ),
                    ))),
        child: Container(
          width: double.infinity,
          child: Card(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 20, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('درباره ما',
                        style: TextStyle(
                            fontFamily: Myfont, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(info['bio'],
                          style: TextStyle(fontFamily: Myfont)),
                    )
                  ],
                ),
              )),
        ),
      ),
    ]);
  }
}

class IconsSocial extends StatelessWidget {
  const IconsSocial({
    required this.pageNavigator, //mapEditor
    required this.propertyName, //snapshot.data!['lng']
    this.icon,
    this.lineIcon,
    Key? key,
  }) : super(key: key);

  final Widget pageNavigator;
  final dynamic propertyName;
  final IconData? icon;
  final IconData? lineIcon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (propertyName == null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                      textDirection: TextDirection.rtl, child: pageNavigator)));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                      textDirection: TextDirection.rtl, child: pageNavigator)));
        }
      },
      icon: icon != null
          ? Icon(
              icon,
              size: 30,
              color:
                  propertyName == null ? Colors.orangeAccent : Colors.redAccent,
            )
          : LineIcon(
              lineIcon!,
              size: 30,
              color: propertyName != null && propertyName != ''
                  ? Colors.pinkAccent
                  : Colors.orangeAccent,
            ),
    );
  }
}
