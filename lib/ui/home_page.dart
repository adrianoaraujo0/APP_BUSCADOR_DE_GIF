import 'dart:convert';

import 'package:buscador_de_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  String? search;

  int offset = 0;

  Future<Map> getGifs() async {
    http.Response response;

    if (search == null || search == "") {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=sMHfYyDTtXm5OoPLqa81plQKvIUSKwzg&limit=20&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=sMHfYyDTtXm5OoPLqa81plQKvIUSKwzg&q=$search&limit=19&offset=$offset&rating=g&lang=en"));
    }
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(179, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(179, 0, 0, 0),
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white)),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: getGifs(),
                builder: (context, snapshot) {
                  //snapshot.connectionState = retorna o status da conexao.
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
                        return Container(
                          child: Text("ERRO...."),
                        );
                      else
                        return createGifTable(context, snapshot);
                  }
                },
              ))
        ],
      ),
    );
  }

  int getCount(int count) {
    if (search == "" || search == null)
      return count;
    else
      return count + 1;
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> listGif = snapshot.data["data"];

    print(listGif.length);

    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getCount(listGif.length),
      itemBuilder: (context, index) {
        if (search == "" || index < listGif.length) {
          return GestureDetector(

            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
              ["url"],
              height: 280,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(
                    snapshot.data["data"][index],
                  ),
                ),
              );
            },
            onLongPress: () {

              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
              ["url"]);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 60, color: Colors.white),
                  Text("Carregando mais...",
                      style: TextStyle(color: Colors.white, fontSize: 19))
                ],
              ),
              onTap: () {
                setState(() {
                  offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }
}
