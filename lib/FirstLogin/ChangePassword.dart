import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/Detail.dart';
import 'loginpage.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key, required this.token}) : super(key: key);

  final String token;

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController password1 = TextEditingController(),
      password2 = TextEditingController();

  Future<int> CreateNewPassword() async {
    http.Response result = await http.put(
        Uri.parse('$host/api/ChangePasswordView/${widget.token}/'),
        body: {'new_password': password2.text});

    return result.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
                tag: "logo",
                child: Image(
                  image: AssetImage('assets/image/logo1.png'),
                )),
            SizedBox(
              height: 10,
            ),
            InputLogin(
                controller: password1,
                name: 'گذرواژه',
                color: Colors.grey.shade200),
            SizedBox(
              height: 10,
            ),
            InputLogin(
                controller: password2,
                name: 'تایید گذرواژه',
                color: Colors.grey.shade200),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                EasyLoading.show(status: 'منتظر بمانید ...');

                if (password1.text != password2.text) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                              'گذرواژه درست نیست',
                              style: TextStyle(fontFamily: Myfont),
                            ),
                          ));
                } else {
                  int status = await CreateNewPassword();

                  print(widget.token);

                  if (status == 201) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => login()));
                  } else {
                    print('nnnnnnnnnnnnnnnnnnnnnnnnnnn');
                  }
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
                  'ثبت',
                  style: TextStyle(
                      color: Colors.white, fontSize: 20, fontFamily: Myfont),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
