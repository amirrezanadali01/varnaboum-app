import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/CategoriesPage.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/Office/NewsOffice.dart';

class AllOffice extends StatefulWidget {
  AllOffice({Key? key, required this.citys}) : super(key: key);

  final List citys;

  @override
  State<AllOffice> createState() => _AllOfficeState();
}

class _AllOfficeState extends State<AllOffice> {
  List officesList = [];

  late Future getOffices;

  late String? urlOffice;

  Future<void> getOffice(bool isPageinition) async {
    if (isPageinition == false) {
      urlOffice = '$host/api/GetAllOffice/${_valIdcity}/';
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlOffice!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      print(urlOffice);
      officesList = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlOffice = jsonDecode(utf8.decode(result.bodyBytes))['next'];
      print('urloffice');

      print(_valIdcity);
      print(officesList);
      setState(() {});
    } else {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlOffice!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlOffice = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      for (var i in items) {
        officesList.add(i);
      }
      setState(() {});
    }
  }

  late String _valTitleCity;
  late int _valCity = 0;
  late int _valIdcity;

  @override
  void initState() {
    _valTitleCity = widget.citys[0].name;
    _valIdcity = widget.citys[0].id;
    getOffices = getOffice(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor),
      body: FutureBuilder(
          future: getOffices,
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
              return Column(
                children: [
                  if (widget.citys.length != 1)
                    Expanded(
                      flex: 0,
                      child: SizedBox(
                          width: 70.w,
                          child: OutlinedButton(
                            child: Text(
                              _valTitleCity,
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
                                            i < widget.citys.length;
                                            i++)
                                          ListTile(
                                            title: Text(
                                              widget.citys[i].name,
                                              style:
                                                  TextStyle(fontFamily: Myfont),
                                            ),
                                            leading: Radio<int>(
                                                focusColor: secColor,
                                                activeColor: secColor,
                                                value: i,
                                                groupValue: _valCity,
                                                onChanged: (valueCity) {
                                                  setState(() {
                                                    _valCity = i;
                                                    _valIdcity =
                                                        widget.citys[i].id;

                                                    _valTitleCity =
                                                        widget.citys[i].name;
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
                          )),
                    ),
                  if (widget.citys.length != 1)
                    Expanded(
                        flex: 0,
                        child: Container(
                          width: 70.w,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  backgroundColor: secColor,
                                  side: BorderSide(color: secColor)),
                              child: Text(
                                'جست و جو',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: Myfont),
                              ),
                              onPressed: () {
                                print('hi');
                                getOffice(false);
                              }),
                        )),
                  Expanded(
                    child: NotificationListener(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          print(scrollNotification);
                          if (urlOffice != null) {
                            getOffice(true);
                          }
                        }
                        return true;
                      },
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio:
                                      MediaQuery.of(context).size.height < 670.0
                                          ? 0.15.h
                                          : 0.10.h),
                          itemCount: officesList.length + 1,
                          itemBuilder: (context, indext) {
                            if (indext == officesList.length) {
                              if (urlOffice == null) {
                                return Container();
                              } else {
                                return Center(
                                  child: new CircularProgressIndicator(
                                    color: secColor,
                                  ),
                                );
                              }
                            } else {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: NewsOffice(
                                                lat: officesList[indext]['lat'],
                                                lng: officesList[indext]['lng'],
                                                id: officesList[indext]['id'],
                                                profile: officesList[indext]
                                                    ['profile'],
                                                preview: officesList[indext]
                                                    ['preview'],
                                                about: officesList[indext]
                                                    ['bio'],
                                                address: officesList[indext]
                                                    ['address'],
                                                instagram: officesList[indext]
                                                    ['instagram'],
                                                phone: officesList[indext]
                                                    ['number'],
                                                video: officesList[indext]
                                                    ['video'],
                                              ),
                                            ))),
                                child: TemplateCategory(
                                  name: officesList[indext]['name'],
                                  image: officesList[indext]['icon'],
                                ),
                              );
                            }
                          }),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}



// newsesList[indext]['CityName']