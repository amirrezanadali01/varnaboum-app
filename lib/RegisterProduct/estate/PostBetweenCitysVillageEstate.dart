import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostRegionEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/PostVillageEstate.dart';
import 'package:varnaboomapp/RegisterProduct/estate/TypeEstate/PostBetweenTypeEstate.dart';

class PostBetweenCityVillageEstate extends StatefulWidget {
  PostBetweenCityVillageEstate({Key? key, required this.villages})
      : super(key: key);

  final List villages;

  @override
  State<PostBetweenCityVillageEstate> createState() =>
      _PostBetweenCityVillageEstateState();
}

class _PostBetweenCityVillageEstateState
    extends State<PostBetweenCityVillageEstate> {
  int _val = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next),
        backgroundColor: flColor,
        onPressed: () {
          if (_val == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: PostRegionEstate())));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: PostVillageEstate(
                          villages: widget.villages,
                        ))));
          }
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
                  'محل کسب و کار شما کجاست؟',
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
                      title: Text('شهر', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                        focusColor: secColor,
                        activeColor: secColor,
                        value: 0,
                        groupValue: _val,
                        onChanged: (value) {
                          setState(() {
                            _val = value as int;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title:
                          Text('روستا', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                        focusColor: secColor,
                        activeColor: secColor,
                        value: 1,
                        groupValue: _val,
                        onChanged: (value) {
                          setState(() {
                            _val = value as int;
                          });
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
