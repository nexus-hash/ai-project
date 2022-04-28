import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PredictionController {
  TextEditingController seedController;
  String prevSeedText;
  String artist;
  double temperature;
  int nWords;
  bool predictionDemanded;
  bool newPredsNeeded;
  String noPredText = 'Ask me when you need!';

  PredictionController(
      {this.seedController,
      this.artist,
      this.temperature,
      this.nWords,
      this.predictionDemanded = false,
      this.newPredsNeeded = true});

  get seed => seedController.text;
  set seed(String text) => seedController.text = text;
  void addToSeed(String text) => seedController.text += text;

  get artistName => artist.replaceAll(' ', '_');

  Future<List<String>> getPredictionsFromServer() async {
    bool errored = false;
    var client = http.Client();
    List<String> predictions = <String>[];

    var url = "http://lyrisis-server.herokuapp.com/predict";

    var logger = Logger();
    try {
      var response = await client.post(url, body: {
        'seed': seedController.text,
        'temp': temperature.toString(),
        'nwords': nWords.toString(),
        'artist': artistName
      });

      print(response.body);

      predictions = json.decode(response.body)['words'].map<String>((dynamic str) {
        String word = str.toString();

        // recall that the server strips off \n in the words
        // so if there are any "" in the predictions
        // they are probably newlines

        // TODO: Fix this '\n' thing on the server end
        // the "" part checking is ok here I guess?

        int longWordLim = (artistName != 'Meraki') ? 50 : 10;

        if (nWords < longWordLim) {
          if (word == "\n") {
            return "(newline)";
          } else if (word == "") {
            return "-";
          } else {
            return word.replaceAll('\n', '');
          }
        } else {
          return word;
        }
      }).toList();

      logger.d('Response: ' + response.body);
    } catch (e) {
      logger.e('Error while retrieving predictions from server!');
      errored = true;
      print(e.toString());
    } finally {
      client.close();
    }

    if (errored) {
      throw Exception("Couldn't fetch predictions");
    }

    // only the first nWords words are needed
    // in case the server was feeling generous as gave us more

    if (artistName != 'Meraki') {
      return (predictions.length < nWords ? predictions : predictions.sublist(0, nWords));
    } else {
      if (nWords < 10) {
        return (predictions.length < nWords ? predictions : predictions.sublist(0, nWords));
      } else {
        return predictions;
      }
    }
  }
}
