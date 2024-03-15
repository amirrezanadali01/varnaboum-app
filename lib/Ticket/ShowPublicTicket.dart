import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:varnaboomapp/Ticket/AddTicket.dart';
import 'package:varnaboomapp/Ticket/ChatTicket.dart';

class ShowPublicTicket extends StatefulWidget {
  ShowPublicTicket({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<ShowPublicTicket> createState() => _ShowPublicTicketState();
}

class _ShowPublicTicketState extends State<ShowPublicTicket> {
  dio.Dio _dio = dio.Dio();

  List ticketsList = [];

  late String? urlTicket;

  late Future futureGetTicket;

  Future<void> getPublicTicket(bool isPageinition) async {
    if (isPageinition == false) {
      urlTicket = '$host/api/GetTicketOfiice/${widget.id}';
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      var response = await _dio.get(urlTicket!);

      print(response.data);

      ticketsList = response.data['results'];

      urlTicket = response.data['next'];
    } else {
      updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      _dio.options.headers['content-Type'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $access';

      var response = await _dio.get(urlTicket!);

      print(response.data);

      ticketsList = response.data['results'];

      urlTicket = response.data['next'];
    }
  }

  @override
  void initState() {
    futureGetTicket = getPublicTicket(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: flColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AddTicket(
                      id: widget.id,
                    )))),
      ),
      body: FutureBuilder(
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
                      getPublicTicket(true);
                    }
                  }
                  return true;
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
                                          isOffice: true,
                                          isfinish: true,
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // SizedBox(height: 10.sp),
                                  // Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       ticketsList[index]['personal'] != null
                                  //           ? Text(
                                  //               ticketsList[index]
                                  //                   ['personalOffice'],
                                  //               style: TextStyle(
                                  //                   color: Colors.grey))
                                  //           : Text(
                                  //               ticketsList[index]
                                  //                   ['officeName'],
                                  //               style: TextStyle(
                                  //                   color: Colors.grey)),
                                  //       Text(
                                  //         ticketsList[index]['officeCity'],
                                  //         style: TextStyle(color: Colors.grey),
                                  //       )
                                  //     ]),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              );
            }
          }),
    );
  }
}
