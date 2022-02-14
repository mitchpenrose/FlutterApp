import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class CompChecker extends StatefulWidget {
  const CompChecker(
      {Key? key, required this.championMap, required this.championMenuItems})
      : super(key: key);

  final Map<String, dynamic> championMap;
  final List<String> championMenuItems;

  @override
  State<CompChecker> createState() => CompCheckerState();
}

class CompCheckerState extends State<CompChecker> with AutomaticKeepAliveClientMixin<CompChecker>{

  @override
  bool get wantKeepAlive => true;
  // final Map<String, dynamic> championMap;
  // final List<String> championMenuItems;

  // CompCheckerState({required this.championMap, required this.championMenuItems});

  List<String?> championSelections = [
    "Top...",
    "Top...",
    "Jungle...",
    "Jungle...",
    "Middle...",
    "Middle...",
    "Bottom...",
    "Bottom...",
    "Support...",
    "Support...",
  ];

  List<String> positions = [
    "Top...",
    "Top...",
    "Jungle...",
    "Jungle...",
    "Middle...",
    "Middle...",
    "Bottom...",
    "Bottom...",
    "Support...",
    "Support...",
  ];

  Future<void> showPredictionDialog(String text) async {
    List<String> predictionAndConfidence = text.split(",");
    String prediction =
        predictionAndConfidence[0] == "0" ? "Blue Team Wins" : "Red Team Wins";
    String confidence =
        (double.parse(predictionAndConfidence[1]) * 100).toStringAsFixed(2) +
            "%";
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(prediction),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Prediction is " +
                    (prediction == "Blue Team Wins"
                        ? "blue team wins "
                        : "red team wins ") +
                    "with a confidence of " +
                    confidence),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setResult() async {
    EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: const LinearProgressIndicator());
    String redTop = widget.championMap[championSelections[0]]["name"];
    String redJungle = widget.championMap[championSelections[2]]["name"];
    String redMiddle = widget.championMap[championSelections[4]]["name"];
    String redBottom = widget.championMap[championSelections[6]]["name"];
    String redSupport = widget.championMap[championSelections[8]]["name"];
    String blueTop = widget.championMap[championSelections[1]]["name"];
    String blueJungle = widget.championMap[championSelections[3]]["name"];
    String blueMiddle = widget.championMap[championSelections[5]]["name"];
    String blueBottom = widget.championMap[championSelections[7]]["name"];
    String blueSupport = widget.championMap[championSelections[9]]["name"];
    var url = Uri.parse(//10.0.2.2
        "https://10.0.2.2:5001/comppredict/GetPrediction?redTop=$redTop&redJungle=$redJungle&redMiddle=$redMiddle&redBottom=$redBottom&redSupport=$redSupport&blueTop=$blueTop&blueJungle=$blueJungle&blueMiddle=$blueMiddle&blueBottom=$blueBottom&blueSupport=$blueSupport");
    http.Response response = await http.get(url);
    EasyLoading.dismiss();
    try {
      if (response.statusCode == 200) {
        String text = response.body;
        showPredictionDialog(text);
        //print(championKeys);
        //return decodedData;
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  dynamic getPredictButton() {
    return championSelections.contains("Top...") ||
            championSelections.contains("Jungle...") ||
            championSelections.contains("Middle...") ||
            championSelections.contains("Bottom...") ||
            championSelections.contains("Support...")
        ? const Text("")
        : OutlinedButton(
            onPressed: () => {setResult()},
            child: const Text("Predict Result!"));
  }

  dynamic getChampionImage(int index) {
    return positions.contains(championSelections[index])
        ? Container(
            margin: const EdgeInsets.all(8),
            child: const CircleAvatar(
              radius: 60,
            ))
        : Container(
            margin: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  "http://ddragon.leagueoflegends.com/cdn/11.24.1/img/champion/" +
                      (championSelections[index] ?? "") +
                      ".png"),
            ));
  }

  void setChampionSelection(String? selection, int index) {
    setState(() {
      if (positions.contains(selection)) {
        championSelections[index] = selection;
      } else {
        championSelections[index] = widget.championMap.values
                .firstWhere((element) => element["name"] == selection)["id"]
            as String;
      }
    });
  }

  dynamic getSideChampionSelections() {
    dynamic widgetList = <Widget>[];
    for (int i = 0; i < 10; i++) {
      List<Widget> children = [];
      children.add(DropdownSearch<String>(
          //mode of dropdown
          mode: Mode.DIALOG,
          //to show search box
          showSearchBox: true,
          showSelectedItems: true,
          //list of dropdown items
          items: [positions.elementAt(i), ...widget.championMenuItems],
          onChanged: (String? selection) =>
              {setChampionSelection(selection, i)},
          //show selected item
          selectedItem: positions.elementAt(i)));
      children.add(getChampionImage(i));
      widgetList.add(Column(children: children));
    }
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.red, Colors.blue],
        ),
      ),
      child: Column(
        children: <Widget>[
          Flexible(
              child: GridView.count(
            crossAxisCount: 2,
            children: getSideChampionSelections(),
            shrinkWrap: true,
          )),
          getPredictButton(),
        ],
      ),
    );
  }
}
