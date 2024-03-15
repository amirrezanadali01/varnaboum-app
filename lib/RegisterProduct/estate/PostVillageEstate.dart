import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/RegisterProduct/estate/TypeEstate/PostBetweenTypeEstate.dart';

class PostVillageEstate extends StatefulWidget {
  PostVillageEstate({Key? key, required this.villages}) : super(key: key);

  final List villages;

  @override
  State<PostVillageEstate> createState() => _PostVillageEstateState();
}

class _PostVillageEstateState extends State<PostVillageEstate> {
  late List villages;
  late int _val;

  @override
  void initState() {
    villages = widget.villages;
    _val = villages[0]['id'];
    postProduct['village'] = _val;
    super.initState();
  }

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
                      child: PostBetweenTypeEstate())));
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
                shadowColor: secColor,
                child: ListView.builder(
                    itemCount: villages.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(villages[index]['name']),
                        leading: Radio<int>(
                            focusColor: secColor,
                            activeColor: secColor,
                            value: villages[index]['id'],
                            groupValue: _val,
                            onChanged: (value) {
                              postProduct['village'] = villages[index]['id'];

                              setState(() {
                                _val = value as int;
                              });
                            }),
                      );
                    })),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
