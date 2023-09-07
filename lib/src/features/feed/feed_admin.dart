import 'package:donation/src/features/feed/feed.dart';
import 'package:donation/src/features/feed/new_post.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/app_icons.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';

class FeedAdminScreen extends StatefulWidget {
  const FeedAdminScreen({super.key});

  @override
  State<FeedAdminScreen> createState() => _FeedAdminScreenState();
}

class _FeedAdminScreenState extends State<FeedAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPostScreen(),
            ),
          );
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(flex: 1, child: FeedScreen(admin: true,)),
            Expanded(flex: 2, child: Container()),
          ],
        ),
      ),
    );
  }
}
