import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/FirstLogin/Register/RegisterShop/end/RequiredRegisterPage.dart';

// Copy Past from RegisterRegion

class RegisterVillage extends StatefulWidget {
  RegisterVillage({Key? key}) : super(key: key);

  @override
  State<RegisterVillage> createState() => _RegisterVillageState();
}

class _RegisterVillageState extends State<RegisterVillage> {
  late Future<List> regions;
  int _val = 0;
  int city = int.parse(registerInformationShop['city']);

  Future<List> getRegions() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcategories = await http.get(
        Uri.parse('$host/api/GetVillage/$city/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List result = jsonDecode(utf8.decode(addcategories.bodyBytes));
    return result;
  }

  @override
  void initState() {
    regions = getRegions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () {
          if (registerInformationShop['village'] != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: endregister())));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(
                        'لطفا روستا ملک را وارد کنید',
                        textDirection: TextDirection.rtl,
                      ),
                    ));
          }
        },
      ),
      body: FutureBuilder<List>(
          future: regions,
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
              registerInformationShop['village'] = snapshot.data![_val]['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'ملکتون در کدام روستا است؟',
                          style: TextStyle(
                              fontFamily: Myfont, fontWeight: FontWeight.bold),
                        ),
                      ),
                      flex: 0,
                    ),
                    Expanded(
                      child: Card(
                        child: ListView.builder(
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

                                        registerInformationShop['village'] =
                                            snapshot.data![_val]['id'];
                                      });
                                    }),
                              );
                            })),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
