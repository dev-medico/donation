import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/common_widgets/customLoader.dart';
import 'package:donation/src/features/feed/widget/circular_image.dart';
import 'package:donation/src/features/feed/widget/composeBottomIconWidget.dart';
import 'package:donation/src/features/feed/widget/customAppBar.dart';
import 'package:donation/src/features/feed/widget/customUrlText.dart';
import 'package:donation/src/features/feed/widget/newfeed_multiple_imageview.dart';
import 'package:donation/src/features/feed/widgetView.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

final scrollingDownController = StateProvider((ref) => false);
final isBusyController = StateProvider((ref) => false);
final searchStateController = StateProvider((ref) => false);
final descriptionController = StateProvider((ref) => '');

class NewPostScreen extends ConsumerStatefulWidget {
  const NewPostScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends ConsumerState<NewPostScreen> {
  bool isScrollingDown = false;
  late Post? model;
  late ScrollController scrollController;
  late CustomLoader loader;

  List<String> images = [];
  late TextEditingController _textEditingController;

  @override
  void dispose() {
    scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController = ScrollController();
    _textEditingController = TextEditingController();
    scrollController.addListener(_scrollListener);
    loader = CustomLoader();
    super.initState();
  }

  _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        ref.watch(scrollingDownController.notifier).state = true;
      }
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      ref.watch(scrollingDownController.notifier).state = false;
    }
  }

  void onCrossIconPressed(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void _onImageIconSelected(List<File> files) {
    log("Result " + files.length.toString());
    setState(() {
      images.addAll(files.map((e) => e.path).toList());
    });
  }

  void _submitButton() async {
    if (_textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }

    await createTweetModel();

    Navigator.pop(context);
  }

  createTweetModel() async {
    loader.showLoader(context);
    List<String> imageUrls = [];
    if (images.isNotEmpty) {
      imageUrls = await Utils.uploadToFireStorage(
          images.map((e) => File(e)).toList(), ref);
    }
    var newPost = Post(
      ObjectId(),
      text: _textEditingController.text,
      images: imageUrls,
      createdAt: DateTime.now(),
      postedBy: "Red Juniors",
      posterProfileUrl: dummyProfilePic,
    );

    ref.watch(realmProvider)!.createPost(newPost);
    loader.hideLoader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: 'Post',
        isSubmitDisable: !_textEditingController.text.isNotEmpty ||
            ref.watch(isBusyController),
        isBottomLine: ref.watch(scrollingDownController),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: scrollController,
            child: ComposeTweet(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ComposeBottomIconWidget(
              textEditingController: _textEditingController,
              onImageIconSelected: _onImageIconSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget ComposeTweet() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: CircularImage(path: dummyProfilePic, height: 40),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: true,
                  textEditingController: _textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Container(
                margin: EdgeInsets.only(top: 12),
                child: images.isEmpty
                    ? Container()
                    : NewsfeedMultipleImageView(
                        imageUrls: images,
                        type: 'post',
                        onImageDeleted: onCrossIconPressed,
                      )
                // : ListView.builder(
                //     itemCount: images.length,
                //     itemBuilder: (context, index) {
                //       return Stack(
                //         children: <Widget>[
                //           InteractiveViewer(
                //             child: Container(
                //               alignment: Alignment.topRight,
                //               child: Container(
                //                 height: 220,
                //                 width: MediaQuery.of(context).size.width * .8,
                //                 decoration: BoxDecoration(
                //                   borderRadius: const BorderRadius.all(
                //                       Radius.circular(10)),
                //                   image: DecorationImage(
                //                       image: FileImage(images[index]),
                //                       fit: BoxFit.cover),
                //                 ),
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.topRight,
                //             child: Container(
                //               padding: const EdgeInsets.all(0),
                //               decoration: const BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   color: Colors.black54),
                //               child: IconButton(
                //                 padding: const EdgeInsets.all(0),
                //                 iconSize: 20,
                //                 onPressed: () {
                //                   onCrossIconPressed(index);
                //                 },
                //                 icon: Icon(
                //                   Icons.close,
                //                   color:
                //                       Theme.of(context).colorScheme.onPrimary,
                //                 ),
                //               ),
                //             ),
                //           )
                //         ],
                //       );
                //     },
                //   ),
                ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends ConsumerWidget {
  const _TextField(
      {Key? key, required this.textEditingController, this.isTweet = false})
      : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5, height: 1.5),
          controller: textEditingController,
          onChanged: (text) {},
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet ? 'What\'s happening?' : 'Tweet your reply',
              hintStyle: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
