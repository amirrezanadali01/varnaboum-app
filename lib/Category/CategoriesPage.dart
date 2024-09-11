import 'dart:async';
import 'package:flutter/material.dart';
import 'package:varnaboomapp/Category/Products/Transportation/TransportationPage.dart';
import 'package:varnaboomapp/News/TodayNews.dart';
import 'package:varnaboomapp/Office/AllOffice.dart';
import 'package:varnaboomapp/Office/NewsOffice.dart';
import 'Products/Estate/EstatePage.dart';
import 'package:varnaboomapp/ProfileUser/RetryProfile.dart';
import '../../Detail.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'CategoriesRetryPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SearchPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

class Category extends StatefulWidget {
  @override
  _CategorytState createState() => _CategorytState();
}

class _CategorytState extends State<Category> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: Image(
                image: AssetImage('assets/image/logo2.png'),
                fit: BoxFit.cover,
                height: 30.h,
                width: 30.w,
                color: Colors.white,
              ),

              // Image(image: AssetImage('assets/image/logo2.png'))

              backgroundColor: primaryColor,
              bottom: TabBar(indicatorColor: Colors.white, tabs: [
                Tab(icon: Icon(Icons.store_sharp)),
                Tab(icon: Icon(Icons.newspaper)),
                // Text(
                //   'خانه',
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   'خبر',
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),
              ]),
            ),
            body: TabBarView(children: [HomePage(), TodayNews()])),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List CategorisList = [];
  List<BannerModel> listBanner = [];

  List<CityModel> cityList = [];

  late Timer _timer;
  int _currentPage = 0;
  PageController pageviewcontroller = PageController();
  String _valTitleOffice = 'شهر';
  int _valOffice = 0;

  Future<void> getCategories() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcategories = await http.get(
        Uri.parse('$host/api/getcategoriesToday/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    var result = jsonDecode(utf8.decode(addcategories.bodyBytes));

    if ('detail' == result.keys.toList()[0]) {
    } else {
      readyListCategories(result);
    }
  }

  Future<List> getTopOffice() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/TopOffice/$_valOffice/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List officses = jsonDecode(utf8.decode(result.bodyBytes));

    return officses;
  }

  Future<void> GetBanner() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addbanner = await http.get(Uri.parse('$host/api/getBanner/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    if (addbanner.statusCode == 200) {
      List result = jsonDecode(utf8.decode(addbanner.bodyBytes));
      result.forEach((element) {
        listBanner.add(BannerModel(
            image: element['image'],
            title: element['title'],
            action: element['action']));
      });
      setState(() {});
    }
  }

  Future<void> GetCity() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcity = await http.get(Uri.parse('$host/api/getCity/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    var result = jsonDecode(utf8.decode(addcity.bodyBytes));

    readyListCity(result);
  }

  void readyListCity(result) {
    for (var i in result) {
      cityList.add(CityModel(id: i['id'], name: i['name']));
    }

    setState(() {
      _valTitleOffice = cityList[0].name;
      _valOffice = cityList[0].id;
    });
  }

  void readyListCategories(result) {
    for (var i in result.keys) {
      if (result[i]['subtitle'].isNotEmpty) {
        result[i]['subtitle'].insert(0, {
          'name': 'انتخاب کنید',
          'id': 50000,
          'subtitle': [
            {'id': 50000, 'name': 'انتخاب کنید', 'subcategory_id': 50000}
          ]
        });

        for (var i in result[i]['subtitle']) {
          if (i['id'] != 50000) {
            i['subtitle'].insert(0, {
              'name': 'انتخاب کنید',
              'id': 50000,
              'subtitle': [
                {'id': 50000, 'name': 'انتخاب کنید', 'subcategory_id': 50000}
              ]
            });
          }
          // i.insert({'id': 50000, 'name': 'انتخاب کنید', 'subcategory_id': 50000});
        }
      }

      CategorisList.add(CategoriesItem(
          name: i,
          id: result[i]['id'],
          image: '$host' + result[i]['image'],
          subtitle: result[i]['subtitle']));
    }

    setState(() {});
  }

  @override
  void initState() {
    GetBanner();
    GetCity();
    getCategories();

    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (pageviewcontroller.hasClients) {
        if (_currentPage < listBanner.length) {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => serach())),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, right: 10),
              height: 30,
              margin: EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  Text(
                    'جست و جو',
                    style: TextStyle(
                        color: Colors.grey, fontSize: 15, fontFamily: Myfont),
                  )
                ],
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
          ),

          // Container(width: double.infinity,height: 13.h,child: Listview.bu),

          FutureBuilder<List>(
              future: getTopOffice(),
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
                  print("City List ${_valOffice}");
                  return Column(
                    children: [
                      if (cityList.length != 1)
                        SizedBox(
                          width: 70.w,
                          child: OutlinedButton(
                            child: Text(
                              _valTitleOffice,
                              style: TextStyle(color: Colors.black54),
                            ),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                content:
                                    StatefulBuilder(builder: (context, stat) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        for (int i = 0;
                                            i < cityList.length;
                                            i++)
                                          ListTile(
                                            title: Text(
                                              cityList[i].name,
                                              style:
                                                  TextStyle(fontFamily: Myfont),
                                            ),
                                            leading: Radio<int>(
                                                focusColor: secColor,
                                                activeColor: secColor,
                                                value: cityList[i].id,
                                                groupValue: _valOffice,
                                                onChanged: (valueCity) {
                                                  setState(() {
                                                    _valOffice =
                                                        valueCity as int;
                                                    _valTitleOffice =
                                                        cityList[i].name;
                                                  });
                                                  Navigator.pop(context);
                                                }),
                                          )
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('اداری',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AllOffice(
                                            citys: cityList,
                                          )))),
                              child: Text(
                                'بیشتر',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 13.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, indext) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: NewsOffice(
                                                  lat: snapshot.data![indext]
                                                      ['lat'],
                                                  lng: snapshot.data![indext]
                                                      ['lng'],
                                                  id: snapshot.data![indext]
                                                      ['id'],
                                                  profile: snapshot
                                                      .data![indext]['profile'],
                                                  preview: snapshot
                                                      .data![indext]['preview'],
                                                  about: snapshot.data![indext]
                                                      ['bio'],
                                                  address: snapshot
                                                      .data![indext]['address'],
                                                  instagram:
                                                      snapshot.data![indext]
                                                          ['instagram'],
                                                  phone: snapshot.data![indext]
                                                      ['number'],
                                                  video: snapshot.data![indext]
                                                      ['video'],
                                                ),
                                                // child: NewsOffice(
                                                //   lat: snapshot.data![indext]
                                                //       ['lat'],
                                                //   lng: snapshot.data![indext]
                                                //       ['lng'],
                                                //   id: snapshot.data![indext]
                                                //       ['id'],
                                                //   profile: snapshot
                                                //       .data![indext]['profile'],
                                                //   preview: snapshot
                                                //       .data![indext]['preview'],
                                                //   about: snapshot.data![indext]
                                                //       ['bio'],
                                                //   address: snapshot
                                                //       .data![indext]['address'],
                                                //   instagram:
                                                //       snapshot.data![indext]
                                                //           ['instagram'],
                                                //   phone: snapshot.data![indext]
                                                //       ['number'],
                                                //   video: snapshot.data![indext]
                                                //       ['video'],
                                                // ),
                                              ))),
                                  child: TemplateCategory(
                                      image: snapshot.data![indext]['icon'],
                                      name: snapshot.data![indext]['name']),
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                }
              }),

          Container(
            width: double.infinity,
            height: 15.h,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: PageView(
                controller: pageviewcontroller,
                children: [
                  for (var i in listBanner)
                    GestureDetector(
                        onTap: () async {
                          if (i.action == 'varnaboom') {
                            List splitTitle = i.title.split(',');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: RetryProfile(
                                            name: splitTitle[1],
                                            id: int.parse(splitTitle[0])))));
                          }

                          if (i.action == 'instagram') {
                            await launch(
                                "https://www.instagram.com/${i.title}/");
                          }
                          if (i.action == 'site') {
                            await launch("https://${i.title}/");
                          }
                          if (i.action == 'phone') {
                            await launch("tel:+98${i.title}");
                          }
                        },
                        child: CachedNetworkImage(
                          imageUrl: i.image,
                          fit: BoxFit.cover,
                        ))
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: MediaQuery.of(context).size.height < 670.0
                        ? 0.15.h
                        : 0.10.h), //0.23  //10
                itemCount: CategorisList.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext ctx, index) {
                  return CategoryItem(
                    id: CategorisList[index].id,
                    citys: cityList,
                    name: CategorisList[index].name,
                    image: CategorisList[index].image,
                    subtitle: CategorisList[index].subtitle,
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.image,
    required this.subtitle,
    required this.citys,
    Key? key,
  }) : super(key: key);

  final String name;
  final int id;
  final String image;
  final List subtitle;
  final List<CityModel> citys;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
      onTap: () {
        print(name);
        if (name == "املاک") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: Estate(
                          id: id,
                          subtitle: subtitle,
                          citys: citys,
                        ),
                      )));
        } else if (name == "وسایل نقلیه") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: Transportation(
                          id: id,
                          subtitle: subtitle,
                          citys: citys,
                        ),
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: CategoryRetry(
                          id: id,
                          subtitle: subtitle,
                          citys: citys,
                        ),
                      )));
        }
      },
      child: TemplateCategory(image: image, name: name),
    ));
  }
}

class TemplateCategory extends StatelessWidget {
  const TemplateCategory({
    Key? key,
    required this.image,
    required this.name,
  }) : super(key: key);

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 5,
                offset: Offset(0, 5), // changes position of shadow
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                maxRadius: 0.38.h, //38   0.38.h
              ),
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 20.w,
                  height: 20.h,
                ),
                maxRadius: 4.55.h, //4.27.h
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          name,
          style: TextStyle(fontFamily: Myfont),
        )
      ],
    );
  }
}

class BannerModel {
  BannerModel({required this.image, required this.title, required this.action});

  final String image;
  final String title;
  final String action;
}
