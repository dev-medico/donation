import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/feed/new_feed.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  final Member? data;
  final bool? isEditable;
  FeedScreen({Key? key, required this.data, this.isEditable = true})
      : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewFeedScreen(),
              ),
            );
          }),
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
          ),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 60),
                child: TabBarView(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(" No Post Yet",
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.red)),
                      ),
                    ),
                    MemberDetailScreen(
                      data: widget.data!,
                      isEditable: widget.isEditable!,
                    ),
                  ],
                ),
              ),
              Container(
                  height: 54,
                  child: Column(
                    children: [
                      Container(
                        height: 52,
                        child: getTabbar(),
                      ),
                      PreferredSize(
                        child: Container(
                          color: Colors.grey.shade200,
                          height: 1.0,
                        ),
                        preferredSize: const Size.fromHeight(0.0),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  getTabbar() {
    return TabBar(
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.black,
      indicatorWeight: 4,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(
          height: 50,
          child: Text(" For you ",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        Tab(
          height: 50,
          child: Text(" အဖွဲ့ဝင်မှတ်တမ်း ",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
