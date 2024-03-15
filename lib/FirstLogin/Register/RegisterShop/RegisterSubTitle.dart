import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'end/RequiredRegisterPage.dart';
import 'package:varnaboomapp/Detail.dart';

class RegiseterFormSubtitle extends StatefulWidget {
  const RegiseterFormSubtitle({
    Key? key,
    required this.subtitle,
    required this.subtitleName,
  });

  final List subtitle;
  final List subtitleName;

  @override
  _RegiseterFormState createState() => _RegiseterFormState();
}

class _RegiseterFormState extends State<RegiseterFormSubtitle> {
  List subtitle = [];

  void addStatusToSubtitle(subtitle) {
    for (var i in subtitle) {
      i['status'] = false;
    }
  }

  @override
  void initState() {
    addStatusToSubtitle(widget.subtitle);

    print(widget.subtitleName);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.navigate_next),
          onPressed: () {
            if (subtitle.isEmpty) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('لطفا مجموعه خود را انتخاب کنید'),
                        contentTextStyle: TextStyle(fontFamily: Myfont),
                      ));
            } else {
              registerInformationShop['subtitle'] = subtitle;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: endregister())));
            }
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: [
                for (var j in widget.subtitleName)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          j['name'],
                          style:
                              TextStyle(fontFamily: Myfont, color: Colors.grey),
                        ),
                      ),
                      for (var i in widget.subtitle)
                        if (i['subcategory_id'] == j['id'])
                          CheckboxListTile(
                              activeColor: secColor,
                              title: Text(
                                i['name'],
                                style: TextStyle(fontFamily: Myfont),
                              ),
                              value: i['status'],
                              onChanged: (cc) {
                                setState(() {
                                  i['status'] = cc;
                                });
                                if (i['status'] == true) {
                                  subtitle.add(i['id'].toString());
                                } else {
                                  subtitle.remove(i['id'].toString());
                                }
                                print(subtitle);
                              })
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
