import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/RegisterProduct/estate/PostBetweenCitysVillageEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostRegionEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostVillageEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/TypeEstate/PostBetweenTypeEstate.dart';
import '../../Detail.dart';

class PostCityEstate extends StatefulWidget {
  PostCityEstate({Key? key}) : super(key: key);

  @override
  State<PostCityEstate> createState() => _PostCityEstateState();
}

class _PostCityEstateState extends State<PostCityEstate> {
  Future<Map> getCitys() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetCitysWithVillage'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    Map json = jsonDecode(utf8.decode(result.bodyBytes));

    return json;
  }

  late Future<Map> listFuture;

  @override
  void initState() {
    listFuture = getCitys();
    super.initState();
  }

  int _val = 0;

  late List village;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.navigate_next),
          backgroundColor: flColor,
          onPressed: () {
            if (village.isNotEmpty)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: PostBetweenCityVillageEstate(
                              villages: village))));
            else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: PostRegionEstate())));
            }
          }),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFAFAFA),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'ملکتون در کدام شهر است؟',
                style:
                    TextStyle(fontFamily: Myfont, fontWeight: FontWeight.bold),
              ),
            ),
            flex: 0,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: Card(
                shadowColor: secColor,
                child: FutureBuilder<Map>(
                    future: listFuture,
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
                        print(snapshot.data!.keys.toList()[0]);

                        village =
                            snapshot.data![snapshot.data!.keys.toList()[_val]]
                                ['village'];

                        postProduct['city'] = snapshot
                            .data![snapshot.data!.keys.toList()[_val]]['id'];

                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
                              return ListTile(
                                title: Text(snapshot.data!.keys.toList()[index],
                                    style: TextStyle(fontFamily: Myfont)),
                                leading: Radio(
                                    focusColor: secColor,
                                    activeColor: secColor,
                                    value: index,
                                    groupValue: _val,
                                    onChanged: (_value) {
                                      setState(() {
                                        print('hiiiiiiiiiiiiiii');

                                        _val = _value as int;
                                        print(snapshot.data![snapshot.data!.keys
                                            .toList()[_val]]['village']);
                                        postProduct['city'] = snapshot.data![
                                            snapshot.data!.keys
                                                .toList()[_val]]['id'];

                                        print(postProduct);
                                      });
                                    }),
                              );
                            }));
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
