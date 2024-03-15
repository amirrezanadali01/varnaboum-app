import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:video_player/video_player.dart';

class SamplePlayer extends StatefulWidget {
  SamplePlayer({required this.url});

  final String url;
  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<SamplePlayer> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    print(widget.url);
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.url),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
    print(widget.url);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secColor,
      ),
      body: Center(
        child: Container(
          height: 45.h,
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: FlickVideoPlayer(flickManager: flickManager),
          ),
        ),
      ),
    );
  }
}

class SampleVideoRetryProfile extends StatefulWidget {
  SampleVideoRetryProfile({Key? key, required this.url, this.height = 50})
      : super(key: key);
  final String url;
  final int height;

  @override
  State<SampleVideoRetryProfile> createState() =>
      _SampleVideoRetryProfileState();
}

class _SampleVideoRetryProfileState extends State<SampleVideoRetryProfile> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    print(widget.url);
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.url,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true)),
    );

    print('width video : ${flickManager.context?.size}');
  }

  @override
  void dispose() {
    flickManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: widget.height.h, //CalculateScale(context)
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: FlickVideoPlayer(flickManager: flickManager),
        ),
      ),
    );
  }
}

class SampleVideoPlayerBubble extends StatefulWidget {
  SampleVideoPlayerBubble({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<SampleVideoPlayerBubble> createState() =>
      _SampleVideoPlayerBubbleState();
}

class _SampleVideoPlayerBubbleState extends State<SampleVideoPlayerBubble> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    print(widget.url);
    flickManager = FlickManager(
      autoPlay: false,
      videoPlayerController: VideoPlayerController.network(
          'https://hajifirouz6.asset.aparat.com/aparat-video/d0f7b054a8e150d0ba8d0a4c9a9dae7e48397704-144p.mp4?wmsAuthSign=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbiI6ImZiMzc2ZWMyNjA1YjZkMjQ4MDBiOTg4YWM0Yjc5MDVjIiwiZXhwIjoxNjY2ODkzODUwLCJpc3MiOiJTYWJhIElkZWEgR1NJRyJ9.FUW7sFGBzAp-Eu_ku9qtuIuI6E3ix2cNP3aufT2CCjk',
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true)),
    );

    print('width video : ${flickManager.context?.size}');
  }

  @override
  void dispose() {
    flickManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(flickManager: flickManager);
  }
}
