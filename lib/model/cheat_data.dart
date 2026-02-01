class CheatData {
  CheatData({
    required this.name,
    required this.slug,
    required this.count,
    required this.cheats,
  });
  String name;
  String slug;
  int count;
  List<Cheat> cheats;

  String image = "";
  String banner = "";

  bool bloadCheat = false;

  factory CheatData.fromJson(Map<String, dynamic> json) {
    var cheats = List<Cheat>.from(
      json["cheats"].map((x) => Cheat.fromJson(x)..name = json["name"]),
    );
    final seen = <String>{};
    final uniqueCheats = cheats.where((str) => seen.add(str.build)).toList();

    return CheatData(
      name: json["name"],
      slug: json["slug"],
      count: json["count"],
      cheats: uniqueCheats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "slug": slug,
      "count": count,
      "cheats": cheats.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return "NameData(name: $name, slug: $slug, count: $count, cheats: $cheats)";
  }
}

class Cheat {
  Cheat({required this.build, required this.titleId});
  String build;
  String titleId;
  String name = "";

  List<CheatCode> cheatList = [];

  factory Cheat.fromJson(Map<String, dynamic> json) {
    return Cheat(build: json["build"] ?? "", titleId: json["titleid"] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {"build": build, "titleId": titleId};
  }

  @override
  String toString() => "Cheat(build: $build, titleId: $titleId)";
}

class CheatCode {
  CheatCode({
    required this.id,
    required this.titles,
    required this.content,
    required this.buildid,
  });
  int id = 0;
  List<String> titles = [];
  String content = "";
  String buildid = "";
  bool bCheckd = false;
  String titleId = "";

  factory CheatCode.fromJson(Map<String, dynamic> json) {
    return CheatCode(
      id: json["id"] ?? "",
      buildid: json["buildid"] ?? "",
      titles: List<String>.from(json["titles"].map((x) => x)),
      content: json["content"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"content": content};
  }

  @override
  String toString() => "CheatCode(content: $content)";
}
