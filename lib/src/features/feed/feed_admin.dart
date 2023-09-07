import 'package:donation/responsive.dart';
import 'package:donation/src/features/feed/feed.dart';
import 'package:donation/src/features/feed/new_post.dart';
import 'package:donation/src/features/feed/widget/feed_or_noti_dialog.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/app_icons.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedAdminScreen extends ConsumerStatefulWidget {
  const FeedAdminScreen({super.key, this.fromHome = false});
  final bool fromHome;

  @override
  ConsumerState<FeedAdminScreen> createState() => _FeedAdminScreenState();
}

class _FeedAdminScreenState extends ConsumerState<FeedAdminScreen> {
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
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text("ပို့စ်/အသိပေးချက်များ",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          showDialog(
              context: context, builder: (context) => FeedOrNotiDialog());
        },
        child: customIcon(
          context,
          icon: AppIcon.fabTweet,
          isTwitterIcon: true,
          iconColor: Colors.white,
          size: 25,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 4 : 20),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: FeedScreen(
                  admin: true,
                )),
            Responsive.isMobile(context)
                ? Container()
                : Expanded(flex: 2, child: Container()),
          ],
        ),
      ),
    );
  }
}
