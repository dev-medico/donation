import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
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
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class PostItem extends StatelessWidget {
  final Post model;
  final bool isDisplayOnProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool admin;
  const PostItem({
    Key? key,
    required this.model,
    this.isDisplayOnProfile = false,
    required this.scaffoldKey,
    this.admin = false,
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
                    admin: admin,
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
              // Padding(
              //   padding: EdgeInsets.only(left: 10),
              //   child: PostIconsRow(
              //     model: model,
              //     iconColor: Theme.of(context).textTheme.bodySmall!.color!,
              //     iconEnableColor: ceriseRed,
              //     size: 20,
              //     scaffoldKey: GlobalKey<ScaffoldState>(),
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              Divider(thickness: 12, color: Colors.grey[200]),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostItemBody extends ConsumerWidget {
  final Post model;
  final bool admin;

  final bool isDisplayOnProfile;
  const _PostItemBody(
      {Key? key,
      required this.model,
      required this.isDisplayOnProfile,
      required this.admin})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    YYDialog.init(context);
    double descriptionFontSize = model.text!.length > 100 ? 13.5 : 15;
    FontWeight descriptionFontWeight = FontWeight.w400;
    TextStyle textStyle = TextStyle(
        color: Colors.black,
        height: model.text!.length > 100 ? 1.3 : 1.35,
        letterSpacing: model.text!.length > 100 ? 0.2 : 0.5,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 0.7
                        : MediaQuery.of(context).size.width * 0.25 - 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: 0,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * .5),
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
                ],
              ),
              if (admin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      messageDialog("Are you sure to delete this post?",
                          context, "Yes", Colors.red, ref);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 12,
                        bottom: 12,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          model.text == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadMoreText(
                        model.text!.toString().removeSpaces,
                        trimLines: 6,
                        colorClickableText: Colors.blue,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'See more',
                        trimExpandedText: '  See less',
                        style: textStyle,
                        lessStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                        moreStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                      // UrlText(
                      //   text: model.text!.toString().removeSpaces,
                      //   onHashTagPressed: (tag) {},
                      //   style: textStyle,
                      //   urlStyle: urlStyle,
                      // ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  messageDialog(String msg, BuildContext context, String buttonMsg, Color color,
      WidgetRef ref) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          SvgPicture.asset(
            "assets/images/warn.svg",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              ref.watch(realmProvider)!.deletePost(model);
              Navigator.of(context, rootNavigator: true).pop('dialog');
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }
}
