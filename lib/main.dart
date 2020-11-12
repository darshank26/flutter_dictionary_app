import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String url ="https://owlbot.info/api/v4/dictionary/";
  String token = "your api key over here";
  StreamController _streamController;
  Stream _stream;
  TextEditingController _controller = TextEditingController();
  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  _search() async{

    if(_controller.text == null || _controller.text.length == 0)
      {
        _streamController.add(null);
      }

    _streamController.add("waiting");
    Response response = await get(url + _controller.text.trim(),headers: {"Authorization": "Token "+token});
    _streamController.add(json.decode(response.body));


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Flutter Dictionary App"),),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left:12.0,bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),

                  ),
                  child: TextFormField(
                    onChanged: (String text)
                    {
                      if(_timer?.isActive ?? false) _timer.cancel();
                      _timer = Timer(const Duration(milliseconds: 1000),()
                      {
                        _search();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word.",
                      contentPadding: EdgeInsets.only(left:24.0),
                      border: InputBorder.none
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom:8.0),
                child: IconButton(icon: Icon(
                  Icons.search,
                  size: 35.0,
                  color: Colors.white,
                ), onPressed:(){
                  _search();
                }),
              )
            ],
          ),
        ),
      ),
      body:Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx,AsyncSnapshot snapshot)
          {
            if(snapshot.data == "waiting")
              {
                return Center(child: CircularProgressIndicator());
              }
            if(snapshot.data == null)
              {
                return Center(child: Text("Enter a word to search"));
              }

            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context,int i) {
                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListBody(
                    children: [
                      Container(
                        color: Colors.grey[100],
                        child: ListTile(
                          leading: snapshot.data["definitions"][i]["image_url"] == null ?
                          null : CircleAvatar(backgroundImage: NetworkImage(snapshot.data["definitions"][i]["image_url"] ),),
                          title: Text(_controller.text.trim() + ' (' + '${snapshot.data["definitions"][i]["type"]}' + ')',style: TextStyle(letterSpacing: 1),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(snapshot.data["definitions"][i]["definition"],style: TextStyle(letterSpacing: 0.6,),textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: snapshot.data["definitions"][i]["example"] == null?
                        null :Text("Example: "+'${snapshot.data["definitions"][i]["example"]}') ,
                      )
                    ],
                  ),
                );
            },
            );
          },
        ),
      ),
    );
  }

}
