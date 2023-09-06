import 'package:donation/realm/schemas.dart';
import 'package:donation/src/common_widgets/title_text.dart';
import 'package:donation/src/features/feed/widget/circular_image.dart';
import 'package:donation/src/features/feed/widget/customText.dart';
import 'package:donation/src/features/feed/widget/customUrlText.dart';
import 'package:donation/src/features/feed/widget/newfeed_multiple_imageview.dart';
import 'package:donation/src/features/feed/widget/postIconsRow.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/extensions.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostItem extends StatelessWidget {
  final Post model;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const PostItem({
    Key? key,
    required this.model,
    this.isDisplayOnProfile = false,
    required this.scaffoldKey,
  }) : super(key: key);

  void onLongPressedPostItem(BuildContext context) {
    Utils.copyToClipBoard(
        context: context,
        text: model.text ?? "",
        message: "PostItem copy to clipboard");
  }

  void onTapPostItem(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        /// Left vertical bar of a postItem
        const SizedBox.shrink(),

        InkWell(
          onLongPress: () {
            onLongPressedPostItem(context);
          },
          onTap: () {
            onTapPostItem(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(
                    top: 12,
                  ),
                  child: _PostItemBody(
                    isDisplayOnProfile: isDisplayOnProfile,
                    model: model,
                  )),
              model.images.isNotEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.only(right: 16, top: 16, left: 12),
                      child: NewsfeedMultipleImageView(
                        imageUrls: model.images.toList(),
                        type: 'view',
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: PostIconsRow(
                  model: model,
                  iconColor: Theme.of(context).textTheme.bodySmall!.color!,
                  iconEnableColor: ceriseRed,
                  size: 20,
                  scaffoldKey: GlobalKey<ScaffoldState>(),
                ),
              ),
              Divider(thickness: 12, color: Colors.grey[200]),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostItemBody extends StatelessWidget {
  final Post model;

  final bool isDisplayOnProfile;
  const _PostItemBody(
      {Key? key, required this.model, required this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = 15;
    FontWeight descriptionFontWeight = FontWeight.w400;
    TextStyle textStyle = TextStyle(
        color: Colors.black,
        height: 1.35,
        letterSpacing: 0.5,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    TextStyle urlStyle = TextStyle(
        color: Colors.blue,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    if (isDisplayOnProfile) {
                      return;
                    }
                  },
                  child: CircularImage(path: dummyProfilePic),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width - 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: MediaQuery.of(context).size.width * .5),
                          child: TitleText(model.postedBy.toString(),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 2),
                        customText(
                          Utils.getChatTime(model.createdAt!),
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
              const SizedBox(width: 10),
            ],
          ),
          model.text == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UrlText(
                        text: model.text!.toString().removeSpaces,
                        onHashTagPressed: (tag) {},
                        style: textStyle,
                        urlStyle: urlStyle,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
