import 'dart:convert';
import 'dart:developer';

import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/response/special_event_list_response.dart';
import 'package:merchant/responsive.dart';
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
    const int COLUMN_COUNT = 9;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "Retro Test\n ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ",
      "Hbs Ag\n အသည်းရောင် အသားဝါ(ဘီ)ပိုး",
      "HCV Ab\n အသည်းရောင် အသားဝါ(စီ)ပိုး",
      "VDRL Test\n ကာလသားရောဂါ",
      "M.P ( I.C.T )\n ငှက်ဖျားရောဂါ",
      "Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း",
      "Lab Name\n ဓါတ်ခွဲခန်းအမည်",
      "Total\n စုစုပေါင်း"
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
                        onTap: () {},
                        child: Container(
                            decoration: borderDecorationNoRadius(Colors.grey),
                            margin: const EdgeInsets.all(1),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 14),
                              child: Text(
                                columnIndex == 0
                                    ? Utils.strToMM(
                                        data[rowIndex].retroTest.toString())
                                    : columnIndex == 1
                                        ? Utils.strToMM(
                                            data[rowIndex].hbsAg.toString())
                                        : columnIndex == 2
                                            ? Utils.strToMM(
                                                data[rowIndex].hcvAb.toString())
                                            : columnIndex == 3
                                                ? Utils.strToMM(data[rowIndex]
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
                                                            : columnIndex == 7
                                                                ? data[rowIndex]
                                                                            .total !=
                                                                        null
                                                                    ? Utils.strToMM(data[
                                                                            rowIndex]
                                                                        .total
                                                                        .toString())
                                                                    : "-"
                                                                : "",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 17,
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
