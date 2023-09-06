import 'dart:io';
import 'package:flutter/material.dart';

class ComposeTweetImages extends StatelessWidget {
  final List<File>? images;
  final VoidCallback onCrossIconPressed;
  const ComposeTweetImages(
      {Key? key, this.images, required this.onCrossIconPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 12),
        child: images == null
            ? Container()
            : GridView.count(
                crossAxisCount: 2,
                children: [
                  ...images!.map(
                    (image) => Stack(
                      children: <Widget>[
                        InteractiveViewer(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 220,
                              width: MediaQuery.of(context).size.width * .8,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    image: FileImage(image), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black54),
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              iconSize: 20,
                              onPressed: onCrossIconPressed,
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ));
  }
}
