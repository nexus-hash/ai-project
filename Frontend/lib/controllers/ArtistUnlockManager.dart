import 'package:shared_preferences/shared_preferences.dart';

@deprecated
class ArtistUnlockManagerOld {
  static List<String> artistsAvailable = ['Taylor Swift', 'Eminem', 'Adele', 'Celine Dion', 'Meraki'];

  static void initArtists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getKeys().length < artistsAvailable.length) {
      for (String artist in artistsAvailable) {
        addOrSetArtist(artist, false);
      }
    }

    unlockArtist('Taylor Swift'); // Hers is unlocked from the beginning
  }

  static Future<List<String>> getUnlockedArtistNames() async {
    List<String> unlockedArtists = <String>[];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (String artist in artistsAvailable) {
      if (prefs.getBool(artist)) {
        unlockedArtists.add(artist);
      }
    }

    return unlockedArtists;
  }

  static void addOrSetArtist(String artistName, bool unlocked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(artistName, unlocked);
  }

  static void unlockArtist(String artistName) {
    addOrSetArtist(artistName, true);
  }
}

class ArtistUnlockManager {
  static List<String> artistsAvailable = ['Taylor Swift', 'Eminem', 'Kanye West', 'Adele', 'Celine Dion'];

  static void initArtists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.getKeys().contains('unlocked')) {
      // first start
      prefs.setStringList('unlocked', <String>['Taylor Swift']);
    }

    if (!prefs.getStringList('unlocked').contains('Taylor Swift')) {
      // If Taylor Swift is not there due to some reason, unlock her
      List<String> unlockedNow = prefs.getStringList('unlocked');

      prefs.setStringList('unlocked', unlockedNow + <String>['Taylor Swift']);
    }
  }

  static Future<List<String>> getUnlockedArtistNames() async {
    List<String> unlockedArtists = <String>[];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    unlockedArtists = prefs.getStringList('unlocked');
    return unlockedArtists;
  }

  static void addOrSetArtist(String artistName, bool toUnlock) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> unlockedNow = prefs.getStringList('unlocked');

    print('unlockedNow.contains($artistName): ' + unlockedNow.contains(artistName).toString());
    if (unlockedNow.contains(artistName) && !toUnlock) {
      unlockedNow.remove(artistName);
    }
    else if ((!unlockedNow.contains(artistName)) && toUnlock) {
      unlockedNow += [artistName];
    }

    print('Seeting unlockedNow as: ' + unlockedNow.toString());
    prefs.setStringList('unlocked', unlockedNow);
  }

  static void unlockArtist(String artistName) {
    addOrSetArtist(artistName, true);
  }

  static void lockArtist(String artistName) {
    addOrSetArtist(artistName, false);
  }
}