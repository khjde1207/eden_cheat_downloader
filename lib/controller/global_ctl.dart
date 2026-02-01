import 'dart:convert';
import 'dart:developer' as d;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eden_cheat_downloader/model/cheat_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'package:dio/dio.dart';

class GlobalCtl extends GetxController {
  var currentIndex = 0.obs;
  var sdCardPath = "".obs;

  RxString token = "".obs;

  late Database db;
  late StoreRef store;

  TextEditingController searchController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  Dio dio = Dio(BaseOptions(baseUrl: "https://www.cheatslips.com/api/v1"));

  RxBool bLoadName = false.obs;

  RxBool bLoadOverlay = false.obs;

  RxList<CheatData> cheatdatas = RxList<CheatData>();

  RxString savePath = "".obs;

  @override
  void onInit() async {
    super.onInit();
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);

    final dbPath = join(dir.path, 'my_database.db');
    db = await databaseFactoryIo.openDatabase(dbPath);

    store = StoreRef.main();
    getToken();
    getSavePath();
  }

  void setToken(String str) async {
    token(str);
    await store.record("token").put(db, str);
  }

  void getToken() async {
    var v = await store.record("token").get(db);
    if (v is String) {
      token(v);
    }
  }

  void setSavePath() async {
    var path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      savePath(path);
      await store.record("savepath").put(db, path);
    }
  }

  void getSavePath() async {
    var v = await store.record("savepath").get(db);
    if (v is String) {
      savePath(v);
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> selectSdCardPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      sdCardPath.value = selectedDirectory;
    }
  }

  void searchName() async {
    bLoadName(true);
    // try {
    var req = await dio.get(
      "/cheats/find/${searchController.text}",
      options: Options(
        headers: {'accept': 'application/json', 'X-API-TOKEN': token.value},
      ),
    );
    if (req.statusCode == 200) {
      if (req.data['games'] is List) {
        cheatdatas.clear();
        for (var v in req.data['games']) {
          cheatdatas.add(CheatData.fromJson(v));
        }
      }
    }
    bLoadName(false);
  }

  void getCheats(CheatData cheat) async {
    if (cheat.cheats.isEmpty) {
      return;
    }
    cheat.bloadCheat = true;
    cheatdatas.refresh();

    var req = await dio.get(
      "/cheats/${cheat.cheats.first.titleId}",
      // /${cheat.build}",
      options: Options(
        headers: {'accept': 'application/json', 'X-API-TOKEN': token.value},
      ),
    );

    if (req.statusCode == 200) {
      for (var v in cheat.cheats) {
        v.cheatList.clear();
      }
      //

      var data = req.data;
      cheat.image = data['image'];
      cheat.banner = data['banner'];

      var list = data['cheats'];
      if (list is List) {
        for (var v in list) {
          var code = CheatCode.fromJson(v);

          var target = cheat.cheats.firstWhereOrNull(
            (e) => e.build == code.buildid,
          );
          if (target != null) {
            target.cheatList.add(code);
          }
        }
      }

      // data.
    }
    cheatdatas.refresh();
    // print(req.data);

    cheatdatas.refresh();
    cheat.bloadCheat = false;

    // var str = json.encode(req.data);
    // d.log(str);
    // var cd = ClipboardData(text: str);
    // Clipboard.setData(cd);
  }

  void saveData(Cheat cheat, CheatCode code) async {
    // titleId;
    bLoadOverlay(true);
    await Future.delayed(Duration(milliseconds: 100));
    var path = savePath.value;
    var folderName = cheat.name.replaceAll(RegExp(r'[\\.\\/:*?"<>|]'), "_");
    var rootFolderPath = "${savePath.value}/$folderName";

    var saveGameDir = Directory(rootFolderPath)..createSync(recursive: true);

    var buildFolder = Directory(
      "${saveGameDir.path}/${code.buildid}_${code.id}",
    )..createSync(recursive: true);

    // print(saveGameDir);
    // print("${saveGameDir.path}/${code.buildid}_${code.id}");

    // print(buildFolder);
    var text = code.content.replaceAll("\r\n", "\n");
    var sections = text.split("[");

    await Future.forEach(sections, (section) async {
      if (section.trim().isEmpty) return;

      var parts = section.split("]");
      if (parts.length >= 2) {
        var title = parts[0].trim();
        var folderName = title.replaceAll(RegExp(r'[\\.\\/:*?"<>|]'), "_");
        var code = parts.sublist(1).join("]").trim();
        var saveData = "[$title]\n$code";

        await Directory(
          "${buildFolder.path}/${folderName}",
        ).create(recursive: true);

        await Directory(
          "${buildFolder.path}/${folderName}/cheats",
        ).create(recursive: true);

        await File(
          "${buildFolder.path}/${folderName}/cheats/${cheat.titleId}.txt",
        ).writeAsString(saveData);
      }
    });
    // for (var section in sections) {
    //   if (section.trim().isEmpty) continue;
    //   var parts = section.split("]");
    //   if (parts.length >= 2) {
    //     var title = parts[0].trim();
    //     var folderName = title.replaceAll(RegExp(r'[\\.\\/:*?"<>|]'), "_");
    //     var code = parts.sublist(1).join("]").trim();
    //     var saveData = "[$title]\n$code";

    //     Directory(
    //       "${buildFolder.path}/${folderName}",
    //     ).createSync(recursive: true);

    //     Directory(
    //       "${buildFolder.path}/${folderName}/cheats",
    //     ).createSync(recursive: true);

    //     File(
    //       "${buildFolder.path}/${folderName}/cheats/${cheat.titleId}.txt",
    //     ).writeAsStringSync(saveData);
    //   }
    // }
    bLoadOverlay(false);
    Get.snackbar("완료", "저장 되었습니다.\n${buildFolder.path}");
  }
}
