import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:http/http.dart' as http;

class Suggestions extends StatefulWidget {
  const Suggestions(
      {Key? key,
      required this.championMap,
      required this.topSuggestions,
      required this.jungleSuggestions,
      required this.middleSuggestions,
      required this.bottomSuggestions,
      required this.supportSuggestions,
      required this.namesToKeys})
      : super(key: key);

  final Map<String, dynamic> championMap;
  final List<String> topSuggestions;
  final List<String> jungleSuggestions;
  final List<String> middleSuggestions;
  final List<String> bottomSuggestions;
  final List<String> supportSuggestions;
  final Map<String, String> namesToKeys;

  @override
  State<Suggestions> createState() => SuggestionsState();
}

class SuggestionsState extends State<Suggestions>
    with AutomaticKeepAliveClientMixin<Suggestions> {
  @override
  bool get wantKeepAlive => true;

  List<String> positions = [
    "Top...",
    "Jungle...",
    "Middle...",
    "Bottom...",
    "Support..."
  ];
  String selectedChampionId = "";
  Widget champInfo = Container();

  List<Widget> getDropdowns() {
    List<Widget> ret = [];
    List<List<String>> suggestions = [
      widget.topSuggestions,
      widget.jungleSuggestions,
      widget.middleSuggestions,
      widget.bottomSuggestions,
      widget.supportSuggestions
    ];
    for (int i = 0; i < positions.length; i++) {
      ret.add(DropdownSearch<String>(
        items: suggestions[i],
        selectedItem: positions[i],
        mode: Mode.DIALOG,
        showSearchBox: true,
        showSelectedItems: true,
        onChanged: (value) => {setChampionInfo(value?.split("  ")[0])},
      ));
    }
    ret.add(champInfo);

    return ret;
  }

  void setChampionInfo(String? champName) {
    if (!positions.contains(champName)) {
      setState(() {
        champInfo = Column(children: getChampionInfo(champName!));
      });
    }
  }

  dynamic getChampionImage(String champId) {
    return Container(
        margin: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(
              "http://ddragon.leagueoflegends.com/cdn/11.24.1/img/champion/" +
                  champId +
                  ".png"),
        ));
  }

  List<Widget> getChampionInfo(String champName) {
    List<Widget> info = [
      Text(
          champName +
              " - " +
              widget.championMap[widget.namesToKeys[champName]!]["title"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      getChampionImage(widget.namesToKeys[champName]!),
      const Text("Tags",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      Text(widget.championMap[widget.namesToKeys[champName]!]["tags"]
          .join(", "), style: const TextStyle(fontSize: 18)),
      const Text("Info",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      getChampionInfoData(widget.namesToKeys[champName]!),
      const Text("Stats",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      getChampionStats(widget.namesToKeys[champName]!),
    ];
    return info;
  }

  Widget getChampionInfoData(String champId) {
    List<TableRow> infoRows = [];

    List<String> infoKeys = [
      "attack",
      "defense",
      "magic",
      "difficulty",
    ];

    List<String> info = [
      "Attack: ",
      "Defense: ",
      "Magic: ",
      "Difficulty: ",
    ];

    for (int i = 0; i < infoKeys.length; i++) {
      infoRows.add(TableRow(children: [
        Text(info[i], style: const TextStyle(fontSize: 18)),
        Text(widget.championMap[champId]["info"][infoKeys[i]].toString(),  style: const TextStyle(fontSize: 18)),
      ]));
    }

    return Table(
      children: infoRows,
      defaultColumnWidth: const IntrinsicColumnWidth(),
    );
  }

  Widget getChampionStats(String champId) {
    List<TableRow> statsRows = [];

    List<String> statKeys = [
      "hp",
      "hpperlevel",
      "mp",
      "mpperlevel",
      "movespeed",
      "armor",
      "armorperlevel",
      "spellblock",
      "spellblockperlevel",
      "attackrange",
      "hpregen",
      "hpregenperlevel",
      "mpregen",
      "mpregenperlevel",
      "crit",
      "critperlevel",
      "attackdamage",
      "attackdamageperlevel",
      "attackspeed",
      "attackspeedperlevel"
    ];

    List<String> stats = [
      "HP: ",
      "HP Per Level: ",
      "MP: ",
      "MP Per Level: ",
      "Move Speed: ",
      "Armor: ",
      "Armor Per Level: ",
      "Spell Block: ",
      "Spell Block Per Level: ",
      "Attack Range: ",
      "HP Regen: ",
      "HP Regen Per Level: ",
      "MP Regen: ",
      "MP Regen Per Level: ",
      "Critical Strike: ",
      "Critical Strike Per Level: ",
      "Attack Damage: ",
      "Attack Damage Per Level: ",
      "Attack Speed: ",
      "Attack Speed Per Level: "
    ];

    for (int i = 0; i < statKeys.length; i++) {
      statsRows.add(TableRow(children: [
        Text(stats[i], style: const TextStyle(fontSize: 18)),
        Text(widget.championMap[champId]["stats"][statKeys[i]].toString(), style: const TextStyle(fontSize: 18)),
      ]));
    }

    return Table(
        children: statsRows, defaultColumnWidth: const IntrinsicColumnWidth());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: ConstrainedBox(
          constraints: const BoxConstraints(),
          child: Column(children: getDropdowns())),
    );
  }
}
