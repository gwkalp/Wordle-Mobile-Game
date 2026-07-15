import 'package:flutter/material.dart';
import 'game_screen.dart';

class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key});

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  int currentStep = 1;
  int selectedGrid = 0;
  int selectedMove = 0;

  void _selectGrid(int size) {
    setState(() {
      selectedGrid = size;
      currentStep = 2;
    });
  }

  void _selectMove(int moves) {
    setState(() {
      selectedMove = moves;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GameScreen(gridSize: selectedGrid, moveLimit: selectedMove),
      ),
    );
  }

  // GERİ DÖNÜŞ MANTIĞINI BURADA YÖNETİYORUZ
  void _geriyeDon() {
    if (currentStep == 2) {
      // 2. Adımdaysa 1. Adıma dön
      setState(() {
        currentStep = 1;
      });
    } else {
      // Zaten 1. Adımdaysa sayfayı tamamen kapat (Ana Menüye dön)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope: Android'in fiziksel geri tuşunu kontrol etmemizi sağlar
    return PopScope(
      canPop:
          currentStep ==
          1, // Sadece 1. adımdaysa fiziksel tuşla çıkmaya izin ver
      onPopInvoked: (didPop) {
        if (didPop) return; // Eğer çıkış yapıldıysa bir şey yapma
        _geriyeDon(); // Çıkış yapılamadıysa (yani 2. adımdaysak) bizim fonksiyonu çalıştır
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Oyun Ayarları"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // AppBar'daki sol üstteki geri butonunu eziyoruz ve kendi fonksiyonumuzu bağlıyoruz
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _geriyeDon,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentStep == 1
                        ? "Oyun Alanı Boyutunu Seç"
                        : "Hamle Sayısını Seç",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  if (currentStep == 1) ...[
                    _buildOptionButton(
                      "10x10 Grid",
                      "Kolay Seviye",
                      Icons.grid_on,
                      () => _selectGrid(10),
                    ),
                    const SizedBox(height: 15),
                    _buildOptionButton(
                      "8x8 Grid",
                      "Orta Seviye",
                      Icons.grid_view,
                      () => _selectGrid(8),
                    ),
                    const SizedBox(height: 15),
                    _buildOptionButton(
                      "6x6 Grid",
                      "Zor Seviye",
                      Icons.grid_4x4,
                      () => _selectGrid(6),
                    ),
                  ],

                  if (currentStep == 2) ...[
                    _buildOptionButton(
                      "25 Hamle",
                      "Kolay Seviye",
                      Icons.directions_walk,
                      () => _selectMove(25),
                    ),
                    const SizedBox(height: 15),
                    _buildOptionButton(
                      "20 Hamle",
                      "Orta Seviye",
                      Icons.directions_run,
                      () => _selectMove(20),
                    ),
                    const SizedBox(height: 15),
                    _buildOptionButton(
                      "15 Hamle",
                      "Zor Seviye",
                      Icons.flash_on,
                      () => _selectMove(15),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 75,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
