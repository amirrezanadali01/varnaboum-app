import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class VerifyNumber extends StatefulWidget {
  VerifyNumber({
    required this.username,
    required this.password,
  });
  final String username, password;

  @override
  _VerifyNumberState createState() => _VerifyNumberState();
}

class _VerifyNumberState extends State<VerifyNumber> {
  TextEditingController verifyNumberController = TextEditingController();

  late int code;
  late bool status;
  bool againSenSms = false;

  Future<int> RegisterUser() async {
    http.Response user = await http.post(Uri.parse('$host/api/registerUser/'),
        body: {"username": widget.username, 'password': widget.password});

    print(user.statusCode);
    print(user.body);

    return user.statusCode;
  }

  Future<bool> CheckVerify(code) async {
    http.Response result = await http
        .get(Uri.parse('$host/api/CheckVerifyCode/${widget.username}/$code/'));

    print(result.body);

    if (result.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> VerifyCode() async {
    http.Response result =
        await http.post(Uri.parse('$host/api/CreateVerifyUser/'), body: {
      'number': widget.username,
    });
    if (result.statusCode == 201) {
      print(true);
    } else {
      print(false);
    }
  }

  @override
  void initState() {
    VerifyCode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.username);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
                tag: "logo",
                child: Image(
                  image: AssetImage('assets/image/logo1.png'),
                )),
            InputLogin(
                color: Colors.grey.shade200,
                controller: verifyNumberController,
                name: 'کد'),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await EasyLoading.show(status: 'منتظر بمانید ...');
                bool responseEnd =
                    await CheckVerify(int.parse(verifyNumberController.text));

                EasyLoading.dismiss();

                print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
                print(responseEnd);
                print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');

                if (responseEnd == true) {
                  final int status = await RegisterUser();
                  if (status == 201) {
                    loginToken(context,
                        username: widget.username, password: widget.password);
                  }
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                              'کد وارد شده اشتباه است',
                              style: TextStyle(fontFamily: Myfont),
                            ),
                          ));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: buttonLogin,
                    borderRadius: BorderRadius.circular(100)),
                margin: EdgeInsets.only(left: 50, right: 50),
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'ثبت نام',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: Myfont,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            againSenSms == false
                ? TweenAnimationBuilder<Duration>(
                    duration: Duration(minutes: 2),
                    tween:
                        Tween(begin: Duration(minutes: 2), end: Duration.zero),
                    onEnd: () {
                      setState(() {
                        againSenSms = true;
                      });
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      final minutes = value.inMinutes;
                      final seconds = value.inSeconds % 60;
                      return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(
                            'تا ارسال پیامک $minutes:$seconds',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey, fontFamily: Myfont),
                          ));
                    })
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          VerifyCode();
                          againSenSms = false;
                        });
                      },
                      child: Text(
                        ' ارسال دوباره پیامک ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Myfont,
                          color: Colors.green,
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
