import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameRecord {
  final int id;
  final String date;
  final String grid;
  final int score;
  final int wordCount;
  final String longestWord;
  final int durationMin;

  GameRecord({
    required this.id,
    required this.date,
    required this.grid,
    required this.score,
    required this.wordCount,
    required this.longestWord,
    required this.durationMin,
  });

  // Veritabanına yazmak için JSON'a dönüştürme
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'grid': grid,
    'score': score,
    'wordCount': wordCount,
    'longestWord': longestWord,
    'durationMin': durationMin,
  };

  // Veritabanından okumak için JSON'dan dönüştürme
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'],
      date: json['date'],
      grid: json['grid'],
      score: json['score'],
      wordCount: json['wordCount'],
      longestWord: json['longestWord'],
      durationMin: json['durationMin'],
    );
  }
}

class Globals {
  static String username = "Kullanıcı";
  static int totalGold = 10000;

  // Joker Envanterimiz
  static int countBalik = 0;
  static int countTekerlek = 0;
  static int countLolipop = 0;
  static int countSerbest = 0;
  static int countKaristirma = 0;
  static int countParti = 0;

  static List<GameRecord> gameHistory = [];

  // ================= VERİ KAYDETME FONKSİYONLARI =================

  // Oyunu kaydet ve kalıcı hafızaya al
  static Future<void> addGameRecord(GameRecord record) async {
    gameHistory.add(record);
    await saveData();
  }

  // Tüm verileri (Altın, Jokerler, Skorlar) kalıcı hafızaya kaydet
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('totalGold', totalGold);
    await prefs.setInt('countBalik', countBalik);
    await prefs.setInt('countTekerlek', countTekerlek);
    await prefs.setInt('countLolipop', countLolipop);
    await prefs.setInt('countSerbest', countSerbest);
    await prefs.setInt('countKaristirma', countKaristirma);
    await prefs.setInt('countParti', countParti);

    // Skor Geçmişini JSON Formatında Kaydet
    List<String> historyJson = gameHistory.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('gameHistory', historyJson);
  }

  // Uygulama ilk açılırken (Splash Screen'de) verileri geri yükle
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    totalGold = prefs.getInt('totalGold') ?? 10000;
    countBalik = prefs.getInt('countBalik') ?? 0;
    countTekerlek = prefs.getInt('countTekerlek') ?? 0;
    countLolipop = prefs.getInt('countLolipop') ?? 0;
    countSerbest = prefs.getInt('countSerbest') ?? 0;
    countKaristirma = prefs.getInt('countKaristirma') ?? 0;
    countParti = prefs.getInt('countParti') ?? 0;

    List<String>? historyJson = prefs.getStringList('gameHistory');
    if (historyJson != null) {
      gameHistory = historyJson.map((e) => GameRecord.fromJson(jsonDecode(e))).toList();
    }
  }
}