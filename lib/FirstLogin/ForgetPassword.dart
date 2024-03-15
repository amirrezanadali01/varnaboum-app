import 'VerifyForgetPassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'loginpage.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  @override
  Widget build(BuildContext context) {
    TextEditingController phoneNumberController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradint1, gradint2])),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Hero(
                  tag: "logo",
                  child: Image(
                    image: AssetImage('assets/image/logo1.png'),
                    color: Colors.white,
                  )),
              InputLogin(
                  controller: phoneNumberController,
                  name: 'شماره همراه',
                  color: Colors.grey.shade200),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: buttonLogin,
                      borderRadius: BorderRadius.circular(100)),
                  margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    'احراز هویت',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: Myfont,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  if (phoneNumberController.text.isNotEmpty) {
                    if (phoneNumberController.text[0] == '0') {
                      phoneNumberController.text =
                          phoneNumberController.text.substring(1);
                    }

                    if (phoneNumberController.text.length != 10) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('شماره همراه درست نیست',
                                    style: TextStyle(fontFamily: Myfont)),
                              ));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyForgetPassword(
                                    phoneNumber:
                                        int.parse(phoneNumberController.text),
                                  )));
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('شماره همراه درست نیست',
                                  style: TextStyle(fontFamily: Myfont)),
                            ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
