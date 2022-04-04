import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:merchant/src/features/donar/new_donar.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';

class DonarList extends StatefulWidget {
  static const routeName = "/donar_list";

  @override
  _DonarListState createState() => _DonarListState();
}

class _DonarListState extends State<DonarList> {
  Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('donors').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
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
          child: Text("အလှူရှင်များ",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 60.0,
              ),
            );
          }

          return ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Container(
                height: snapshot.data!.docs.length > 8
                    ? MediaQuery.of(context).size.height *
                        (snapshot.data!.docs.length / 8)
                    : MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 0.93,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Column(
                      children: [
                        header(),
                        Column(
                          // shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return memberRow(data);
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewDonarScreen(),
              ),
            );
            _usersStream =
                FirebaseFirestore.instance.collection('donors').snapshots();
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget header() {
    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width * 0.93,
      margin: const EdgeInsets.only(top: 24, left: 12, right: 20),
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.red[100],
      ),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.4,
                child: Text(
                  "အမည်",
                  style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.4,
                child: Text(
                  "အလှူငွေ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget memberRow(Map<String, dynamic> data) {
    return Container(
      height: 42,
      decoration: shadowDecoration(Colors.white),
      width: MediaQuery.of(context).size.width * 0.93,
      margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
      padding: const EdgeInsets.only(left: 18, right: 20),
      child: Row(
       
        children: [
          Expanded(
           flex: 5,
            child: Text(
              data['name'] ?? "-",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data['amount'] == null ? "-" : Utils.strToMM(data['amount']),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
        ],
      ),
    );
  }
}
