import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Category/Products/Estate/UpdateProductEstateText.dart';
import 'package:varnaboomapp/base.dart';
import '../../../Detail.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

class EstateProductRetryUpdate extends StatefulWidget {
  EstateProductRetryUpdate({Key? key, required this.id, required this.data})
      : super(key: key);

  final int id;
  final Map data;

  @override
  State<EstateProductRetryUpdate> createState() =>
      _EstateProductRetryUpdateState();
}

class _EstateProductRetryUpdateState extends State<EstateProductRetryUpdate> {
  Future<Map> getProduct() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/GetRetrieveProductsEatate/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    return jsonDecode(utf8.decode(result.bodyBytes));
  }

  Future<List> getImageProduct() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    print(widget.id);
    http.Response result = await http.get(
        Uri.parse('$host/api/GetRetrieveImageProductsEatate/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    return jsonDecode(result.body);
  }

  Future<void> removeProductsEstate() async {
    EasyLoading.show(status: 'منتظر بمانید ...');
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.delete(
        Uri.parse('$host/api/RemoveProductsEstate/${widget.id}/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);

    EasyLoading.dismiss();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Directionality(
                textDirection: TextDirection.rtl, child: baseWidget())));
  }

  late Map data;
  late List<Expanded> iconsEstate = [];

  @override
  void initState() {
    data = widget.data;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: Text('میخواهید این محصول کامل حذف کنید؟'),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                await removeProductsEstate();
                              },
                              child: Text(
                                'حذف',
                                style: TextStyle(fontFamily: Myfont),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'انصراف',
                                style: TextStyle(fontFamily: Myfont),
                              ))
                        ],
                      ),
                    );
                  });
            },
            icon: Icon(
              Icons.delete,
              size: 29,
              color: Colors.redAccent,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List>(
                future: getImageProduct(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return new Center(
                      child: new CircularProgressIndicator(
                        color: secColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Container();
                  } else {
                    return GestureDetector(
                      onTap: () {
                        print('iiiii');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 30.h,
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: PageView(
                            children: [
                              for (var i in snapshot.data!)
                                Image(
                                  image: NetworkImage(i['image']),
                                  fit: BoxFit.cover,
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }),
            Padding(
                padding: EdgeInsets.only(left: 10.sp, right: 10.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: UpdateproductEstateText(
                                  field: 'name',
                                  id: widget.id,
                                  name: 'عنوان',
                                  text: data['name'],
                                ),
                              ),
                            ),
                          ),
                          child: Card(
                            child: Text(
                              data['name'],
                              style: TextStyle(
                                  fontFamily: Myfont,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (data['price'] != null)
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateproductEstateText(
                                field: 'price',
                                id: widget.id,
                                isNumber: true,
                                name: '(تومان)قیمت',
                                text: data['price'].toString(),
                              ),
                            )),
                        child: Card(
                          child: Row(
                            children: [
                              Text('قیمت(تومان)',
                                  style: TextStyle(
                                      fontFamily: Myfont,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: Text(
                                data['price']
                                    .toString()
                                    .seRagham()
                                    .toPersianDigit(),
                                style: TextStyle(fontFamily: Myfont),
                              )),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (data['rent'] != null)
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateproductEstateText(
                                field: 'rent',
                                id: widget.id,
                                isNumber: true,
                                name: '(تومان) اجاره',
                                text: data['rent'].toString(),
                              ),
                            )),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('اجاره',
                                  style: TextStyle(
                                      fontFamily: Myfont,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: Text(
                                data['rent']
                                    .toString()
                                    .seRagham()
                                    .toPersianDigit(),
                                style: TextStyle(fontFamily: Myfont),
                              )),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (data['mortgage'] != null)
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateproductEstateText(
                                field: 'mortgage',
                                id: widget.id,
                                isNumber: true,
                                name: '(تومان) رهن',
                                text: data['mortgage'].toString(),
                              ),
                            )),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('رهن',
                                  style: TextStyle(
                                      fontFamily: Myfont,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: Text(
                                data['mortgage']
                                    .toString()
                                    .seRagham()
                                    .toPersianDigit(),
                                style: TextStyle(fontFamily: Myfont),
                              )),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: UpdateproductEstateText(
                                    field: 'LanArea',
                                    id: widget.id,
                                    isNumber: true,
                                    name: 'متراژ زمین',
                                    text: data['LanArea'].toString(),
                                  ),
                                ),
                              ),
                            ),
                            child: Card(
                              child: Text(
                                'متراژ زمین ${data['LanArea']}'
                                    .toPersianDigit(),
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontSize: 15,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateproductEstateText(
                                      field: 'BuildingArea',
                                      id: widget.id,
                                      isNumber: true,
                                      name: 'متراژ بنا',
                                      text: data['BuildingArea'].toString(),
                                    ),
                                  ),
                                )),
                            child: Card(
                              child: Text(
                                'متراژ بنا ${data['BuildingArea']}'
                                    .toPersianDigit(),
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontSize: 15,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: UpdateproductEstateText(
                                      field: 'year',
                                      id: widget.id,
                                      isNumber: true,
                                      name: 'سال ساخت',
                                      text: data['year'].toString(),
                                    ),
                                  ),
                                )),
                            child: Card(
                              child: Text(
                                'سال ساخت ${data['year']}'.toPersianDigit(),
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontSize: 15,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color.fromARGB(255, 172, 162, 162),
                      thickness: 1.0,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(LineIcons.city),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          data['CityName'],
                          style: TextStyle(
                              fontFamily: Myfont,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 75, 75, 75)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        // if (data['village'] != null) Text(','),
                        // SizedBox(
                        //   width: 5,
                        // ),
                        // if (data['village'] != null)
                        //   Text(
                        //     data['village'].toString(),
                        //     style: TextStyle(
                        //         fontFamily: Myfont,
                        //         fontWeight: FontWeight.w300,
                        //         fontStyle: FontStyle.italic,
                        //         color: Color.fromARGB(255, 75, 75, 75)),
                        //   ),
                      ],
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: UpdateproductEstateText(
                                field: 'address',
                                id: widget.id,
                                name: 'ادرس',
                                text: data['address'].toString(),
                              ),
                            ),
                          )),
                      child: Card(
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Text(
                              data['address'],
                              style: TextStyle(fontFamily: Myfont),
                            )),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            LineIcon(
                              LineIcons.parking,
                              size: 50,
                              color: data['parking'] == true
                                  ? Colors.greenAccent
                                  : null,
                            ),
                            Text(
                              'پارکینگ',
                              style: TextStyle(
                                fontFamily: Myfont,
                                color: data['parking'] == true
                                    ? Colors.greenAccent
                                    : null,
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                          child: Column(
                            children: [
                              LineIcon(
                                LineIcons.warehouse,
                                size: 50,
                                color: data['warehouse'] == true
                                    ? Colors.greenAccent
                                    : null,
                              ),
                              Text(
                                'انباری',
                                style: TextStyle(
                                  fontFamily: Myfont,
                                  color: data['warehouse'] == true
                                      ? Colors.greenAccent
                                      : null,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              color: data['room'] != null
                                  ? Colors.greenAccent
                                  : null,
                              size: 50,
                            ),
                            if (data['room'] != null)
                              Text(
                                '${data['room']} اتاق',
                                style: TextStyle(
                                  fontFamily: Myfont,
                                  color: data['room'] != null
                                      ? Colors.greenAccent
                                      : null,
                                ),
                              ),
                            if (data['room'] == null)
                              Text(
                                'اتاق',
                                style: TextStyle(
                                  fontFamily: Myfont,
                                  color: data['room'] != null
                                      ? Colors.greenAccent
                                      : null,
                                ),
                              )
                          ],
                        )),
                        Expanded(
                          child: Column(
                            children: [
                              Icon(
                                Icons.balcony_outlined,
                                size: 50,
                                color: data['balcony'] == true
                                    ? Colors.greenAccent
                                    : null,
                              ),
                              Text(
                                'بالکن',
                                style: TextStyle(
                                  fontFamily: Myfont,
                                  color: data['balcony'] == true
                                      ? Colors.greenAccent
                                      : null,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    if (data['description'] != null)
                      Card(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: UpdateproductEstateText(
                                  field: 'description',
                                  id: widget.id,
                                  name: 'توضیحات',
                                  text: data['description'],
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            data['description'],
                            style: TextStyle(fontFamily: Myfont),
                          ),
                        ),
                      ),
                    if (data['description'] == null)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: UpdateproductEstateText(
                                field: 'description',
                                id: widget.id,
                                name: 'توضیحات',
                                text: data['description'],
                              ),
                            ),
                          ),
                        ),
                        child: Card(
                            child: Text('توضیحات',
                                style: TextStyle(fontFamily: Myfont))),
                      ),
                    SizedBox(height: 15.h),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
