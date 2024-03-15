import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/protocol.dart';
import '../base.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Detail.dart';
import 'package:varnaboomapp/FirstLogin/Register/BaseRegister.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:varnaboomapp/FirstLogin/Register/RegisterUser/RegisterUser.dart';
import 'ForgetPassword.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  late TextEditingController usernameText, passwordText;

  Future<void> getintroduce() async {
    var boxToken = await Hive.openBox('introduce');
    String? law = boxToken.get('law');
    if (law == null) {
      statusIntroduce = false;
      var box = await Hive.box('introduce');
      box.put('law', 'yes');
      setState(() {});
    } else {
      statusIntroduce = true;
    }
  }

  late bool statusIntroduce;

  @override
  void initState() {
    usernameText = TextEditingController();
    passwordText = TextEditingController();

    statusIntroduce = true;

    getintroduce();

    super.initState();
  }

  @override
  void dispose() {
    usernameText.dispose();
    passwordText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // HERE AFFFFFTEEEEEEEEERRRRRRRRR

    // if (statusIntroduce == false) {
    //   Future.delayed(
    //       Duration.zero,
    //       () => showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                 title: Text(
    //                   'کد وارد شده اشتباه است',
    //                   style: TextStyle(fontFamily: Myfont),
    //                 ),
    //               )));
    // }

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradint1, gradint2])),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
            child: Column(
          children: [
            Column(
              children: [
                Hero(
                    tag: "logo",
                    child: Image(
                      image: AssetImage('assets/image/logo1.png'),
                      width: 45.h,
                      height: 45.h,
                      color: Colors.white,
                    )),
                InputLogin(
                  controller: usernameText,
                  name: 'شماره تماس',
                ),
                SizedBox(
                  height: 10,
                ),
                InputLogin(
                  controller: passwordText,
                  name: 'گذرواژه',
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if (usernameText.text.isNotEmpty) {
                  if (usernameText.text[0] == '0') {
                    usernameText.text = usernameText.text.substring(1);
                  }
                }

                await loginToken(context,
                    username: usernameText.text, password: passwordText.text);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: buttonLogin,
                    borderRadius: BorderRadius.circular(100)),
                margin: EdgeInsets.only(left: 50, right: 50, bottom: 20),
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'ورود',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: Myfont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            GestureDetector(
              child: Text(
                'ثبت نام',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: Myfont,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterUser()));
              },
            ),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'فراموشی رمز عبور',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: Myfont,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgetPassword()));
              },
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => protocol())),
                child: Text(
                  'شرایط و قوانین استفاده و سیاست نامه حریم خصوصی وارنابوم را میپذیرم',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: Myfont,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}

class InputLogin extends StatelessWidget {
  const InputLogin(
      {Key? key,
      required this.controller,
      required this.name,
      this.color = Colors.white})
      : super(key: key);

  final TextEditingController controller;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      margin: EdgeInsets.only(left: 50, right: 50),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
      child: TextField(
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: Myfont,
        ),
        controller: controller,
        obscureText: name.contains('گذرواژه') ? true : false,
        enableSuggestions: name.contains('گذرواژه') ? false : true,
        autocorrect: name.contains('گذرواژه') ? true : false,
        keyboardType: name.contains('گذرواژه')
            ? TextInputType.text
            : TextInputType.number,
        decoration: InputDecoration(
          hintText: name,
          border: InputBorder.none,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
