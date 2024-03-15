import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/Ticket/ChatTicket.dart';

class MyTicket extends StatefulWidget {
  MyTicket({Key? key}) : super(key: key);

  @override
  State<MyTicket> createState() => _MyTicketState();
}

class _MyTicketState extends State<MyTicket> {
  Future<bool> setStatusUser() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response statusUserRequest = await http.get(
      Uri.parse('$host/api/retryuser/'),
      headers: <String, String>{'Authorization': 'Bearer $access'},
    );

    print('infouserinfouserinfouser ${statusUserRequest.body}');

    switch (statusUserRequest.statusCode) {
      case 500:
        http.Response statusUserOffice = await http.get(
          Uri.parse('$host/api/retryOffice/'),
          headers: <String, String>{'Authorization': 'Bearer $access'},
        );
        print(
            'statusofficestatusofficestatusofficestatusoffice${statusUserOffice.body}');
        if (statusUserOffice.statusCode == 200) {
          return true;
        } else {
          return false;
        }

      case 200:
        return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              bottom: TabBar(indicatorColor: Colors.white, tabs: [
                Tab(text: 'انتقاد و پیشنهادات'),
                Tab(text: 'شکایات'),
              ]),
            ),
            body: FutureBuilder<bool>(
              future: setStatusUser(),
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
                  return TabBarView(children: [
                    PublickTicket(
                      isOffice: snapshot.data!,
                    ),
                    PrivateTicket(isOffice: snapshot.data!)
                  ]);
                }
              },
            )));
  }
}

class PublickTicket extends StatefulWidget {
  PublickTicket({Key? key, required this.isOffice}) : super(key: key);

  final bool isOffice;

  @override
  State<PublickTicket> createState() => _PublickTicketState();
}

class _PublickTicketState extends State<PublickTicket> {
  Map filter = {};
  dio.Dio _dio = dio.Dio();

  List ticketsList = [];

  String? urlTicket = '$host/api/GetMyTicket/';

  late Future futureGetTicket;

  Future<void> getMyTicket(bool isPageinition) async {
    if (isPageinition == false) {
      urlTicket = '$host/api/GetMyTicket/';
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      if (widget.isOffice == false) {
        filter['creator'] = access;
        filter['typeask'] = 'criticism';
      } else {
        filter['office'] = access;
        filter['typeask'] = 'criticism';
      }

      dio.FormData formdata = dio.FormData.fromMap({
        "filter": json.encode(filter),
      });

      var response = await _dio.post(urlTicket!, data: formdata);

      print(response.data);

      ticketsList = response.data['results'];

      urlTicket = response.data['next'];
    } else {
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      dio.FormData formdata = dio.FormData.fromMap({
        "filter": json.encode(filter),
      });
      print('urrrrrlllllll $urlTicket');
      var response = await _dio.post(urlTicket!, data: formdata);
      urlTicket = response.data['next'];

      for (var i in response.data['results']) {
        ticketsList.add(i);
      }

      setState(() {});
    }

    // print(response.data);
  }

  @override
  void initState() {
    futureGetTicket = getMyTicket(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureGetTicket,
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
            return NotificationListener(
              onNotification: (ScrollNotification scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  print(scrollNotification);
                  if (urlTicket != null) {
                    getMyTicket(true);
                  }
                }
                return true;
              },
              child: RefreshIndicator(
                color: secColor,
                onRefresh: () async {
                  print('first List Ticket ${ticketsList.length}');
                  await getMyTicket(false);
                  print('last List Ticket ${ticketsList.length}');
                },
                child: ListView.builder(
                    itemCount: ticketsList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == ticketsList.length) {
                        if (urlTicket == null) {
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
                                        child: ChatTicket(
                                          isOffice: widget.isOffice,
                                          isfinish: ticketsList[index]
                                              ['isfinish'],
                                          idTicket: ticketsList[index]['id'],
                                        ),
                                      ))),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticketsList[index]['name'],
                                    style: TextStyle(
                                        fontWeight: ticketsList[index]
                                                    ['message'] ==
                                                true
                                            ? null
                                            : FontWeight.bold),
                                  ),
                                  SizedBox(height: 10.sp),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ticketsList[index]['personal'] != null
                                            ? Text(
                                                ticketsList[index]
                                                    ['personalOffice'],
                                                style: TextStyle(
                                                    color: Colors.grey))
                                            : Text(
                                                ticketsList[index]
                                                    ['officeName'],
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                        Text(
                                          ticketsList[index]['officeCity'],
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
            );
          }
        });
  }
}

class PrivateTicket extends StatefulWidget {
  PrivateTicket({Key? key, required this.isOffice}) : super(key: key);

  final bool isOffice;

  @override
  State<PrivateTicket> createState() => _PrivateTicketState();
}

class _PrivateTicketState extends State<PrivateTicket> {
  Map filter = {};
  dio.Dio _dio = dio.Dio();

  List ticketsList = [];

  String? urlTicket = '$host/api/GetMyTicket/';

  late Future futureGetTicket;

  Future<void> getMyTicket(bool isPageinition) async {
    if (isPageinition == false) {
      urlTicket = '$host/api/GetMyTicket/';
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      if (widget.isOffice == false) {
        filter['creator'] = access;
        filter['typeask'] = 'complaint';
      } else {
        filter['office'] = access;
        filter['typeask'] = 'complaint';
      }

      dio.FormData formdata = dio.FormData.fromMap({
        "filter": json.encode(filter),
      });

      var response = await _dio.post(urlTicket!, data: formdata);

      print(response.data);

      ticketsList = response.data['results'];

      urlTicket = response.data['next'];
    } else {
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      dio.FormData formdata = dio.FormData.fromMap({
        "filter": json.encode(filter),
      });
      print('urrrrrlllllll $urlTicket');
      var response = await _dio.post(urlTicket!, data: formdata);
      urlTicket = response.data['next'];

      for (var i in response.data['results']) {
        ticketsList.add(i);
      }

      setState(() {});
    }

    // print(response.data);
  }

  @override
  void initState() {
    futureGetTicket = getMyTicket(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureGetTicket,
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
            return NotificationListener(
              onNotification: (ScrollNotification scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  print(scrollNotification);
                  if (urlTicket != null) {
                    getMyTicket(true);
                  }
                }
                return true;
              },
              child: RefreshIndicator(
                color: secColor,
                onRefresh: () async {
                  print('first List Ticket ${ticketsList.length}');
                  await getMyTicket(false);
                  print('last List Ticket ${ticketsList.length}');
                },
                child: ListView.builder(
                    itemCount: ticketsList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == ticketsList.length) {
                        if (urlTicket == null) {
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
                                        child: ChatTicket(
                                          isOffice: widget.isOffice,
                                          isfinish: ticketsList[index]
                                              ['isfinish'],
                                          idTicket: ticketsList[index]['id'],
                                        ),
                                      ))),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticketsList[index]['name'],
                                    style: TextStyle(
                                        fontWeight: ticketsList[index]
                                                    ['message'] ==
                                                true
                                            ? null
                                            : FontWeight.bold),
                                  ),
                                  SizedBox(height: 10.sp),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ticketsList[index]['personal'] != null
                                            ? Text(
                                                ticketsList[index]
                                                    ['personalOffice'],
                                                style: TextStyle(
                                                    color: Colors.grey))
                                            : Text(
                                                ticketsList[index]
                                                    ['officeName'],
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                        Text(
                                          ticketsList[index]['officeCity'],
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
            );
          }
        });
  }
}
