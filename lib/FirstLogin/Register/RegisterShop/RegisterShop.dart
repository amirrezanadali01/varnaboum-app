import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import '../../loginpage.dart';

class RegisterShop extends StatefulWidget {
  @override
  _RegisterShoprState createState() => _RegisterShoprState();
}

class _RegisterShoprState extends State<RegisterShop> {
  TextEditingController username = TextEditingController();
  TextEditingController password1 = TextEditingController();
  TextEditingController password2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InputLogin(
              controller: username,
              name: 'شماره همراه',
              color: Colors.grey.shade200),
          SizedBox(
            height: 10,
          ),
          InputLogin(
              controller: password1,
              name: 'پسورد',
              color: Colors.grey.shade200),
          SizedBox(
            height: 10,
          ),
          InputLogin(
              controller: password2,
              name: 'پسورد دوباره',
              color: Colors.grey.shade200),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                color: buttonLogin, borderRadius: BorderRadius.circular(100)),
            margin: EdgeInsets.only(left: 50, right: 50),
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'بعدی',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
