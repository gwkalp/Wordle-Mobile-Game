import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_menu_screen.dart'; // Ana menüye geçiş yapabilmek için import ettik

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _ismiKaydetVeGec() async {
    if (_nameController.text.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kullanici_adi', _nameController.text.trim());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainScreen(userName: _nameController.text.trim()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kullanıcı adı giriniz!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Klavye açıldığında ekranın sıkışmasını önler
      resizeToAvoidBottomInset: true,
      body: Container(
        // 1. ADIM: ŞIK RENK GEÇİŞLİ ARKA PLAN
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A00E0), // Koyu Mor
              Color(0xFF8E2DE2), // Parlak Mor/Pembe
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Küçük ekranlarda klavye açılınca kaydırma sağlar
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              // 2. ADIM: BEYAZ GÖLGELİ KART TASARIMI
              child: Card(
                elevation: 10, // Karta gölge verir (havada duruyor hissi)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Köşeleri yumuşatır
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videogame_asset,
                        size: 60,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Word Crush",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Hoş Geldiniz!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: 'Kullanıcı Adı Giriniz',
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _ismiKaydetVeGec,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple, // Buton rengi
                          foregroundColor: Colors.white, // Yazı rengi
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Oyuna Başla",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
