import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewFeedScreen extends ConsumerStatefulWidget {
  const NewFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NewFeedScreen> createState() => _NewFeedScreenState();
}

class _NewFeedScreenState extends ConsumerState<NewFeedScreen> {
  String? selectedType;
  File? file;
  bool isLoading = false;
  List<String> donationItems = [
    "အသိပေးချက်",
    "ပို့စ်များ",
  ];

  TextEditingController aboutController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  String todayDate = "-";
  late String dateFilter;
  List<File> imagesToUpload = [];
  List<String> imagesUploaded = [];

  @override
  void initState() {
    super.initState();
    iniitial();
  }

  iniitial() async {
    var currentTime = DateTime.now().toLocal();

    final format1 = DateFormat('yyyy-MM-dd');
    final format2 = DateFormat('dd MMM yyyy');
    todayDate = format2.format(currentTime);
    dateFilter = format1.format(currentTime);
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    int progress = ref.watch(uploadProgressProvider);
    if (progress == 100) {
      Future.delayed(Duration(seconds: 2)).then((value) {
        String link = ref.watch(downloadableUrlProvider);
        imagesUploaded.add(link);
        ref.invalidate(uploadProgressProvider);
      });
    }
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text("Post",
                style: TextStyle(fontSize: 17, color: Colors.white)),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, left: 4, right: 20),
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                "အမျိုးအစား",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 6, bottom: 12),
              child: DropdownButtonFormField2(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                isExpanded: true,
                hint: const Text(
                  "အမျိုးအစားရွေးချယ်ပါ",
                  style: TextStyle(fontSize: 14),
                ),
                iconStyleData: IconStyleData(
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black45,
                  ),
                  iconSize: 30,
                ),
                buttonStyleData: ButtonStyleData(
                  height: 48,
                  padding: const EdgeInsets.only(left: 4, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: donationItems
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return "Please Select Role";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedType = value.toString();
                  });
                },
                onSaved: (value) {
                  setState(() {
                    selectedType = value.toString();
                  });
                },
              ),
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
              height: 90,
              width: MediaQuery.of(context).size.width * 0.4,
              margin:
                  const EdgeInsets.only(left: 20, top: 6, bottom: 4, right: 20),
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
                    contentPadding:
                        EdgeInsets.only(left: 15, bottom: 8, top: 6, right: 15),
                    hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                  )),
            ),
            buildImageList(),
            Container(
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
                      left: 24.0,
                      right: 24.0,
                    ),
                    child: Text("ပို့စ်တင်မည်",
                        textScaleFactor: 1.0,
                        style: TextStyle(fontSize: 16.0, color: Colors.white)),
                  ),
                ),
                onPressed: () {
                  if (selectedType == null) {
                    Utils.messageDialog("ကဏ္ဏ ရွေးချယ်ပေးရန် \nလိုအပ်ပါသည်။",
                        context, "ပြင်ဆင်မည်", Colors.black);
                  } else {
                    createPost(selectedType.toString(),
                        aboutController.text.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  createPost(String type, String remark) async {
    setState(() {
      isLoading = true;
    });

    for (int i = 0; i < imagesToUpload.length; i++) {}

    final data = {
      "message": {
        "notification": {"body": "this is a body", "title": "this is a title"},
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done"
        },
        "topic": "notifications"
      }
    };
    final oldData = {
      "to": "/topics/notifications",
      "notification": {"title": "Breaking News", "body": remark},
      "data": {"title": "New Notification!", "body": remark}
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

  buildImageList() {
    if (imagesUploaded.isNotEmpty) {
      //return list of image widgets from images array.kl[;...]
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imagesUploaded.length + 1,
          itemBuilder: (context, index) {
            if (index == imagesUploaded.length) {
              return GestureDetector(
                onTap: () {
                  showChooseDialog();
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 24, top: 12),
                    height: 100,
                    width: 100,
                    child: Image.asset("assets/images/add_photo.png"),
                  ),
                ),
              );
            } else {
              return Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(left: 12, top: 12),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(imagesUploaded[index])),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imagesUploaded.removeAt(index);
                          });
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          showChooseDialog();
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 24, top: 12),
            height: 100,
            width: 100,
            child: Image.asset("assets/images/add_photo.png"),
          ),
        ),
      );
    }
  }

  void showChooseDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.28,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogGradientTitleWidget(
                  title: "ရွေးချယ်ရန်",
                  width: 400,
                  height: 60,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                    getImagefromGallery();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 32,
                      top: 20,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 32,
                          color: primaryColor,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          "Choose From Gallery",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                    getImagefromCamera();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 34),
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera,
                          size: 32,
                          color: primaryColor,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          "Take By Camera",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future getImagefromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      file = File(image!.path);
    });
    setState(() {
      imagesToUpload.add(file!);
    });
    final Directory tempDir = await getApplicationDocumentsDirectory();

    var result =
        await compressFile(file!, tempDir.path + file!.path.split("/").last);
    Utils.uploadToFireStorage(result, ref);
  }

  Future getImagefromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      file = File(image!.path);
    });

    setState(() {
      imagesToUpload.add(file!);
    });
  }
}
