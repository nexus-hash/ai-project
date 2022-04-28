import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyricyst_app/pages/TextEditorPageNew.dart';
import 'controllers/LoopAnimController.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'controllers/ArtistUnlockManager.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Color.fromARGB(255, 36, 44, 70),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromRGBO(249, 249, 227, 30),
      systemNavigationBarIconBrightness: Brightness.dark));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyricyst',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LoopAnimController cont = LoopAnimController("start_btn_unselected");
  bool pingTried = false;

  void pingServer() async {
    Fluttertoast.showToast(
      msg: 'Checking connection...',
      backgroundColor: Color.fromRGBO(2, 75, 150, 0.8),
      textColor: Colors.white,
    );
    // Ping server once for fast predictions
    var uri = "https://lyrisis-server.herokuapp.com";

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Pinging successful!',
          backgroundColor: Color.fromRGBO(51, 128, 89, 0.8),
          textColor: Colors.white,
        );
        setState(() => pingTried = true);
      } else {
        Fluttertoast.showToast(
          msg: 'Server error!',
          backgroundColor: Color.fromRGBO(168, 61, 61, 0.9),
          textColor: Colors.white,
        );
        print('Server RROR code: ' + response.statusCode.toString());
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Connection error! Check internet.',
        backgroundColor: Color.fromRGBO(168, 61, 61, 0.9),
        textColor: Colors.white,
      );
      print('ERROR WHILE PINGING: ' + e.toString());
    }
    setState(() => pingTried = true);
  }

  @override
  void initState() {
    super.initState();
    pingServer();
    ArtistUnlockManager.initArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset('assets/bg_screen1_notext_light4.png', fit: BoxFit.fill),
          ),
          Positioned(
            left: 40,
            top: 98,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Wrap(
                children: <Widget>[
                  Text(
                    'Short of words?',
                    style: TextStyle(fontFamily: 'RhodiumLibre', fontSize: 48, color: Color.fromARGB(255, 36, 44, 70)),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 40,
            top: MediaQuery.of(context).size.height * 0.6 + 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Wrap(
                children: <Widget>[
                  Text(
                    'Ask me!',
                    style: TextStyle(fontFamily: 'RhodiumLibre', fontSize: 32, color: Color.fromARGB(255, 34, 57, 85)),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 40,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  if (pingTried) {
                    cont.animation = 'start_btn_selected';
                    cont.loopAmt = -2;
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please wait, still testing connection.',
                      backgroundColor: Color.fromRGBO(150, 62, 84, 0.9),
                      textColor: Colors.white,
                    );
                  }
                });

                if (pingTried) {
                  await Future.delayed(Duration(milliseconds: 170), () {
                    setState(() {
                      cont.animation = 'start_btn_unselected';
                      cont.loopAmt = -1;
                    });
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TextEditorPageNew();
                    }));
                  });
                }
              },
              child: SizedBox(
                width: 300,
                height: 100,
                child: FlareActor('assets/Lyricyst_StartBtn.flr', controller: cont, animation: 'start_btn_unselected'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
