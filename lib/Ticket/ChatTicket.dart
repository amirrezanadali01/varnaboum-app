import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:varnaboomapp/Ticket/CreateMessage.dart';
import 'package:varnaboomapp/base.dart';

class ChatTicket extends StatefulWidget {
  ChatTicket({
    Key? key,
    required this.idTicket,
    required this.isfinish,
    required this.isOffice,
    this.isPublick = false,
  }) : super(key: key);

  int idTicket;
  bool isOffice;
  bool isfinish;
  bool isPublick;

  @override
  State<ChatTicket> createState() => _ChatTicketState();
}

class _ChatTicketState extends State<ChatTicket> {
  dio.Dio _dio = dio.Dio();

  Future<void> finishTicket() async {
    EasyLoading.show(status: 'منتظر بمانید ...');
    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    dio.FormData formdata = dio.FormData.fromMap({
      'isfinish': true,
    });

    var response = await _dio.put("$host/api/UpdateTicket/${widget.idTicket}/",
        data: formdata);

    print(response.data);
    print(response.statusCode);

    EasyLoading.dismiss();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl, child: baseWidget())));
  }

  List messagesList = [];
  late String? urlMessage;
  late Future futureGetChatTicket;

  Future<void> getChatTicket(bool isPageinition) async {
    if (isPageinition == false) {
      if (widget.isPublick == true) {
        urlMessage = '$host/api/GetMessagePublicTicket/${widget.idTicket}/';
      } else {
        urlMessage = '$host/api/GetMessageTicket/${widget.idTicket}/';
      }

      await updateToken(context);

      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');

      http.Response result = await http.get(Uri.parse(urlMessage!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      print(result.body);

      messagesList = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlMessage = jsonDecode(utf8.decode(result.bodyBytes))['next'];
    } else {
      await updateToken(context);

      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');

      http.Response result = await http.get(Uri.parse(urlMessage!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      urlMessage = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      List newMessages = jsonDecode(utf8.decode(result.bodyBytes))['results'];

      for (var i in newMessages) {
        messagesList.add(i);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    futureGetChatTicket = getChatTicket(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor),
      body: FutureBuilder(
          future: futureGetChatTicket,
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
                  if (widget.isfinish != true)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: CreateMessage(
                                            ticket: widget.idTicket,
                                            isOffice: widget.isOffice,
                                          )))),
                              child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    height: 5.h,
                                    child: Center(
                                      child: Text(
                                        'ثبت پیام',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orangeAccent,
                                            fontSize: 15.sp),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          if (widget.isOffice == false)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => finishTicket(),
                                child: Card(
                                    elevation: 5,
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      height: 5.h,
                                      child: Center(
                                        child: Text(
                                          'مشکلم حل شد',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                              fontSize: 15.sp),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    flex: 8,
                    child: NotificationListener(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          print(scrollNotification);
                          if (urlMessage != null) {
                            getChatTicket(true);
                          }
                        }
                        return true;
                      },
                      child: ListView.builder(
                          itemCount: messagesList.length + 1,
                          itemBuilder: (context, indext) {
                            if (indext == messagesList.length) {
                              if (urlMessage == null) {
                                return Container();
                              } else {
                                return Center(
                                  child: new CircularProgressIndicator(
                                    color: Color(
                                        0xFF149694), // messagesList[indext]['isMe']
                                  ),
                                );
                              }
                            } else {
                              return TemplateBubble(
                                  isMe: messagesList[indext]['isMe'],
                                  image: messagesList[indext]['image'],
                                  video: messagesList[indext]['video'],
                                  text: messagesList[indext]['text']);
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


// return Bubble(
//                               // #E8E8EE
//                               color: Color(0xFFE8E8EE),
//                               margin: BubbleEdges.only(top: 10),
//                               alignment: Alignment.topLeft,
//                               nip: BubbleNip.leftTop,
//                               child: Text(messagesList[indext]['text'],
//                                   style: TextStyle(color: Colors.black)),
//                             );