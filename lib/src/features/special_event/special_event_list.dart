import 'dart:convert';
import 'dart:developer';

import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/special_event_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/special_event/edit_special_event.dart';
import 'package:merchant/src/features/special_event/new_special_event.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:http/http.dart' as http;

class SpecialEventListScreen extends StatefulWidget {
  static const routeName = "/special_event_list";
  const SpecialEventListScreen({Key? key}) : super(key: key);

  @override
  State<SpecialEventListScreen> createState() => _SpecialEventListScreenState();
}

class _SpecialEventListScreenState extends State<SpecialEventListScreen> {
  List<SpecialEventData>? data = [];
  @override
  void initState() {
    super.initState();
    getEventsFromXata();
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 252, 231),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("ထူးခြားဖြစ်စဥ်များ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 17,
                  color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEventAddScreen(),
            ),
          );
          getEventsFromXata();
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
        child: buildSimpleTable(data!),
      ),
    );
  }

  ExpandableTable buildSimpleTable(List<SpecialEventData> data) {
    const int COLUMN_COUNT = 10;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "Retro Test\n ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ",
      "Hbs Ag\n အသည်းရောင် အသားဝါ(ဘီ)ပိုး",
      "HCV Ab\n အသည်းရောင် အသားဝါ(စီ)ပိုး",
      "VDRL Test\n ကာလသားရောဂါ",
      "M.P ( I.C.T )\n ငှက်ဖျားရောဂါ",
      "Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း",
      "Lab Name\n ဓါတ်ခွဲခန်းအမည်",
      "Total\n စုစုပေါင်း",
      "လုပ်ဆောင်ချက်"
    ];

    //Creation header
    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: Responsive.isMobile(context) ? 80 : 120,
            color: primaryColor,
            height: 74,
            margin: const EdgeInsets.all(1),
            child: const Center(
                child: Text(
              'ရက်စွဲ',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))),
        children: List.generate(
            COLUMN_COUNT - 1,
            (index) => Container(
                color: primaryColor,
                height: 74,
                margin: const EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  titles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 15,
                      color: Colors.white),
                )))));
    //Creation rows
    List<ExpandableTableRow> rows = List.generate(
        ROWCOUNT,
        (rowIndex) => ExpandableTableRow(
              height: 50,
              firstCell: Container(
                  color: const Color(0xffe1e1e1),
                  margin: const EdgeInsets.all(1),
                  child: Center(
                      child: Text(
                    data[rowIndex].date.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ))),
              children: List<Widget>.generate(
                  COLUMN_COUNT - 1,
                  (columnIndex) => GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditSpecialEventScreen(
                                        event: data[rowIndex],
                                      )));
                          getEventsFromXata();
                        },
                        child: columnIndex == 8
                            ? Container(
                                decoration:
                                    borderDecorationNoRadius(Colors.grey),
                                margin: const EdgeInsets.all(1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                        onPressed: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditSpecialEventScreen(
                                                        event: data[rowIndex],
                                                      )));
                                          getEventsFromXata();
                                        }),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          confirmDeleteDialog(
                                              "ဖျက်မည်မှာ သေချာပါသလား?",
                                              "ထူးခြားဖြစ်စဥ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                              context,
                                              "အိုကေ",
                                              Colors.black, () {
                                            XataRepository()
                                                .deleteSpecialEventByID(
                                              data[rowIndex].id.toString(),
                                            )
                                                .then((value) {
                                              if (value.statusCode
                                                  .toString()
                                                  .startsWith("2")) {
                                                Utils.messageSuccessNoPopDialog(
                                                    "ထူးခြားဖြစ်စဥ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                    context,
                                                    "အိုကေ",
                                                    Colors.black);
                                                getEventsFromXata();
                                              }
                                            });
                                          });
                                        }),
                                  ],
                                ),
                              )
                            : Container(
                                decoration:
                                    borderDecorationNoRadius(Colors.grey),
                                margin: const EdgeInsets.all(1),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 14),
                                  child: Text(
                                    columnIndex == 0
                                        ? Utils.strToMM(
                                            data[rowIndex].retroTest.toString())
                                        : columnIndex == 1
                                            ? Utils.strToMM(
                                                data[rowIndex].hbsAg.toString())
                                            : columnIndex == 2
                                                ? Utils.strToMM(data[rowIndex]
                                                    .hcvAb
                                                    .toString())
                                                : columnIndex == 3
                                                    ? Utils.strToMM(
                                                        data[rowIndex]
                                                            .vdrlTest
                                                            .toString())
                                                    : columnIndex == 4
                                                        ? Utils.strToMM(
                                                            data[rowIndex]
                                                                .mpIct
                                                                .toString())
                                                        : columnIndex == 5
                                                            ? Utils.strToMM(
                                                                data[rowIndex]
                                                                    .haemoglobin
                                                                    .toString())
                                                            : columnIndex == 6
                                                                ? data[rowIndex]
                                                                            .labName !=
                                                                        null
                                                                    ? data[rowIndex]
                                                                        .labName
                                                                        .toString()
                                                                    : "-"
                                                                : columnIndex ==
                                                                        7
                                                                    ? data[rowIndex].total !=
                                                                            null
                                                                        ? Utils.strToMM(data[rowIndex]
                                                                            .total
                                                                            .toString())
                                                                        : "-"
                                                                    : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 16
                                            : 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                      )),
            ));

    return ExpandableTable(
      rows: rows,
      header: header,
      cellWidth: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.23
          : MediaQuery.of(context).size.width * 0.135,
      cellHeight: 48,
      headerHeight: 74,
      firstColumnWidth: Responsive.isMobile(context) ? 94 : 200,
      scrollShadowColor: Colors.grey,
    );
  }

  YYDialog confirmDeleteDialog(String title, String msg, BuildContext context,
      String buttonMsg, Color color, Function onTap) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.8
          : MediaQuery.of(context).size.width * 0.3
//      ..height = 110
      ..backgroundColor =
          Colors.white //Colors.black.withOpacity(0.8)//main_theme_color
      ..borderRadius = 10.0
      ..barrierColor = const Color(0xDD000000)
      ..showCallBack = () {
        debugPrint("showCallBack invoke");
      }
      ..dismissCallBack = () {
        debugPrint("dismissCallBack invoke");
      }
      ..widget(Container(
        color: Colors.red,
        padding: const EdgeInsets.only(top: 8),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 20, bottom: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      right: 12,
                      bottom: 12,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Padding(
        padding: EdgeInsets.only(
            top: Responsive.isMobile(context) ? 26 : 42, bottom: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 8,
                right: 18,
              ),
              child: Image.asset(
                'assets/images/question_mark.png',
                height: 56,
                width: 56,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 12,
                right: 20,
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration:
                    shadowDecorationWithBorder(Colors.white, Colors.black),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  left: 20,
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 20,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "မလုပ်တော့ပါ",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                onTap.call();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration: shadowDecoration(const Color(0xffFF5F17)),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 30,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "ဖျက်မည်",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  getEventsFromXata() async {
    Map<String, String> headers = {
      "Accept": "application/json",
      "content-type": 'application/json',
      "Authorization": "Bearer xau_n8jyl0ncOhjMYXFMQvgU5re57VDW9vSX2"
    };

    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Records/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200}
        }));
    log(response.statusCode.toString());
    log(response.body.toString());
    if (response.statusCode.toString().startsWith("2")) {
      setState(() {
        data = SpecialEventListResponse.fromJson(jsonDecode(response.body))
            .specialEventData!;
      });
    } else {
      log("Failed");
    }
  }
}
