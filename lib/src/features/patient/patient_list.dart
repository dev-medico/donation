import 'dart:async';

import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donation/controller/donation_list_controller.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/src/features/patient/patient_data_source.dart';
import 'package:donation/src/features/patient/patient_list_by_year.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientList extends ConsumerStatefulWidget {
  static const routeName = "/patient_list";
  final bool fromHome;
  const PatientList({Key? key, this.fromHome = false}) : super(key: key);

  @override
  ConsumerState<PatientList> createState() => _PatientListState();
}

class _PatientListState extends ConsumerState<PatientList> {
  //List<SpecialEventData>? data = [];
  bool notloaded = true;
  Timer? _debounceTimer;
  String searchKey = "";
  int _yearSelected = 0;
  int _monthSelected = DateTime.now().month - 1;
  List<String> years = [
    "2023",
    "2022",
    "2021",
    "2020",
    "2019",
    "2018",
    "2017",
    "2016",
    "2015",
    "2014",
    "2013",
    "2012",
  ];
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];

  List<String> monthsMobile = [
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var donationData = ref.watch(donationListProvider(DonationFilterModel(
        year: int.parse(years[_yearSelected]), month: _monthSelected + 1)));
    YYDialog.init(context);
    if (notloaded) {
      //
      notloaded = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        leading: widget.fromHome && Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Humberger(
                  onTap: () {
                    ref.watch(drawerControllerProvider)!.toggle!.call();
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("လူနာများ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: Responsive.isMobile(context)
                          ? MediaQuery.of(context).size.width * 1.8
                          : MediaQuery.of(context).size.width * 0.8,
                      height: Responsive.isMobile(context) ? 40 : 60,
                      child: CommonTabBar(
                        underline: false,
                        listWidget: [
                          for (int i = 0; i < years.length; i++)
                            CommonTabBarWidget(
                              underline: false,
                              name: years[i],
                              isSelected: _yearSelected,
                              i: i,
                              onTap: () {
                                _yearSelected = i;

                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width * 1.8
                    : MediaQuery.of(context).size.width * 0.8,
                height: Responsive.isMobile(context) ? 40 : 60,
                child: CommonTabBar(
                  underline: false,
                  listWidget: [
                    for (int i = 0; i < months.length; i++)
                      CommonTabBarWidget(
                        color: primaryColor,
                        underline: false,
                        name: Responsive.isMobile(context)
                            ? monthsMobile[i]
                            : months[i],
                        isSelected: _monthSelected,
                        i: i,
                        onTap: () {
                          _monthSelected = i;

                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width / 5,
                    margin: const EdgeInsets.only(right: 20, bottom: 12),
                    padding: const EdgeInsets.only(
                      top: 12,
                    ),
                    child: TextFormField(
                      autofocus: false,
                      controller: searchController,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      onChanged: (val) {
                        if (_debounceTimer?.isActive ?? false) {
                          _debounceTimer?.cancel();
                        }

                        _debounceTimer =
                            Timer(const Duration(milliseconds: 700), () {
                          setState(() {
                            searchKey = val;
                          });
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                        hintStyle: const TextStyle(
                            color: Colors.black, fontSize: 15.0),
                        fillColor: Colors.white.withOpacity(0.2),
                        filled: true,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.search,
                            color: primaryColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 20, right: 20, top: 4, bottom: 4),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey)),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        var year = int.parse(years[_yearSelected]);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return PatientListByYear(
                              year: year,
                            );
                          },
                        ));
                      },
                      child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 12,
                              ),
                              Icon(Icons.list_alt_outlined,
                                  color: Colors.white),
                              Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    "နှစ်အလိုက် ကြည့်မည်",
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  )),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              donationData.when(
                  data: (donations) {
                    var results =
                        ref.watch(patientByDonationsProvider(donations));
                    return Expanded(
                      child: buildSimpleTable(searchKey == ""
                          ? results
                          : results
                              .where((element) =>
                                  element.patientName!.contains(searchKey))
                              .toList()),
                    );
                  },
                  loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                  error: (error, stack) => Center(
                        child: Text(error.toString()),
                      )),
            ],
          )),
    );
  }

  buildSimpleTable(List<Patient> data) {
    PatientDataSource patientDataSource = PatientDataSource(patient: data);

    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: patientDataSource,
        onCellTap: (details) async {},
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: Responsive.isMobile(context)
            ? ColumnWidthMode.fitByCellValue
            : ColumnWidthMode.fitByCellValue,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'စဥ်',
              label: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'စဥ်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အမည်',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'အကြိမ်ရေ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အကြိမ်ရေ',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'လှူဒါန်းသည့်နေရာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လှူဒါန်းသည့်နေရာ',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ဖြစ်ပွားသည့်ရောဂါ',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'အသက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အသက်',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'နေရပ်လိပ်စာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'နေရပ်လိပ်စာ',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
        ],
      ),
    );
  }
}
