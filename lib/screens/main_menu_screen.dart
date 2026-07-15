import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'login_screen.dart';
import 'game_settings_screen.dart';
import 'market_screend.dart';
import 'scoreboard_screen.dart';

class MainScreen extends StatefulWidget {
  final String userName;
  const MainScreen({super.key, required this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String guncelKullaniciAdi;

  @override
  void initState() {
    super.initState();
    guncelKullaniciAdi = widget.userName;
  }

  Future<void> _isimDegistirDialog() async {
    TextEditingController editController = TextEditingController(text: guncelKullaniciAdi);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kullanıcı Adını Değiştir"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Yeni kullanıcı adı"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('kullanici_adi', editController.text.trim());
                  setState(() => guncelKullaniciAdi = editController.text.trim());
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _hafizayiSifirla() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kullanici_adi');
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: _isimDegistirDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(guncelKullaniciAdi, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text("${Globals.totalGold}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _hafizayiSifirla,
            tooltip: 'İsmi Sıfırla ve Çıkış Yap',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "WORD CRUSH",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [Shadow(blurRadius: 15.0, color: Colors.black45, offset: Offset(3.0, 3.0))],
                ),
              ),
              const SizedBox(height: 10),
              const Text("Kelime Avı Başlıyor!", style: TextStyle(fontSize: 18, color: Colors.white70, fontStyle: FontStyle.italic)),
              const SizedBox(height: 50),
              _buildMenuButton("Yeni Oyun", Icons.play_arrow, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GameSettingsScreen())).then((_) => setState((){}));
              }),
              const SizedBox(height: 15),
              _buildMenuButton("Skor Tablosu", Icons.leaderboard, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoreboardScreen()));
              }),
              const SizedBox(height: 15),
              _buildMenuButton("Market", Icons.store, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketScreen())).then((_) => setState((){}));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPress) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPress,
        icon: Icon(icon, color: Colors.deepPurple),
        label: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 5),
      ),
    );
  }
}