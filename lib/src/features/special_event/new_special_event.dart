import 'dart:convert';
import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';

class NewEventAddScreen extends StatefulWidget {
  const NewEventAddScreen({Key? key}) : super(key: key);

  @override
  State<NewEventAddScreen> createState() => _NewEventAddScreenState();
}

class _NewEventAddScreenState extends State<NewEventAddScreen> {
  bool isLoading = false;
  String dateFilter = "-";
  TextEditingController retorTestController = TextEditingController();
  TextEditingController hbsAgController = TextEditingController();
  TextEditingController hcvAbController = TextEditingController();
  TextEditingController vdrlController = TextEditingController();
  TextEditingController mpICTController = TextEditingController();
  TextEditingController haemoglobinController = TextEditingController();
  TextEditingController labNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    String formattedDate = DateFormat('dd MMM yyyy').format(now);
    dateFilter = formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
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
          child: Center(
            child: Text("ထူးခြားဖြစ်စဥ်အသစ် ထည့်သွင်းမည်",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 17,
                    color: Colors.white)),
          ),
        ),
      ),
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Responsive.isMobile(context)
              ? ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(
                          left: 20, top: 16, bottom: 4, right: 20),
                      child: NeumorphicButton(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateFilter,
                            style: TextStyle(fontSize: 14, color: primaryColor),
                          ),
                        ),
                        onPressed: () {
                          showDatePicker();
                        },
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: retorTestController,
                        decoration: inputBoxDecoration(
                            "Retro Test (ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: hbsAgController,
                        decoration: inputBoxDecoration(
                            "Hbs Ag (အသည်းရောင် အသားဝါ(ဘီ)ပိုး)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: hcvAbController,
                        decoration: inputBoxDecoration(
                            "HCV Ab (အသည်းရောင် အသားဝါ(စီ)ပိုး)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: vdrlController,
                        decoration:
                            inputBoxDecoration("VDRL Test (ကာလသားရောဂါ)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: mpICTController,
                        decoration:
                            inputBoxDecoration("M.P (I.C.T) (ငှက်ဖျားရောဂါ)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: haemoglobinController,
                        decoration: inputBoxDecoration(
                            "Haemoglobin ( Hb% ) (သွေးအားရာခိုင်နှုန်း)"),
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 16, right: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: labNameController,
                        decoration:
                            inputBoxDecoration("Lab Name (ဓါတ်ခွဲခန်းအမည်)"),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      width: MediaQuery.of(context).size.width / 2.8,
                      margin: const EdgeInsets.only(
                          left: 20, bottom: 16, right: 20, top: 20),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          uploadNewEventToXata();
                        },
                        child: const Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                child: Text(
                                  "ထည့်သွင်းမည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ))),
                      ),
                    )
                  ],
                )
              : Stack(
                  children: [
                    ListView(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.7),
                          height: 50,
                          margin: const EdgeInsets.only(
                              left: 20, top: 16, bottom: 4, right: 20),
                          child: NeumorphicButton(
                            child: Text(
                              dateFilter,
                              style:
                                  TextStyle(fontSize: 14, color: primaryColor),
                            ),
                            onPressed: () {
                              showDatePicker();
                            },
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: retorTestController,
                                    decoration: inputBoxDecoration(
                                        "Retro Test (ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ)"),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: hbsAgController,
                                    decoration: inputBoxDecoration(
                                        "Hbs Ag (အသည်းရောင် အသားဝါ(ဘီ)ပိုး)"),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: hcvAbController,
                                    decoration: inputBoxDecoration(
                                        "HCV Ab (အသည်းရောင် အသားဝါ(စီ)ပိုး)"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 70,
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: vdrlController,
                                    decoration: inputBoxDecoration(
                                        "VDRL Test (ကာလသားရောဂါ)"),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: mpICTController,
                                    decoration: inputBoxDecoration(
                                        "M.P (I.C.T) (ငှက်ဖျားရောဂါ)"),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: haemoglobinController,
                                    decoration: inputBoxDecoration(
                                        "Haemoglobin ( Hb% )"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0))),
                        width: MediaQuery.of(context).size.width * 0.25,
                        margin: EdgeInsets.only(
                            bottom: 16,
                            right: MediaQuery.of(context).size.width * 0.1),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            uploadNewEventToXata();
                          },
                          child: const Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Text(
                                    "ထည့်သွင်းမည်",
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ))),
                        ),
                      ),
                    )
                  ],
                )),
    );
  }

  showDatePicker() async {
    DateTime? newDateTime = await showRoundedDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 150),
        lastDate: DateTime(DateTime.now().year + 1),
        theme: ThemeData(primarySwatch: Colors.red),
        styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleDayButton:
              const TextStyle(fontSize: 20, color: Colors.white),
          textStyleYearButton: const TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
          textStyleDayHeader: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textStyleCurrentDayOnCalendar: const TextStyle(
              fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleDayOnCalendar:
              const TextStyle(fontSize: 16, color: Colors.white),
          textStyleDayOnCalendarSelected: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleDayOnCalendarDisabled:
              TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.1)),
          textStyleMonthYearHeader: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          paddingMonthHeader: const EdgeInsets.all(16),
          paddingDateYearHeader: const EdgeInsets.all(20),
          sizeArrow: 28,
          colorArrowNext: Colors.white,
          colorArrowPrevious: Colors.white,
          marginLeftArrowPrevious: 4,
          marginTopArrowPrevious: 4,
          marginTopArrowNext: 4,
          marginRightArrowNext: 4,
          textStyleButtonAction:
              const TextStyle(fontSize: 28, color: Colors.white),
          textStyleButtonPositive: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleButtonNegative:
              TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
          decorationDateSelected:
              BoxDecoration(color: Colors.orange[600], shape: BoxShape.circle),
          backgroundPicker: Colors.red[400],
          backgroundActionBar: Colors.red[300],
          backgroundHeaderMonth: Colors.red[300],
        ),
        styleYearPicker: MaterialRoundedYearPickerStyle(
          textStyleYear: const TextStyle(fontSize: 20, color: Colors.white),
          textStyleYearSelected: const TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          heightYearRow: 60,
          backgroundPicker: Colors.red[400],
        ));
    setState(() {
      String formattedDate = DateFormat('dd MMM yyyy').format(newDateTime!);
      dateFilter = formattedDate;
    });
  }

  uploadNewEventToXata() async {
    setState(() {
      isLoading = true;
    });

    int total = (retorTestController.text.toString().isEmpty
            ? 0
            : int.parse(retorTestController.text.toString())) +
        (hbsAgController.text.toString().isEmpty
            ? 0
            : int.parse(hbsAgController.text.toString())) +
        (hcvAbController.text.toString().isEmpty
            ? 0
            : int.parse(hcvAbController.text.toString())) +
        (vdrlController.text.toString().isEmpty
            ? 0
            : int.parse(vdrlController.text.toString())) +
        (mpICTController.text.toString().isEmpty
            ? 0
            : int.parse(mpICTController.text.toString())) +
        (haemoglobinController.text.toString().isEmpty
            ? 0
            : int.parse(retorTestController.text.toString()));

    XataRepository()
        .uploadNewEvent(
      jsonEncode(
        <String, dynamic>{
          "date": dateFilter.toString(),
          "retro_test": retorTestController.text.toString().isEmpty
              ? 0
              : int.parse(retorTestController.text.toString()),
          "hbs_ag": hbsAgController.text.toString().isEmpty
              ? 0
              : int.parse(hbsAgController.text.toString()),
          "hcv_ab": hcvAbController.text.toString().isEmpty
              ? 0
              : int.parse(hcvAbController.text.toString()),
          "vdrl_test": vdrlController.text.toString().isEmpty
              ? 0
              : int.parse(vdrlController.text.toString()),
          "mp_ict": mpICTController.text.toString().isEmpty
              ? 0
              : int.parse(mpICTController.text.toString()),
          "haemoglobin": haemoglobinController.text.toString().isEmpty
              ? 0
              : int.parse(retorTestController.text.toString()),
          "lab_name": labNameController.text.isEmpty
              ? ""
              : labNameController.text.toString(),
          "total": total
        },
      ),
    )
        .then((response) {
      log(response.statusCode.toString());
      setState(() {
        isLoading = false;
      });
      if (response.statusCode != 201) {
        log("Failed");
      } else {
        Navigator.pop(context);
      }
    });
  }
}
