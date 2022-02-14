import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'compChecker.dart';
import 'suggestions.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  runApp(const MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> championMap = {};
  Map<String, String> namesToKeys = {};
  List<String> championKeys = [];
  List<String> championMenuItems = [];
  List<String> topSuggestions = ["Top..."];
  List<String> jungleSuggestions = ["Jungle..."];
  List<String> middleSuggestions = ["Middle..."];
  List<String> bottomSuggestions = ["Bottom..."];
  List<String> supportSuggestions = ["Support..."];

  @override
  void initState() {
    super.initState();
    gatherData();
  }

  void gatherData() async {
    var url = Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/11.24.1/data/en_US/champion.json');
    http.Response response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);
        championMap = decodedData['data'];

        for(String key in championMap.keys){
          namesToKeys[championMap[key]["name"]] = key;
        }

        setState(() {
          championKeys = decodedData["data"].keys.toList();
          championKeys[championKeys.indexOf("MonkeyKing")] = "Wukong";
          championKeys.sort();
          championKeys[championKeys.indexOf("Wukong")] = "MonkeyKing";

          championMenuItems = getChampionMenuItems();
        });
      } else {
        return;
      }
    } catch (e) {
      return;
    }

    url = Uri.parse(
        'https://10.0.2.2:5001/comppredict/GetWinRates');
    response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        String data = response.body;
        Map<String, dynamic> decodedData = jsonDecode(data);
        List<String> roles = ["top", "jungle", "middle", "bottom", "support"];
        List<List<String>> suggestions = [topSuggestions, jungleSuggestions, middleSuggestions, bottomSuggestions, supportSuggestions];
        int i = 0;
        for(String role in roles){
          for(var data in decodedData[role]){
            suggestions[i].add(championMap[data["roleChamp"]]["name"] + "  " + data["numWins"].toString() + "/" + data["totalGames"].toString() + "  " + (data["winRate"] * 100).toStringAsFixed(2) + "%  " + (data["totalGames"] < 1000 ? "⚠️" : ""));//😀⚠️
          }
          i++;
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  List<String> getChampionMenuItems() {
    List<String> ret = championKeys.map<String>((String name) {
      return championMap[name]["name"];
    }).toList();
    return ret;
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black45,//Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black45,
            title: const Text("LoL Assist"),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Comp Check")),
                Tab(icon: Text("Pick Suggestions")),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              CompChecker(championMap: championMap, championMenuItems: championMenuItems),
              Suggestions(championMap: championMap, topSuggestions: topSuggestions, jungleSuggestions: jungleSuggestions, middleSuggestions: middleSuggestions, bottomSuggestions: bottomSuggestions, supportSuggestions: supportSuggestions, namesToKeys: namesToKeys,),
            ],
          ),
        ),
      ),
    );
  }
}
