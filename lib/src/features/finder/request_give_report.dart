import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/finder/new_request_give.dart';
import 'package:donation/src/features/finder/request_give_yearly_report.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

class RequestGiveReportScreen extends StatefulWidget {
  const RequestGiveReportScreen({super.key});

  @override
  State<RequestGiveReportScreen> createState() =>
      _RequestGiveReportScreenState();
}

class _RequestGiveReportScreenState extends State<RequestGiveReportScreen> {
  int _yearSelected = 0;
  List<String> years = [
    "2024",
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

  @override
  Widget build(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Center(
            child: Text("သွေးတောင်းခံ/လှူဒါန်းမှု အခြေအနေ",
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewRequestGiveScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: Responsive.isMobile(context) ? 40 : 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 1.8
                        : MediaQuery.of(context).size.width * 0.8,
                    height: 60,
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
            RequestGiveYearlyReport(year: years[_yearSelected])
          ],
        ),
      ),
    );
  }
}
