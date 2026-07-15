import 'dart:math';
import 'package:flutter/material.dart';
import 'globals.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int totalGames = Globals.gameHistory.length;
    int highestScore = totalGames > 0 ? Globals.gameHistory.map((e) => e.score).reduce(max) : 0;
    int avgScore = totalGames > 0 ? (Globals.gameHistory.map((e) => e.score).reduce((a, b) => a + b) / totalGames).round() : 0;
    int totalWords = totalGames > 0 ? Globals.gameHistory.map((e) => e.wordCount).reduce((a, b) => a + b) : 0;
    
    String longestWord = "";
    for(var game in Globals.gameHistory) {
      if(game.longestWord.length > longestWord.length) longestWord = game.longestWord;
    }
    
    int totalTimeMin = totalGames > 0 ? Globals.gameHistory.map((e) => e.durationMin).reduce((a, b) => a + b) : 0;
    String totalTimeStr = totalTimeMin >= 60 ? "${totalTimeMin ~/ 60} saat ${totalTimeMin % 60} dakika" : "$totalTimeMin dakika";

    List<GameRecord> sortedHistory = List.from(Globals.gameHistory.reversed);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Skor Tablosu"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Genel Performans", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const Divider(),
                _buildSummaryRow("Toplam Oyun:", "$totalGames"),
                _buildSummaryRow("En Yüksek Puan:", "$highestScore"),
                _buildSummaryRow("Ortalama Puan:", "$avgScore"),
                _buildSummaryRow("Toplam Kelime:", "$totalWords"),
                _buildSummaryRow("En Uzun Kelime:", '"$longestWord"'),
                _buildSummaryRow("Toplam Süre:", totalTimeStr),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedHistory.length,
              itemBuilder: (context, index) {
                var game = sortedHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Oyun ${game.id}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tarih: ${game.date}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Grid: ${game.grid}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Puan: ${game.score}"),
                            Text("Süre: ${game.durationMin} dk"),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Kelime Sayısı: ${game.wordCount}"),
                            Text('En Uzun: "${game.longestWord}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
        ],
      ),
    );
  }
}