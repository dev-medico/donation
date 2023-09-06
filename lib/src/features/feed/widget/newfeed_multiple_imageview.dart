import 'package:donation/src/features/feed/widget/multiple_image_view.dart';
import 'package:donation/src/features/feed/widget/smart_image.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class NewsfeedMultipleImageView extends StatelessWidget {
  final List<String> imageUrls;
  final String type;
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final Function(int index)? onImageDeleted;

  const NewsfeedMultipleImageView({
    Key? key,
    this.marginLeft = 0,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    required this.type,
    required this.imageUrls,
    this.onImageDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, costraints) => Container(
        width: costraints.maxWidth,
        height: costraints.maxWidth,
        margin: EdgeInsets.fromLTRB(
          marginLeft,
          marginTop,
          marginRight,
          marginBottom,
        ),
        child: GestureDetector(
          child: MultipleImageView(imageUrls: imageUrls),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(
                  imageUrls: imageUrls,
                  type: type,
                  onImageDeleted: onImageDeleted),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final String type;
  final Function(int index)? onImageDeleted;
  const ImageViewer({
    Key? key,
    required this.imageUrls,
    required this.type,
    this.onImageDeleted,
  }) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int _currentIndex = 0;
  List<String> urls = [];
  @override
  void initState() {
    super.initState();
    urls = widget.imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.type == "post"
            ? AppBar(
                backgroundColor: primaryColor,
                title: Text("Edit"),
                leading: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Container(
            // width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.type == "post") {
                        widget.onImageDeleted?.call(_currentIndex);
                        setState(() {});
                        if (urls.length == 0) Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: ImageSlideshow(
                      initialPage: 0,
                      indicatorColor: Colors.red,
                      indicatorBackgroundColor: Colors.grey,
                      isLoop: urls.length > 1,
                      onPageChanged: (value) {
                        print('Page changed: $value');
                        setState(() {
                          _currentIndex = value;
                        });
                      },
                      children: urls
                          .map(
                            (e) => ClipRect(
                              child: SmartImage(
                                e,
                                fit: BoxFit.contain,
                                isPost: widget.type == 'post',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
