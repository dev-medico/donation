import 'package:flutter/material.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardError extends StatelessWidget {
  const DashboardError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/playstore-icon.png",
                    height: 60,
                    width: 60,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 0, 40, 0),
                    child: const Text(
                      "Session Expired !",
                      textAlign: TextAlign.left,
                      maxLines: 4,
                      style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(5, 24, 0, 0),
                child: const Text(
                  "အကောင့် Session Expired ဖြစ်သွားပါပြီ \nပြန်လည်၀င်ရောက်ရန် လိုအပ်ပါသည်",
                  textAlign: TextAlign.left,
                  maxLines: 4,
                  style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 14,
                    left: 16,
                    right: 16,
                    bottom: 34),
                child: MaterialButton(
                    child: Container(
                      height: 52,
                      width: MediaQuery.of(context).size.width / 1.4,
                      decoration: shadowDecoration(secondColor),
                      child: const Center(
                        child: Text(
                          "ပြန်လည်၀င်ရောက်မည်",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.routeName,
                          (Route<dynamic> route) => false);
                    }),
              ),
            ],
          )
          // Text('This is a demo alert dialog.'),
        ],
      ),
    );
  }
}
