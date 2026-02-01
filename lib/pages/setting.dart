import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eden_cheat_downloader/controller/global_ctl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Setting extends GetView {
  final GlobalCtl ctl = Get.find();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: [
        ElevatedButton(
          onPressed: () {
            launchUrlString(
              "https://www.cheatslips.com/profile/api",
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text("open cheat slips profile"),
        ).alignment(Alignment.center),
        SizedBox(height: 20),
        Obx(() {
          return TextFormField(
            initialValue: ctl.token.value,
            onChanged: (value) => ctl.setToken(value),
            decoration: InputDecoration(labelText: "token"),
          );
        }),
        SizedBox(height: 20),

        // Divider().marginSymmetric(vertical: 20),
        Text("save path :"),
        Obx(() {
          return Text(ctl.savePath.value).paddingAll(10);
        }).constrained(width: double.infinity, minHeight: 80).card(),
        ElevatedButton(
          onPressed: () {
            ctl.setSavePath();
          },
          child: Icon(Icons.folder_open),
        ).alignment(AlignmentGeometry.topRight),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).paddingAll(10),
    );
  }
}
