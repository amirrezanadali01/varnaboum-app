import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/FirstLogin/ChangePassword.dart';

import '../Detail.dart';
import 'loginpage.dart';

class VerifyForgetPassword extends StatefulWidget {
  const VerifyForgetPassword({Key? key, required this.phoneNumber})
      : super(key: key);

  final int phoneNumber;

  @override
  _VerifyForgetPasswordState createState() => _VerifyForgetPasswordState();
}

class _VerifyForgetPasswordState extends State<VerifyForgetPassword> {
  late int status;
  TextEditingController verifyNumberController = TextEditingController();
  bool againSenSms = false;

  Future<String> CheckVerifyChangePassword(code) async {
    http.Response result = await http.get(Uri.parse(
        '$host/api/CheckVerifyChangePassword/${widget.phoneNumber}/$code/'));

    print(result.body);

    var token = jsonDecode(utf8.decode(result.bodyBytes));

    status = result.statusCode;

    if (result.statusCode == 201) {
      return token['message'];
    } else {
      return 'no';
    }
  }

  Future<void> VerifyCode() async {
    http.Response result =
        await http.post(Uri.parse('$host/api/CreateVerifyUser/'), body: {
      'number': widget.phoneNumber.toString(),
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
                EasyLoading.show(status: 'منتظر بمانید ...');

                if (verifyNumberController.text.isNotEmpty) {
                  String responseEnd = await CheckVerifyChangePassword(
                      int.parse(verifyNumberController.text));
                  if (status == 201) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePassword(
                                  token: responseEnd,
                                )));
                  } else {
                    EasyLoading.dismiss();
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(
                                'کد وارد شده اشتباه است',
                                style: TextStyle(fontFamily: Myfont),
                              ),
                            ));
                  }
                } else {
                  EasyLoading.dismiss();
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                              'کد وارد شده اشتباه است',
                              style: TextStyle(fontFamily: Myfont),
                            ),
                          ));
                }

                EasyLoading.dismiss();
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
                  'تغییر رمز عبور',
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
                            ' $minutes:$seconds تا ارسال پیامک',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Myfont,
                              color: Colors.grey,
                            ),
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
                        style:
                            TextStyle(color: Colors.green, fontFamily: Myfont),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
