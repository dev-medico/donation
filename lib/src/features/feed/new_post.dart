import 'dart:ffi';
import 'dart:io';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/feed/widget/circular_image.dart';
import 'package:donation/src/features/feed/widget/composeBottomIconWidget.dart';
import 'package:donation/src/features/feed/widget/composeTweetImage.dart';
import 'package:donation/src/features/feed/widget/customAppBar.dart';
import 'package:donation/src/features/feed/widget/customUrlText.dart';
import 'package:donation/src/features/feed/widgetView.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';

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

  List<File> images = [];
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

  void _onCrossIconPressed() {
    images = [];
  }

  void _onImageIconSelected(List<File> files) {
    images.addAll(files);
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }

    await createTweetModel();
    String? tweetId;

    /// If tweet contain image
    /// First image is uploaded on firebase storage
    /// After successful image upload to firebase storage it returns image path
    /// Add this image path to tweet model and save to firebase database
    if (images.isNotEmpty) {
      //imagePath
    }

    /// If tweet did not contain image
    else {}
    Navigator.pop(context);
  }

  createTweetModel() async {
    var profilePic = dummyProfilePic;

    _textEditingController.text;
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
            child: Stack(
              children: <Widget>[
                ComposeTweetImages(
                  images: images,
                  onCrossIconPressed: _onCrossIconPressed,
                ),
                // _UserList(
                //   list: Provider.of<SearchState>(context).userlist,
                //   textEditingController: viewState._textEditingController,
                // )
              ],
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
