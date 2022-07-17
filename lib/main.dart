import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = ScrollController();
  List<String> items = [];
  bool hasmore=true;
  int page=1;
  bool isLoding=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future fetch() async {
    if(isLoding) return;
    isLoding=true;
    const limit=25;
    var url =
    Uri.parse("https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page");

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print('data');
      var jsonResponse =
      convert.jsonDecode(response.body) ;
      setState(() {
        page++;
        isLoding=false;
        if(jsonResponse.length<limit){
          hasmore=false;
        }
        items.addAll(jsonResponse.map<String>((item) {
          final number=item['id'];
          return "Item $number";
        }).toList());
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  Future refresh()async{
    setState(() {
      isLoding=false;
      hasmore=true;
      page=1;
      items.clear();
    });
    fetch();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(

        onRefresh: refresh,
        child: ListView.builder(
            controller: controller,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index < items.length) {
                final item = items[index];
                return ListTile(
                  title: Text(item),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child:hasmore ? CircularProgressIndicator():Text('data tugadi')),
                );
              }
            }),
      ),
    );
  }
}
