import 'dart:developer';
import 'dart:io';

import 'package:donation/src/features/feed/widget/customText.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/app_icons.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';

class ComposeBottomIconWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(List<File>) onImageIconSelected;
  const ComposeBottomIconWidget(
      {Key? key,
      required this.textEditingController,
      required this.onImageIconSelected})
      : super(key: key);

  @override
  _ComposeBottomIconWidgetState createState() =>
      _ComposeBottomIconWidgetState();
}

class _ComposeBottomIconWidgetState extends State<ComposeBottomIconWidget> {
  bool reachToWarning = false;
  bool reachToOver = false;
  late Color wordCountColor;
  String tweet = '';

  @override
  void initState() {
    wordCountColor = Colors.blue;
    widget.textEditingController.addListener(updateUI);
    super.initState();
  }

  void updateUI() {
    setState(() {
      tweet = widget.textEditingController.text;
      if (widget.textEditingController.text.isNotEmpty) {
        if (widget.textEditingController.text.length > 259 &&
            widget.textEditingController.text.length < 280) {
          wordCountColor = Colors.orange;
        } else if (widget.textEditingController.text.length >= 280) {
          wordCountColor = Theme.of(context).colorScheme.error;
        } else {
          wordCountColor = Colors.blue;
        }
      }
    });
  }

  Widget _bottomIconWidget() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
              onPressed: () {
                setImageGallery();
              },
              icon: customIcon(context,
                  icon: AppIcon.image,
                  size: 24,
                  isTwitterIcon: true,
                  iconColor: primaryColor)),
          if (Platform.isIOS || Platform.isAndroid)
            IconButton(
                onPressed: () {
                  setImageCamera();
                },
                icon: customIcon(context,
                    icon: AppIcon.camera,
                    size: 24,
                    isTwitterIcon: true,
                    iconColor: primaryColor)),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: /*tweet != null &&*/ tweet.length > 289
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: customText(
                          '${280 - tweet.length}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: getTweetLimit(),
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(wordCountColor),
                          ),
                          tweet.length > 259
                              ? customText('${280 - tweet.length}',
                                  style: TextStyle(color: wordCountColor))
                              : customText('',
                                  style: TextStyle(color: wordCountColor))
                        ],
                      )),
          ))
        ],
      ),
    );
  }

  void setImageCamera() {
    // ImagePicker()
    //     .pickImage(source: ImageSource.camera, imageQuality: 20)
    //     .then((XFile? file) {
    //   if (file != null) {
    //     setState(() {
    //       widget.onImageIconSelected([File(file.path)]);
    //     });
    //   }
    // });
  }

  void setImageGallery() {
    // ImagePicker().pickMultiImage(imageQuality: 20).then((List<XFile>? files) {
    //   log("message: " + files!.length.toString());
    //   setState(() {
    //     List<File> results = [];
    //     if (files.isNotEmpty) {
    //       files.forEach((element) {
    //         results.add(File(element.path));
    //       });
    //     }
    //     widget.onImageIconSelected(results);
    //   });
    // });
  }

  double getTweetLimit() {
    if (tweet.isEmpty) {
      return 0.0;
    }
    if (tweet.length > 280) {
      return 1.0;
    }
    var length = tweet.length;
    var val = length * 100 / 28000.0;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _bottomIconWidget(),
    );
  }
}
