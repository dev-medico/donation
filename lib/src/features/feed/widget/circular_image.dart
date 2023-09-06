import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  const CircularImage(
      {Key? key, this.path, this.height = 50, this.isBorder = false})
      : super(key: key);
  final String? path;
  final double height;
  final bool isBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.grey.shade100, width: isBorder ? 2 : 0),
      ),
      child: CircleAvatar(
        maxRadius: height / 2,
        backgroundColor: Theme.of(context).cardColor,
        backgroundImage: customAdvanceNetworkImage(path ?? dummyProfilePic),
      ),
    );
  }
}

CachedNetworkImageProvider customAdvanceNetworkImage(String? path) {
  if (path ==
      'http://www.azembelani.co.za/wp-content/uploads/2016/07/20161014_58006bf6e7079-3.png') {
    path = dummyProfilePic;
  } else {
    path ??= dummyProfilePic;
  }
  return CachedNetworkImageProvider(
    path,
    cacheKey: path,
  );
}

String dummyProfilePic =
    "https://firebasestorage.googleapis.com/v0/b/redjuniors-be113.appspot.com/o/images%2Fic_launcher.png?alt=media&token=a9e3cc0b-4963-4929-9047-c5b1f0fe2dce";
