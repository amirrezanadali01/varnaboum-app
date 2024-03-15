import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';

class InfoOffice extends StatefulWidget {
  InfoOffice(
      {Key? key,
      this.instagram,
      this.video,
      this.phone,
      this.lat,
      this.lng,
      required this.profile,
      required this.preview,
      required this.about,
      required this.address})
      : super(key: key);

  final String preview;
  final String profile;
  final String? instagram;
  final String? video;
  final int? phone;
  final String about;
  final String address;
  final String? lat;
  final String? lng;

  @override
  State<InfoOffice> createState() => _InfoOfficeState();
}

class _InfoOfficeState extends State<InfoOffice> {
  List<Widget> option = [];
  @override
  void initState() {
    if (widget.phone != null) {
      option.add(
        IconButton(
          icon: Icon(
            Icons.phone,
            size: 4.20.h,
            color: Colors.greenAccent,
          ),
          onPressed: () async => {await launch("tel:+98${widget.phone}")},
        ),
      );
    }
    if (widget.lat != null) {
      option.add(
        IconButton(
            icon: Icon(
              Icons.location_on,
              size: 4.20.h,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              print(
                  "https://www.google.com/maps/search/?api=1&query=${widget.lat},${widget.lng}");

              await launch("geo:${widget.lat},${widget.lng}");
            }),
      );
    }

    if (widget.video != null) {
      option.add(
        IconButton(
          icon: Icon(
            Icons.movie,
            size: 4.20.h,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SampleVideoRetryProfile(
                    url: widget.video as String,
                  );
                });
          },
        ),
      );
    }
    if (widget.instagram != null) {
      option.add(IconButton(
          icon: LineIcon.instagram(
            size: 4.20.h,
            color: Colors.pinkAccent,
          ),
          onPressed: () async {
            await launch("https://www.instagram.com/${widget.instagram}/");
          }));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 5.h),
                  width: double.infinity,
                  child: Container(
                    height: 25.h,
                    child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Color(0xffeeeeee),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 30.sp,
                                            )),
                                        CachedNetworkImage(
                                          imageUrl: widget.preview,
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.preview,
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                ),
                // CircleAvatar(
                //   radius: 5.h, // infoUser['profile']

                //   backgroundImage: NetworkImage(infoUser['profile']),
                // ),

                CachedNetworkImage(
                    imageUrl: widget.profile,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 5.h,
                          backgroundImage: imageProvider,
                        ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: option,
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آدرس',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          widget.address,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (widget.about != '')
                        Text(
                          'درباره ما',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          widget.about,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
