import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:url_launcher/url_launcher.dart';

final formatter = NumberFormat("#,###", "en_US");

final downloadableUrlProvider = StateProvider((ref) => "");
final uploadProgressProvider = StateProvider((ref) => 0);

class Utils {
  static String strToMM(String str) {
    String converted;

    converted = str;

    // converted = formatter.format(int.parse(str));

    converted = converted.replaceAll(RegExp('0'), "၀");
    converted = converted.replaceAll(RegExp('1'), "၁");
    converted = converted.replaceAll(RegExp('2'), "၂");
    converted = converted.replaceAll(RegExp('3'), "၃");
    converted = converted.replaceAll(RegExp('4'), "၄");
    converted = converted.replaceAll(RegExp('5'), "၅");
    converted = converted.replaceAll(RegExp('6'), "၆");
    converted = converted.replaceAll(RegExp('7'), "၇");
    converted = converted.replaceAll(RegExp('8'), "၈");
    converted = converted.replaceAll(RegExp('9'), "၉");

    return converted;
  }

  static bool isNumeric(String? s) {
    bool exist = false;
    List<String> match = ["၀", "၁", "၂", "၃", "၄", "၅", "၆", "၇", "၈", "၉"];
    for (int i = 0; i < match.length; i++) {
      if (s!.contains(match[i])) {
        exist = true;
        break;
      }
    }
    if (exist) return true;
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static String getPostTime2(DateTime date) {
    var dat = DateFormat.jm().format(date) +
        ' - ' +
        DateFormat("dd MMM yy").format(date);
    return dat;
  }

  static String getChatTime(DateTime date) {
    String msg = '';
    var dt = date.toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(date.toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    if (dur.inDays > 365) {
      msg = DateFormat.yMMMd().format(dt);
    } else if (dur.inDays > 30) {
      msg = DateFormat.yMMMd().format(dt);
    } else if (dur.inDays > 0) {
      msg = '${dur.inDays} days ago';
      return dur.inDays == 1 ? '1 day ago' : DateFormat.MMMd().format(dt);
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours} hours ago';
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes} minutes ago';
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds} seconds ago';
    } else {
      msg = 'now';
    }
    return msg;
  }

  static void copyToClipBoard({
    required BuildContext context,
    required String text,
    required String message,
  }) {
    var data = ClipboardData(text: text);
    Clipboard.setData(data);
    customSnackBar(context, message);
  }

  static customSnackBar(BuildContext context, String msg,
      {double height = 30, Color backgroundColor = Colors.black}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showCupertinoDatePicker(
      BuildContext context, Function onDateTimeChanged) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: MediaQuery.of(context).size.height * 0.2,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 28, bottom: 20),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("အိုကေ",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  )),
            ),
          ),
        ],
        titlePadding: const EdgeInsets.only(left: 16.0, top: 16.0),
        title: const Text("ရက်စွဲအား ရွေးချယ်ပါ",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            )),
        content: SizedBox(
          width: Responsive.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.width * 0.3,
          child: DatePickerWidget(
            dateFormat: 'dd MMM yyyy',
            initialDateTime: DateTime.parse("1990-01-01"),
            pickerTheme: DateTimePickerTheme(
              backgroundColor: Colors.white,
              cancel: Container(),
              confirm: Container(),
              itemTextStyle: const TextStyle(fontSize: 17, color: Colors.red),
              pickerHeight: MediaQuery.of(context).size.height * 0.35,
              titleHeight: 0,
              itemHeight: 30.0,
            ),
            onChange: (newDateTime, selectedIndex) {
              onDateTimeChanged(newDateTime);
            },
          ),
        ),
      ),
    );
  }

  static YYDialog messageSuccessDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "assets/images/checked.png",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.pop(context);
              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context);
              // }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  static YYDialog messageSuccessSinglePopDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "assets/images/checked.png",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  static YYDialog messageSuccessNoPopDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "assets/images/checked.png",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.pop(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  static YYDialog messageDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          SvgPicture.asset(
            "assets/images/warn.svg",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16 : 18,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  static Future<List<String>> uploadToFireStorage(
      List<File> files, WidgetRef ref) async {
    List<String> _downloadUrls = [];

    // Create a reference to the Firebase Storage bucket
    // final storageRef = FirebaseStorage.instance.ref();

    // // Upload file and metadata to the path 'images/mountains.jpg'
    // await Future.forEach(files, (file) async {
    //   var uploadTask =
    //       storageRef.child("images/" + file.path.split("/").last).putFile(file);
    //   var taskSnapshot = await uploadTask.whenComplete(() {});
    //   final url = await taskSnapshot.ref.getDownloadURL();
    //   log(url);
    //   _downloadUrls.add(url);
    // });
    return _downloadUrls;
  }

  static launchURL(String url) async {
    if (url == "") {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Could not launch $url');
    }
  }

  static Future<bool> sendMessageByFcm(Map<String, dynamic> data) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAA6P6BMbU:APA91bFX33mNlKV8TNsT2muiLsn99wV5bXuarVrgT9XpQJDSaRRRx6o2lRKrpiWDV63ZwFGPZAd1_xIobDLyNeOoj54fazrkd7ehJ_HZIGBSFqH71r5WcbR_YwEoVTrszOGlJ3HVTQic'
    };

    final response = await http.post(Uri.parse(

            //"https://fcm.googleapis.com/v1/projects/redjuniors-be113/messages:send",
            // "https://fcm.googleapis.com/v1/redjuniors-be113/messages:send"
            'https://fcm.googleapis.com/fcm/send'),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    log(response.body);
    if (response.statusCode == 200) {
      // on success do sth
      return true;
    } else {
      // on failure do sth
      return false;
    }
  }
}

Future<File> compressFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 88,
  );

  print(file.lengthSync());

  return File(result!.path);
}

extension on DateTime {
  String formatDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }
}

extension FormatExtension on DateTime {
  String string(String pattern) {
    try {
      return new DateFormat(pattern).format(this);
    } catch (e) {
      return "";
    }
  }
}
