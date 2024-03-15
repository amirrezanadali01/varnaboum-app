import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'end/RequiredRegisterPage.dart';
import 'package:varnaboomapp/Detail.dart';
import 'RegisterSubTitle.dart';

class RegiseterForm extends StatefulWidget {
  const RegiseterForm({
    Key? key,
    required this.subtitle,
  });

  final List subtitle;

  @override
  _RegiseterFormState createState() => _RegiseterFormState();
}

class _RegiseterFormState extends State<RegiseterForm> {
  List subcategory = [];
  List subtitle = [];
  List subtitleName = [];

  void addStatusToSubtitle(subtitle) {
    for (var i in subtitle) {
      i['status'] = false;
    }
  }

  @override
  void initState() {
    addStatusToSubtitle(widget.subtitle);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.navigate_next),
          onPressed: () {
            if (subcategory.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    if (subtitle.isNotEmpty) {
                      registerInformationShop['subcategory'] = subcategory;
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: RegiseterFormSubtitle(
                          subtitle: subtitle,
                          subtitleName: subtitleName,
                        ),
                      );
                    } else {
                      registerInformationShop['subcategory'] = subcategory;
                      return Directionality(
                          textDirection: TextDirection.rtl,
                          child: endregister());
                    }
                  },
                ),
              );
            } else {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('لطفا مجموعه خود را انتخاب کنید'),
                        contentTextStyle: TextStyle(fontFamily: Myfont),
                      ));
            }
          }),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: [
                for (var i in widget.subtitle)
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
                          i['subtitle']
                              .forEach((element) => subtitle.add(element));

                          subtitleName.add({'id': i['id'], 'name': i['name']});
                          subcategory.add(i['id'].toString());
                          print(subtitleName);
                        } else {
                          i['subtitle']
                              .forEach((element) => subtitle.remove(element));

                          subcategory.remove(i['id'].toString());

                          print(subtitleName);

                          subtitleName.removeWhere(
                              (element) => element['id'] == i['id']);
                        }
                        print(subcategory);
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
