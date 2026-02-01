import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:eden_cheat_downloader/controller/global_ctl.dart';
import 'package:eden_cheat_downloader/model/cheat_data.dart';
import 'package:styled_widget/styled_widget.dart';

class Home extends GetView {
  final GlobalCtl ctl = Get.find();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // ctl.searchController.text = "";
    return Scaffold(
      body: [
        [
          TextFormField(
            controller: ctl.searchController,
            onEditingComplete: () {
              ctl.searchName();
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              labelText: "search",

              suffixIcon: IconButton(
                onPressed: () {
                  ctl.searchName();
                  FocusScope.of(context).unfocus();
                },
                icon: Icon(Icons.search),
              ),
            ),
          ),
          Obx(() {
            if (ctl.bLoadName.value) {
              return CircularProgressIndicator().center();
            }

            return ListView.builder(
              itemCount: ctl.cheatdatas.length,
              itemBuilder: (context, index) {
                var target = ctl.cheatdatas[index];

                return ExpansionTile(
                  title: Text(target.name),
                  subtitle: target.cheats.isNotEmpty
                      ? Text(target.cheats.first.titleId)
                      : null,
                  onExpansionChanged: (value) {
                    var bLoaded = false;
                    for (var v in target.cheats) {
                      if (v.cheatList.isNotEmpty) {
                        bLoaded = true;
                        break;
                      }
                    }

                    if (value && !bLoaded) {
                      ctl.getCheats(target);
                    }
                  },
                  children: [
                    if (target.bloadCheat)
                      CircularProgressIndicator().paddingAll(10),
                    if (target.image.isNotEmpty)
                      Image.network(
                        target.banner,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(target.image, height: 150);
                        },
                      ),
                    if (target.cheats.isNotEmpty)
                      for (var v in target.cheats) CompCheats(cheat: v),

                    // target.cheats
                    //     .map(
                    //       (e) => ListTile(
                    //         title: Text(e.build),
                    //         onTap: () {
                    //           ctl.getCheats(target);
                    //         },
                    //       ).card(),
                    //     )
                    //     .toList()
                    //     .toColumn(),
                  ],
                ).card().gestures(
                  onLongPress: () {
                    var cd = ClipboardData(text: target.cheats.first.titleId);
                    Clipboard.setData(cd);
                  },
                );
              },
            );
            // ctl.cheatdatas.map()
          }).expanded(),
        ].toColumn().paddingAll(10),
        Obx(() {
          if (ctl.bLoadOverlay.value) {
            return Container(
              color: Colors.black26,
              child: CircularProgressIndicator().center(),
            );
          }
          return SizedBox();
        }),
      ].toStack(),
    );
  }
}

class CompCheats extends GetView {
  CompCheats({required this.cheat});
  Cheat cheat;
  final GlobalCtl ctl = Get.find();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpansionTile(
      title: Text(cheat.build),
      expandedAlignment: Alignment.topLeft,
      children: cheat.cheatList.map((e) {
        var titles = e.titles.toList();
        titles = titles.sublist(0, 5.clamp(0, titles.length));
        // titles = ["${e.id}", ...titles];
        return ListTile(
          // leading: Text("${e.id}"),
          title: [
            Text("id : ${e.id}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(titles.join("\n")),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
          subtitle: e.titles.length > 5
              ? Text("and : ${e.titles.length - 5}more")
              : null,
          trailing: ElevatedButton(
            onPressed: () {
              ctl.saveData(cheat, e);
            },
            child: Icon(Icons.download),
          ),
        ).card();
      }).toList(),
    ).card();
  }
}
