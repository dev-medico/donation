import 'package:donation/src/features/feed/widget/circular_image.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/extensions.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {Key? key,
      this.title,
      this.scaffoldKey,
      this.icon,
      this.onActionPressed,
      this.textController,
      this.isBackButton = false,
      this.isCrossButton = false,
      this.submitButtonText,
      this.isSubmitDisable = true,
      this.isBottomLine = true,
      this.onSearchChanged})
      : super(key: key);

  final Size appBarHeight = const Size.fromHeight(56.0);
  final IconData? icon;
  final bool isBackButton;
  final bool isBottomLine;
  final bool isCrossButton;
  final bool isSubmitDisable;
  final Function? onActionPressed;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? submitButtonText;
  final TextEditingController? textController;
  final Widget? title;
  final ValueChanged<String>? onSearchChanged;

  @override
  Size get preferredSize => appBarHeight;

  Widget _searchField() {
    return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          onChanged: onSearchChanged,
          controller: textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0, style: BorderStyle.none),
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
            hintText: 'Search..',
            fillColor: extraLightGrey,
            filled: true,
            focusColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        ));
  }

  List<Widget> _getActionButtons(BuildContext context) {
    return <Widget>[
      submitButtonText != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                decoration: BoxDecoration(
                  color: !isSubmitDisable
                      ? primaryColor
                      : primaryColor.withAlpha(150),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  submitButtonText!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ).ripple(
                () {
                  if (onActionPressed != null) onActionPressed!();
                },
                borderRadius: BorderRadius.circular(40),
              ),
            )
          : icon == null
              ? Container()
              : IconButton(
                  onPressed: () {
                    if (onActionPressed != null) onActionPressed!();
                  },
                  icon: customIcon(context,
                      icon: icon!,
                      isTwitterIcon: true,
                      iconColor: primaryColor,
                      size: 25),
                )
    ];
  }

  Widget _getUserAvatar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CircularImage(
        height: 30,
      ).ripple(() {
        scaffoldKey!.currentState!.openDrawer();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.blue),
      backgroundColor: Colors.white,
      leading: isBackButton
          ? const BackButton()
          : isCrossButton
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : _getUserAvatar(context),
      title: title ?? _searchField(),
      actions: _getActionButtons(context),
      bottom: PreferredSize(
        child: Container(
          color: isBottomLine
              ? Colors.grey.shade200
              : Theme.of(context).scaffoldBackgroundColor,
          height: 1.0,
        ),
        preferredSize: const Size.fromHeight(0.0),
      ),
    );
  }
}
