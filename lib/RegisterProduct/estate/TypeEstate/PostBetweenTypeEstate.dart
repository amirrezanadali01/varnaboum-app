import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/RegisterProduct/estate/TypeEstate/PostTypeEstate.dart';

class PostBetweenTypeEstate extends StatefulWidget {
  PostBetweenTypeEstate({Key? key}) : super(key: key);

  @override
  State<PostBetweenTypeEstate> createState() => _PostBetweenTypeEstateState();
}

class _PostBetweenTypeEstateState extends State<PostBetweenTypeEstate> {
  int _val = 0;
  String type = "masconi";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: PostTypeEstate(
                        type: type,
                      ))));
        },
      ),
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
      body: Padding(
        padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ملکتون در کدام دسته بندی است؟',
                  style: TextStyle(
                      fontFamily: Myfont, fontWeight: FontWeight.bold),
                ),
              ),
              flex: 0,
            ),
            Expanded(
              child: Card(
                shadowColor: secColor,
                child: Column(
                  children: [
                    ListTile(
                      title:
                          Text('مسکونی', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                        focusColor: secColor,
                        activeColor: secColor,
                        value: 0,
                        groupValue: _val,
                        onChanged: (value) {
                          print(_val);

                          setState(() {
                            _val = value as int;
                          });
                          if (_val == 0) {
                            type = 'masconi';
                          } else {
                            type = 'edareAndTejari';
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('اداری و تجاری',
                          style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                        focusColor: secColor,
                        activeColor: secColor,
                        value: 1,
                        groupValue: _val,
                        onChanged: (value) {
                          print(_val);

                          setState(() {
                            _val = value as int;
                          });
                          if (_val == 0) {
                            type = 'masconi';
                          } else {
                            print('edare tegary');
                            type = 'edareAndTejari';
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
