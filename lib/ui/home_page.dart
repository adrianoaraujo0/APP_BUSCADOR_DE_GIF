import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? search;

  int offset = 0;

  Future<Map> getGifs() async {
    http.Response response;

    if (search == "")
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=sMHfYyDTtXm5OoPLqa81plQKvIUSKwzg&limit=20&rating=g"));
    else
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=sMHfYyDTtXm5OoPLqa81plQKvIUSKwzg&q=$search&limit=20&offset=$offset&rating=g&lang=en"));

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  search = text;
                });
              },
            ),
            Expanded(
              child: FutureBuilder(
                  future: getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return createGifsTable(context, snapshot);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

Widget createGifsTable(BuildContext context, AsyncSnapshot snapshot) {
  return GridView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 10,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10.0,
      ),
      itemCount: (snapshot.data! as Map<String, dynamic>)['data'].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover),
        );
      });
}
