import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/customLoader.dart';
import 'package:donation/src/common_widgets/title_text.dart';
import 'package:donation/src/features/feed/widget/circular_image.dart';
import 'package:donation/src/features/feed/widget/composeBottomIconWidget.dart';
import 'package:donation/src/features/feed/widget/customAppBar.dart';
import 'package:donation/src/features/feed/widget/customText.dart';
import 'package:donation/src/features/feed/widget/customUrlText.dart';
import 'package:donation/src/features/feed/widget/newfeed_multiple_imageview.dart';
import 'package:donation/src/features/feed/widgetView.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> _onImageIconSelected(List<File> files) async {
    final Directory tempDir = await getApplicationDocumentsDirectory();
    log("Result " + files.length.toString());
    for (var i = 0; i < files.length; i++) {
      log("Result " + files[i].path);

      if (Platform.isAndroid || Platform.isIOS) {
        var result = await compressFile(
            files[i], tempDir.path + files[i].path.split("/").last);
        setState(() {
          images.add(result.path);
        });
      } else {
        setState(() {
          images.add(files[i].path);
        });
      }
    }
    // setState(() {
    //   images.addAll(files.map((e) => e.path).toList());
    // });
  }

  void _submitButton() async {
    if (_textEditingController.text.isEmpty) {
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
      postedBy: "RED Juniors",
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
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
      child: ListView(
        padding: EdgeInsets.only(
            top: _textEditingController.text.length > 100 ? 80 : 0, bottom: 60),
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox.shrink(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CircularImage(path: dummyProfilePic, height: 46),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.7
                    : MediaQuery.of(context).size.width * 0.25 - 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 4,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: MediaQuery.of(context).size.width * .5),
                          child: TitleText("RED Juniors",
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 2),
                        customText(
                          "Admin",
                          style: TextStyle(
                              color: darkGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          _TextField(
            isTweet: true,
            textEditingController: _textEditingController,
          ),
          Container(
              margin: EdgeInsets.only(
                  top: 12,
                  right: Responsive.isMobile(context)
                      ? 0
                      : MediaQuery.of(context).size.width * 0.6),
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
          style: TextStyle(
              fontSize: textEditingController.text.length > 100 ? 13.5 : 15,
              letterSpacing:
                  textEditingController.text.length > 100 ? 0.3 : 0.5,
              height: textEditingController.text.length > 100 ? 1.4 : 1.5),
          controller: textEditingController,
          onChanged: (text) {},
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet ? 'What\'s in your mind?' : 'Tweet your reply',
              hintStyle: TextStyle(
                  fontSize: textEditingController.text.length > 100 ? 14 : 16)),
        ),
      ],
    );
  }
}
