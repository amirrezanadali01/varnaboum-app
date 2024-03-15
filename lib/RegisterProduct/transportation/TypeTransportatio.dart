import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/RegisterProduct/transportation/CategoryTypeTransportation.dart';

class TypeTransportation extends StatefulWidget {
  TypeTransportation({Key? key}) : super(key: key);

  @override
  State<TypeTransportation> createState() => _TypeTransportationState();
}

class _TypeTransportationState extends State<TypeTransportation> {
  int _val = 0;
  String _valName = 'bycecle';

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
                      child: CategoryTypeTransporation(type: _valName))));
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'نوع سواری خود را انتخاب کنید',
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
                child: ListView(
                  children: [
                    ListTile(
                      title:
                          Text('دوچرخه', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 0,
                          groupValue: _val,
                          onChanged: (_value) {
                            setState(() {
                              _val = _value as int;
                              _valName = 'bycecle';
                            });
                          }),
                    ),
                    ListTile(
                      title:
                          Text('موتور', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 1,
                          groupValue: _val,
                          onChanged: (_value) {
                            setState(() {
                              _val = _value as int;
                              _valName = 'motorcycle';
                            });
                          }),
                    ),
                    ListTile(
                      title:
                          Text('ماشین', style: TextStyle(fontFamily: Myfont)),
                      leading: Radio(
                          focusColor: secColor,
                          activeColor: secColor,
                          value: 2,
                          groupValue: _val,
                          onChanged: (_value) {
                            setState(() {
                              _val = _value as int;
                              _valName = 'car';
                            });
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
