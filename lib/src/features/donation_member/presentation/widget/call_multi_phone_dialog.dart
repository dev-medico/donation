import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallMultiPhoneDialog extends StatelessWidget {
  final String? title;
  final List<String>? phones;
  const CallMultiPhoneDialog(
      {super.key, required this.title, required this.phones});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title.toString(),
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.5
          : MediaQuery.of(context).size.width * 0.23,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.3,
      child: Center(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: phones!.length,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
                margin: const EdgeInsets.only(left: 15, bottom: 16, right: 15),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse("tel:" + phones![index].toString()));
                  },
                  child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: Responsive.isMobile(context) ? 20 : 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/phone.png",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                phones![index].toString(),
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          ))),
                ),
              );
            }),
      ),
    );
  }
}
