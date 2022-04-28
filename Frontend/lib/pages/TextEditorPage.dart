import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lyricyst_app/controllers/PredictionController.dart';
import 'package:lyricyst_app/pages/PredictionPage.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/ArtistUnlockManager.dart';

class TextEditorPage extends StatefulWidget {
  TextEditorPage({Key key}) : super(key: key);

  final PredictionController predictionController =
      PredictionController(artist: 'Taylor Swift', temperature: 0.5, nWords: 5, predictionDemanded: false);
  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final seedTextController = TextEditingController();

  final seedTextFocusNode = FocusNode();

  List<String> artists = <String>[];

  void initArtists() async {
    List<String> currentlyUnlockedArtists = await ArtistUnlockManager.getUnlockedArtistNames();

    try {
      setState(() {
        artists = currentlyUnlockedArtists;
      });
    } catch (e) {
      // To prevent calling setState before the state is built, we've got this
      // Try after a few milliseconds

      try {
        await Future.delayed(Duration(milliseconds: 70), () {
          setState(() {
            artists = currentlyUnlockedArtists;
          });
        });
      } catch (er) {
        Fluttertoast.showToast(
          msg: 'Could not update artist list!',
          backgroundColor: Color.fromRGBO(150, 62, 84, 0.9),
          textColor: Colors.white,
        );
        print(er);
      }
    }
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Color.fromARGB(255, 36, 44, 70),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromRGBO(249, 249, 227, 30),
        systemNavigationBarIconBrightness: Brightness.dark));

    super.initState();
    widget.predictionController.seedController = seedTextController;
    initArtists();
  }

  void onPredictionChosen(String item) {
    setState(() {
      seedTextController.text += ' ' + item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DrawerHeader(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'OPTIONS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: Text('Artist: ')),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: DropdownButton<String>(
                      value: widget.predictionController.artist,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 20,
                      elevation: 8,
                      onChanged: (newVal) => setState(() {
                        widget.predictionController.newPredsNeeded = true;
                        widget.predictionController.artist = newVal;
                      }),
                      items: artists.map<DropdownMenuItem<String>>((String name) {
                        return DropdownMenuItem<String>(
                          child: Padding(
                            child: GestureDetector(
                              child: Text(name),
                              onLongPress: () {
                                if (name != 'Taylor Swift') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Lock Artist'),
                                      content: Text('Do you want to lock (hide) $name?'),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop('dialog');
                                            Navigator.of(context).pop();
                                            ArtistUnlockManager.lockArtist(name);
                                            setState(() {
                                              // Just removing the artist from the list will cause an error
                                              // if that artist was the currently selected one

                                              // In that case, replace the current artist with the previous one
                                              if (widget.predictionController.artist == name) {
                                                // Note that there will be atleast one name in the list
                                                // i.e, Taylor Swift. So no need to to check for index bounds

                                                // But still I will check... I guess
                                                widget.predictionController.artist = artists[max(0, artists.indexOf(name) - 1)];
                                              }
                                              artists.remove(name);
                                            });
                                          },
                                          child: Text('Yes'),
                                        ),
                                        FlatButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(context).pop('dialog');
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  Fluttertoast.showToast(msg: "You can't lock Taylor Swift");
                                }
                              },
                            ),
                            padding: EdgeInsets.only(right: 10),
                          ),
                          value: name,
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 50), child: Text('Temperature: ')),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: SpinnerInput(
                      step: 0.1,
                      minValue: 0.1,
                      fractionDigits: 1,
                      maxValue: 1.0,
                      middleNumberPadding: EdgeInsets.symmetric(horizontal: 10),
                      spinnerValue: widget.predictionController.temperature,
                      onChange: (newVal) => setState(
                        () {
                          widget.predictionController.newPredsNeeded = true;
                          widget.predictionController.temperature = newVal;
                        },
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 50), child: Text('Number of words: ')),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: SpinnerInput(
                      step: 1,
                      minValue: 1,
                      maxValue: 600,
                      spinnerValue: widget.predictionController.nWords.toDouble(),
                      middleNumberPadding: EdgeInsets.symmetric(horizontal: 17),
                      fractionDigits: 0,
                      onChange: (newVal) => setState(
                        () {
                          widget.predictionController.newPredsNeeded = true;
                          widget.predictionController.nWords = newVal.toInt();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FlatButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.all_out, color: Colors.lightBlue),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Easter eggs',
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
                var alertDlg = AlertDialog(
                  title: Text('Easter Eggs'),
                  content: Text("Want hints about the easter eggs? Visit lyrisis-server.herokuapp.com!"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Go!'),
                      onPressed: () async {
                        Navigator.of(context).pop('dialog');
                        const url = 'https://lyrisis-server.herokuapp.com';
                        if (await canLaunch(url))
                          launch(url);
                        else
                          Fluttertoast.showToast(msg: "Sorry, can't open URL!");
                      },
                    ),
                    FlatButton(
                      child: Text('Leave it'),
                      onPressed: () {
                        // close the dialog
                        Navigator.of(context).pop('dialog'); // Navigator.pop(context) should work too I guess
                        Fluttertoast.showToast(msg: 'Okay, as you wish!');
                      },
                    ),
                  ],
                );

                showDialog(
                  context: context,
                  builder: (_) => alertDlg,
                  barrierDismissible: true,
                );
              },
            ),
          ],
        ),
      ),
      body: Builder(
        // we need to do this to get a new BuildContext inside to call Scaffold.of()
        builder: (context) {
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(
                  'assets/screen2_bg.png',
                  fit: BoxFit.fill,
                ), // The BG
              ),
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 12),
                      child: GestureDetector(
                          child:
                              Image.asset('assets/drawer_open_arrow.png', height: MediaQuery.of(context).size.height / 14),
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Wrap(
                      children: <Widget>[
                        TextField(
                          style: TextStyle(fontFamily: 'RhodiumLibre', fontSize: 20),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle:
                                TextStyle(fontFamily: 'RhodiumLibre', fontSize: 20, color: Color.fromRGBO(229, 235, 194, 1)),
                            contentPadding: EdgeInsets.only(bottom: 10),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(234, 244, 205, 1),
                                width: 2,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(234, 244, 205, 1),
                                width: 2,
                              ),
                            ),
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(234, 244, 205, 1), width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(234, 244, 205, 1), width: 2),
                            ),
                          ),
                          cursorColor: Color.fromRGBO(234, 244, 205, 1),
                          enabled: true,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        seedTextFocusNode.requestFocus();
                      },
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: TextField(
                                  controller: widget.predictionController.seedController,
                                  focusNode: seedTextFocusNode,
                                  style: TextStyle(fontFamily: 'RhodiumLibre', fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Type here',
                                    hintStyle: TextStyle(
                                      fontFamily: 'RhodiumLibre',
                                      fontSize: 15,
                                      color: Color.fromRGBO(229, 235, 194, 1),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  cursorColor: Color.fromRGBO(229, 235, 194, 1),
                                  maxLines: null,
                                  onChanged: (str) {
                                    List<String> availableArtists = ArtistUnlockManager.artistsAvailable;
                                    bool unlockedSomething = false;
                                    String unlockedArtist = '';

                                    // Regular unlock for actual artists
                                    for (String artist in availableArtists.sublist(0, 5)) {
                                      if (str.endsWith('I <3 ' + artist + "'s songs") && !artists.contains(artist)) {
                                        ArtistUnlockManager.unlockArtist(artist);
                                        unlockedSomething = true;
                                        unlockedArtist = artist;
                                        break;
                                      }
                                    }

                                    if (str.endsWith("I <3 me.r.a_ki's poems") && !artists.contains('Meraki')) {
                                      String artist = 'Meraki';
                                      ArtistUnlockManager.unlockArtist(artist);
                                      unlockedSomething = true;
                                      unlockedArtist = artist;
                                    }

                                    print('UNLOCKED ' + unlockedArtist + ' !');

                                    if (unlockedSomething) {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          List<String> titles = ['Congrats!', 'Wow!', 'Great!', 'Yay!', 'Hurray!', 'Hey!'];

                                          int rand = Random().nextInt(titles.length);

                                          return AlertDialog(
                                            title: Text(titles[rand]), // Randomize the title for some more fun
                                            content: Text('You have unlocked $unlockedArtist!'),
                                            actions: <Widget>[
                                              FlatButton(
                                                onPressed: () => Navigator.of(context).pop('dialog'),
                                                child: Text('Great!'),
                                              ),
                                              FlatButton(
                                                child: Text('Re-lock'),
                                                onPressed: () {
                                                  setState(() {
                                                    Navigator.of(context).pop('dialog');
                                                    ArtistUnlockManager.lockArtist(unlockedArtist);
                                                    if (artists.contains(unlockedArtist)) {
                                                      artists.remove(unlockedArtist);
                                                    }
                                                  });
                                                  // unnecessary, but still
                                                  unlockedSomething = false;
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }

                                    widget.predictionController.newPredsNeeded = true;

                                    setState(() {
                                      print(artists);
                                      if (unlockedSomething) {
                                        artists.add(unlockedArtist);
                                      }
                                      print(artists);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 5),
                          child: Image.asset('assets/need_help_label_editor.png',
                              height: MediaQuery.of(context).size.height / 35),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 32, bottom: 0),
                          child: GestureDetector(
                              child: Image.asset('assets/popup_arrow_editor.png',
                                  height: MediaQuery.of(context).size.height / 15),
                              onTap: () {
                                setState(() {
                                  //predictionKey
                                  //.currentState.predictionDemanded = true;
                                  widget.predictionController.predictionDemanded = true;
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                top: widget.predictionController.predictionDemanded
                    ? MediaQuery.of(context).size.height * (1 - 1 / 2.7)
                    : MediaQuery.of(context).size.height,
                bottom: 0,
                left: 0,
                right: 0,
                curve: Curves.easeOutCubic,
                duration: Duration(milliseconds: 350),
                child: PredictionPage(
                  //key: predictionKey,
                  predictionController: widget.predictionController,
                  onCloseRequested: () {
                    setState(() {
                      widget.predictionController.predictionDemanded = false;
                    });
                  },
                  onChipPressed: (chipText) {
                    setState(() {
                      widget.predictionController.seedController.text += chipText == " (newline)" ? '\n' : chipText;
                      widget.predictionController.newPredsNeeded = true;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    seedTextFocusNode.dispose();
    seedTextController.dispose();
    super.dispose();
  }
}
