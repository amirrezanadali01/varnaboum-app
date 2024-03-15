import 'package:flutter/material.dart';
import 'package:varnaboomapp/Detail.dart';
import 'RegisterUser/RegisterUser.dart';
import 'RegisterShop/RegisterShop.dart';

class BaseRegister extends StatefulWidget {
  @override
  State<BaseRegister> createState() => _BaseRegisterState();
}

class _BaseRegisterState extends State<BaseRegister> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: secColor,
          bottom: TabBar(tabs: [Text('کاربر'), Text('فروشگاه')]),
        ),
        body: TabBarView(children: [
          RegisterUser(),
          RegisterShop(),
        ]),
      ),
    );
  }
}
