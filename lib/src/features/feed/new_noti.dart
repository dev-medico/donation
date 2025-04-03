import 'dart:developer';
import 'dart:io';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';

class NewNotiScreen extends ConsumerStatefulWidget {
  const NewNotiScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewNotiScreen> createState() => _NewNotiScreenState();
}

class _NewNotiScreenState extends ConsumerState<NewNotiScreen> {
  bool isLoading = false;

  TextEditingController aboutController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text("အသိပေးချက်",
                style: TextStyle(fontSize: 17, color: Colors.white)),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 4, right: 20),
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    "ခေါင်းစဥ်",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.only(
                      left: 20, top: 6, bottom: 4, right: 20),
                  decoration: const BoxDecoration(
                      color: Color(0xFFEDEDED),
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  child: TextFormField(
                      controller: titleController,
                      onSaved: (value) {},
                      style: const TextStyle(
                        height: 1.0,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "",
                        labelStyle: TextStyle(
                          height: 1.0,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 8, top: 6, right: 15),
                        hintStyle:
                            TextStyle(fontSize: 15.0, color: Colors.grey),
                      )),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, left: 4, right: 20),
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    "အကြောင်းအရာ",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Container(
                  height: 110,
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.only(
                      left: 20, top: 6, bottom: 4, right: 20),
                  decoration: const BoxDecoration(
                      color: Color(0xFFEDEDED),
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  child: TextFormField(
                      controller: aboutController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onSaved: (value) {},
                      // controller: name,
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "",
                        labelStyle: TextStyle(
                          height: 1.0,
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 8, top: 12, right: 15),
                        hintStyle:
                            TextStyle(fontSize: 15.0, color: Colors.grey),
                      )),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
                      colors: [primaryColor, primaryColor]),
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 30, bottom: 20),
                child: MaterialButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  splashColor: primaryColor,
                  minWidth: MediaQuery.of(context).size.width,
                  child: Container(
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 8, bottom: 8),
                      child: Text("ပေးပို့မည်",
                          textScaleFactor: 1.0,
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                    ),
                  ),
                  onPressed: () {
                    createNotification(titleController.text.toString(),
                        aboutController.text.toString());
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  createNotification(String title, String body) async {
    setState(() {
      isLoading = true;
    });

    final oldData = {
      "to": "/topics/notifications",
      "notification": {"title": title, "body": body},
      "data": {"title": title, "body": body}
    };
    final response = await Utils.sendMessageByFcm(oldData);
    log("Result -  " + response.toString());

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
