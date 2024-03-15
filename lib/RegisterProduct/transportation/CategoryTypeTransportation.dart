import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/RegisterProduct/transportation/SubCategoryTypeTransportation.dart';

class CategoryTypeTransporation extends StatefulWidget {
  CategoryTypeTransporation({Key? key, required this.type}) : super(key: key);
  final String type;

  @override
  State<CategoryTypeTransporation> createState() =>
      _CategoryTypeTransporationState();
}

class _CategoryTypeTransporationState extends State<CategoryTypeTransporation> {
  Future<List> getCategorys() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/GetTypeTransportation/${widget.type}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List json = jsonDecode(utf8.decode(result.bodyBytes));

    return json;
  }

  late Future<List> listFuture;

  @override
  void initState() {
    listFuture = getCategorys();
    super.initState();
  }

  int _val = 0;
  late List categorys;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFFFAFAFA),
          leading: BackButton(
            color: Colors.black,
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: SubCategoryTypeTransportation(
                        categoryType: postProduct['TypeTransportation'],
                      ))));
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'دسته بندی سواری خود را انتخاب کنید',
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
                child: FutureBuilder<List>(
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
                        print(snapshot.data![_val]['id']);

                        postProduct['TypeTransportation'] =
                            snapshot.data![_val]['id'];

                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index]['name'],
                                    style: TextStyle(fontFamily: Myfont)),
                                leading: Radio(
                                    focusColor: secColor,
                                    activeColor: secColor,
                                    value: index,
                                    groupValue: _val,
                                    onChanged: (_value) {
                                      setState(() {
                                        _val = _value as int;

                                        postProduct['TypeTransportation'] =
                                            snapshot.data![_val]['id'];
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
