import 'package:flutter/material.dart';
import 'globals.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  void _satinAl(int fiyat, VoidCallback onSuccess) {
    if (Globals.totalGold >= fiyat) {
      setState(() {
        Globals.totalGold -= fiyat;
        onSuccess();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Satın alma başarılı!"), backgroundColor: Colors.green, duration: Duration(milliseconds: 500))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yeterli altınınız yok!"), backgroundColor: Colors.red, duration: Duration(milliseconds: 500))
      );
    }
  }

  Widget _buildMarketItem(String name, String desc, int price, IconData icon, int currentCount, VoidCallback onBuy) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text("Sahip Olunan: $currentCount", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.orange, size: 18),
                    Text(" $price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Globals.totalGold >= price ? Colors.green : Colors.grey),
                  onPressed: () => _satinAl(price, onBuy),
                  child: const Text("Al", style: TextStyle(color: Colors.white)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Market"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.orange),
                const SizedBox(width: 4),
                Text("${Globals.totalGold}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        children: [
          _buildMarketItem("Balık", "Gridde rastgele olarak harfleri yok etmektedir.", 100, Icons.set_meal, Globals.countBalik, () => Globals.countBalik++),
          _buildMarketItem("Tekerlek", "Seçilen harfin bulunduğu satır ve sütundaki harfleri yok eder.", 200, Icons.settings, Globals.countTekerlek, () => Globals.countTekerlek++),
          _buildMarketItem("Lolipop Kırıcı", "Gridde seçilen tek bir harfi yok etmek için kullanılır.", 75, Icons.hardware, Globals.countLolipop, () => Globals.countLolipop++),
          _buildMarketItem("Serbest Değiştirme", "Gridde birbirine temas eden iki harfin yerini değiştirir.", 125, Icons.swap_horiz, Globals.countSerbest, () => Globals.countSerbest++),
          _buildMarketItem("Harf Karıştırma", "Gridde bulunan harflerin rastgele karıştırılmasını sağlar.", 300, Icons.shuffle, Globals.countKaristirma, () => Globals.countKaristirma++),
          _buildMarketItem("Parti Güçlendiricisi", "Tüm harfler yok edilir ve yukarıdan yenileri düşer.", 400, Icons.celebration, Globals.countParti, () => Globals.countParti++),
        ],
      ),
    );
  }
}