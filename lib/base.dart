import 'dart:convert';

import 'package:varnaboomapp/ProfileUser/NewProfilePage.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/MyTicket.dart';
import 'ContectUs.dart';
import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import '/Category/CategoriesPage.dart';

class baseWidget extends StatefulWidget {
  @override
  _baseWidgetState createState() => _baseWidgetState();
}

class _baseWidgetState extends State<baseWidget> {
  int _selectedIndex = 0;

  List<Widget> pages = [Category(), MyTicket(), ContectUs(), ProfileUser()];

  //pages[_selectedIndex]

  Future<void> CheckUpdate() async {
    http.Response version =
        await http.get(Uri.parse('$host/api/UpdateVersion/'));

    List decodeVersion = jsonDecode(utf8.decode(version.bodyBytes));
    print(decodeVersion);

    if (versionUpdate < decodeVersion[0]['version']) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                    'لطفا برنامه را از کافه بازار یا سیبچه به روزرسانی کنید',
                    style: TextStyle(fontFamily: Myfont)),
              ));
    }
  }

  @override
  void initState() {
    super.initState();
    CheckUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedLabelStyle:
            TextStyle(fontFamily: Myfont, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: Myfont),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message), label: 'صندوق پیام'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'تماس با ما',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
