import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/ManageStore/RetryStore.dart';

class ListMangerStore extends StatefulWidget {
  ListMangerStore({Key? key}) : super(key: key);

  @override
  State<ListMangerStore> createState() => _ListMangerStoreState();
}

class _ListMangerStoreState extends State<ListMangerStore> {
  List listStore = [];

  late String? url;
  late Future<void> getStore;
  Future<void> GetStore({required bool isPageinition}) async {
    if (isPageinition == false) {
      url = "$host/api/GetListStoreManager/";
      await updateToken(context);
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      listStore = [];
      http.Response result = await http.get(Uri.parse(url as String),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      print(
          'result.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.body');
      print(result.body);
      print(
          'result.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.bodyresult.body');
      url = jsonDecode(utf8.decode(result.bodyBytes))['next'];
      listStore = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      setState(() {});
    } else {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(url as String),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      url = jsonDecode(utf8.decode(result.bodyBytes))['next'];
      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];

      for (var i in items) {
        listStore.add(i);
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    getStore = GetStore(isPageinition: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
      ),
      body: FutureBuilder(
          future: getStore,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFe3b12c),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return NotificationListener(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if (url != null) {
                      GetStore(isPageinition: true);
                    }
                  }
                  return true;
                },
                child: ListView.builder(
                    itemCount: listStore.length + 1,
                    itemBuilder: (context, index) {
                      if (index == listStore.length) {
                        if (url == null) {
                          return Container();
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFe3b12c),
                            ),
                          );
                        }
                      } else {
                        print(listStore[index]['profile']);
                        return GestureDetector(
                          // onTap: () {
                          //   print(listStore[index]);
                          // },
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: RetryStore(
                                            id: listStore[index]['user'],
                                            name: listStore[index]['name']),
                                      ))),
                          child: TemplateItem(
                              image: listStore[index]['profile'],
                              c1: listStore[index]['name'],
                              c2: listStore[index]['address']),
                        );
                      }
                    }),
              );
            }
          }),
    );
  }
}
