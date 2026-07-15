import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'globals.dart';

// --- TILE SINIFI GÜNCELLENDİ (id EKLENDİ) ---
class Tile {
  final String id;
  String letter;
  String power;
  bool isExploding;
  Tile({
    required this.id,
    required this.letter,
    this.power = "none",
    this.isExploding = false,
  });
}

enum JokerMode { none, lolipop, tekerlek, swapFirst, swapSecond }

class GameScreen extends StatefulWidget {
  final int gridSize;
  final int moveLimit;

  const GameScreen({
    super.key,
    required this.gridSize,
    required this.moveLimit,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int currentMoves;
  int currentScore = 0;

  int possibleWordCount = 0;
  int _tileIdCounter = 0; // Her yeni harfe benzersiz ID vermek için sayaç

  late DateTime baslangicZamani;
  int bulunanKelimeSayisi = 0;
  String enUzunKelime = "";

  JokerMode currentJokerMode = JokerMode.none;
  int? swapFirstIndex;

  late List<List<Tile>> gridBoard;
  final Random _random = Random();
  late List<String> _letterPool;

  List<int> selectedIndices = [];
  String currentWord = "";

  Set<String> _sozluk = {};
  bool _sozlukYuklendiMi = false;

  final Map<String, int> _harfPuanlari = {
    'A': 1,
    'B': 3,
    'C': 4,
    'Ç': 4,
    'D': 3,
    'E': 1,
    'F': 7,
    'G': 5,
    'Ğ': 8,
    'H': 5,
    'I': 2,
    'İ': 1,
    'J': 10,
    'K': 1,
    'L': 1,
    'M': 2,
    'N': 1,
    'O': 2,
    'Ö': 7,
    'P': 5,
    'R': 1,
    'S': 2,
    'Ş': 4,
    'T': 1,
    'U': 2,
    'Ü': 3,
    'V': 7,
    'Y': 3,
    'Z': 4,
  };

  @override
  void initState() {
    super.initState();
    baslangicZamani = DateTime.now();
    currentMoves = widget.moveLimit;
    _havuzuOlustur();
    _gridiDoldur();
    _sozluguYukle();
  }

  Future<void> _sozluguYukle() async {
    try {
      String dosyaIcerigi = await rootBundle.loadString('assets/sozluk.txt');
      List<String> satirlar = dosyaIcerigi.split('\n');
      _sozluk = satirlar
          .map(
            (e) => e
                .trim()
                .replaceAll('i', 'İ')
                .replaceAll('ı', 'I')
                .toUpperCase(),
          )
          .where((e) => e.isNotEmpty)
          .toSet();
      setState(() {
        _sozlukYuklendiMi = true;
      });
      _gridiAnalizEtVeDuzelt();
    } catch (e) {
      print("Sözlük yüklenirken hata oluştu: $e");
    }
  }

  void _havuzuOlustur() {
    _letterPool = [];
    const highFreq = ['A', 'E', 'İ', 'L', 'R', 'N'];
    for (var letter in highFreq) {
      for (int i = 0; i < 6; i++) _letterPool.add(letter);
    }
    const medFreq = ['K', 'M', 'T', 'S', 'Y', 'D'];
    for (var letter in medFreq) {
      for (int i = 0; i < 3; i++) _letterPool.add(letter);
    }
    const lowFreq = ['J', 'Ğ', 'F', 'V'];
    for (var letter in lowFreq) _letterPool.add(letter);
    const otherFreq = [
      'B',
      'C',
      'Ç',
      'G',
      'H',
      'I',
      'O',
      'Ö',
      'P',
      'U',
      'Ü',
      'Z',
      'Ş',
    ];
    for (var letter in otherFreq) {
      for (int i = 0; i < 2; i++) _letterPool.add(letter);
    }
  }

  // --- YENİ TILE OLUŞTURUCU (Animasyon Kimliği için) ---
  Tile _createNewTile() {
    _tileIdCounter++;
    return Tile(id: "tile_$_tileIdCounter", letter: _rastgeleHarfCek());
  }

  void _gridiDoldur() {
    gridBoard = List.generate(
      widget.gridSize,
      (row) => List.generate(widget.gridSize, (col) => _createNewTile()),
    );
  }

  String _rastgeleHarfCek() {
    return _letterPool[_random.nextInt(_letterPool.length)];
  }

  bool _kelimeSozlukteVarMi(String kelime) {
    if (!_sozlukYuklendiMi) return false;
    return _sozluk.contains(
      kelime.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase(),
    );
  }

  int _puaniHesapla(String kelime) {
    int toplam = 0;
    for (int i = 0; i < kelime.length; i++) {
      toplam += _harfPuanlari[kelime[i]] ?? 0;
    }
    return toplam;
  }

  List<String> _altKelimeleriBul(String anaKelime) {
    List<String> bulunanlar = [];
    for (int i = 0; i < anaKelime.length; i++) {
      for (int j = i + 3; j <= anaKelime.length; j++) {
        String altParca = anaKelime.substring(i, j);
        if (_kelimeSozlukteVarMi(altParca) && !bulunanlar.contains(altParca)) {
          bulunanlar.add(altParca);
        }
      }
    }
    return bulunanlar;
  }

  List<int> _gucEtkiAlaniniBul(int r, int c, String guc) {
    List<int> etkilenenler = [];
    int s = widget.gridSize;
    if (guc == "row") {
      for (int i = 0; i < s; i++) etkilenenler.add(r * s + i);
    } else if (guc == "col") {
      for (int i = 0; i < s; i++) etkilenenler.add(i * s + c);
    } else if (guc == "bomb") {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int nr = r + i, nc = c + j;
          if (nr >= 0 && nr < s && nc >= 0 && nc < s)
            etkilenenler.add(nr * s + nc);
        }
      }
    } else if (guc == "mega") {
      for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
          int nr = r + i, nc = c + j;
          if (nr >= 0 && nr < s && nc >= 0 && nc < s)
            etkilenenler.add(nr * s + nc);
        }
      }
    }
    return etkilenenler;
  }

  int _ortakOlmayanKelimeSayisiniBul() {
    int s = widget.gridSize;
    List<List<int>> tumBulunanYollar = [];

    void dfs(int r, int c, String current, List<int> path) {
      if (current.length >= 3 && _kelimeSozlukteVarMi(current))
        tumBulunanYollar.add(List.from(path));
      if (current.length >= 5) return;

      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == 0 && j == 0) continue;
          int nr = r + i, nc = c + j;
          if (nr >= 0 && nr < s && nc >= 0 && nc < s) {
            int idx = nr * s + nc;
            if (!path.contains(idx)) {
              path.add(idx);
              dfs(nr, nc, current + gridBoard[nr][nc].letter, path);
              path.removeLast();
            }
          }
        }
      }
    }

    for (int i = 0; i < s; i++) {
      for (int j = 0; j < s; j++) {
        dfs(i, j, gridBoard[i][j].letter, [i * s + j]);
      }
    }

    tumBulunanYollar.sort((a, b) => b.length.compareTo(a.length));
    Set<int> kullanilanHarfler = {};
    int count = 0;

    for (var yol in tumBulunanYollar) {
      bool kesisimVar = false;
      for (int idx in yol) {
        if (kullanilanHarfler.contains(idx)) {
          kesisimVar = true;
          break;
        }
      }
      if (!kesisimVar) {
        count++;
        kullanilanHarfler.addAll(yol);
      }
    }
    return count;
  }

  void _gridiAnalizEtVeDuzelt() {
    if (!_sozlukYuklendiMi || _sozluk.isEmpty) return;
    int count = _ortakOlmayanKelimeSayisiniBul();
    if (count == 0) {
      _harfleriYenileGucKoru();
      count = _ortakOlmayanKelimeSayisiniBul();
      if (count == 0) {
        _garantiKelimeYerlestir();
        count = _ortakOlmayanKelimeSayisiniBul();
        if (count == 0) count = 1;
      }
    }
    setState(() {
      possibleWordCount = count;
    });
  }

  void _harfleriYenileGucKoru() {
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        // Güçleri koru, harfleri ve ID'yi yenile (Patlama efekti tetiklenir)
        String mevcutGuc = gridBoard[i][j].power;
        _tileIdCounter++;
        gridBoard[i][j] = Tile(
          id: "tile_$_tileIdCounter",
          letter: _rastgeleHarfCek(),
          power: mevcutGuc,
        );
      }
    }
  }

  void _garantiKelimeYerlestir() {
    List<String> uygunKelimeler = _sozluk
        .where((k) => k.length == 4 || k.length == 5)
        .toList();
    if (uygunKelimeler.isEmpty) return;
    String secilenKelime =
        uygunKelimeler[_random.nextInt(uygunKelimeler.length)];
    int r = _random.nextInt(widget.gridSize);
    int c = _random.nextInt(widget.gridSize);
    List<int> yol = [r * widget.gridSize + c];

    for (int i = 1; i < secilenKelime.length; i++) {
      List<int> komsular = [];
      int cr = yol.last ~/ widget.gridSize;
      int cc = yol.last % widget.gridSize;
      for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
          if (x == 0 && y == 0) continue;
          int nr = cr + x, nc = cc + y;
          int nidx = nr * widget.gridSize + nc;
          if (nr >= 0 &&
              nr < widget.gridSize &&
              nc >= 0 &&
              nc < widget.gridSize &&
              !yol.contains(nidx)) {
            komsular.add(nidx);
          }
        }
      }
      if (komsular.isNotEmpty) {
        komsular.shuffle(_random);
        yol.add(komsular.first);
      } else {
        break;
      }
    }
    for (int i = 0; i < yol.length; i++) {
      int idx = yol[i];
      int row = idx ~/ widget.gridSize;
      int col = idx % widget.gridSize;
      // ID yeniliyoruz ki animasyon oynasın
      _tileIdCounter++;
      gridBoard[row][col] = Tile(
        id: "tile_$_tileIdCounter",
        letter: secilenKelime[i],
        power: gridBoard[row][col].power,
      );
    }
  }

  // Animasyon sırasında ekrana dokunmayı kilitleyecek değişken (Sınıfın en üstünde, diğer değişkenlerin yanında da durabilir)
  bool _isExplodingAnimation = false;

  // --- YENİ EKLENEN GECİKMELİ PATLAMA FONKSİYONU ---
  Future<void> _belirliHarfleriYokEt(Set<int> yokEdilecekler) async {
    if (yokEdilecekler.isEmpty) return;

    // 1. Aşama: Harfleri "patlıyor" olarak işaretle ve ekrana yansıt (Kırmızı kutu & 💥)
    setState(() {
      _isExplodingAnimation = true;
      for (int idx in yokEdilecekler) {
        int r = idx ~/ widget.gridSize;
        int c = idx % widget.gridSize;
        gridBoard[r][c].isExploding = true;
      }
    });

    // 2. Aşama: Oyuncuya o muazzam patlamayı izlet (350 milisaniye bekliyoruz)
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // 3. Aşama: Patlama bitti, eski silme ve yerçekimi (aşağı kaydırma) işlemini çalıştır
    setState(() {
      _harfleriAsagiKaydir(yokEdilecekler);
      _isExplodingAnimation = false; // Kilidi kaldır, oyuncu hamle yapabilsin
    });
  }

  // --- SENİN ESKİ FONKSİYONUN (Sadece adını değiştirdik) ---
  void _harfleriAsagiKaydir(Set<int> yokEdilecekler) {
    for (int col = 0; col < widget.gridSize; col++) {
      List<Tile> kalanHarfler = [];
      for (int row = widget.gridSize - 1; row >= 0; row--) {
        int index = row * widget.gridSize + col;
        if (!yokEdilecekler.contains(index)) {
          // isExploding durumunu sıfırlayarak yeni listeye ekliyoruz
          gridBoard[row][col].isExploding = false;
          kalanHarfler.add(gridBoard[row][col]);
        }
      }
      int eksikSayisi = widget.gridSize - kalanHarfler.length;
      for (int k = 0; k < eksikSayisi; k++) {
        kalanHarfler.add(_createNewTile()); // Yeni ID'li kutular
      }
      for (int row = widget.gridSize - 1; row >= 0; row--) {
        gridBoard[row][col] = kalanHarfler[widget.gridSize - 1 - row];
      }
    }
    _gridiAnalizEtVeDuzelt();
  }

  void _patlatmaVeGucIslemleri() {
    Set<int> yokEdilecekler = {};
    List<int> islenecekler = List.from(selectedIndices);

    int i = 0;
    while (i < islenecekler.length) {
      int index = islenecekler[i];
      yokEdilecekler.add(index);
      int r = index ~/ widget.gridSize;
      int c = index % widget.gridSize;

      String guc = gridBoard[r][c].power;
      if (guc != "none") {
        List<int> etkilenenler = _gucEtkiAlaniniBul(r, c, guc);
        for (int etkiIndex in etkilenenler) {
          if (!yokEdilecekler.contains(etkiIndex) &&
              !islenecekler.contains(etkiIndex)) {
            islenecekler.add(etkiIndex);
          }
        }
      }
      i++;
    }

    int ekstraPuan = 0;
    for (int idx in yokEdilecekler) {
      if (!selectedIndices.contains(idx)) {
        int r = idx ~/ widget.gridSize;
        int c = idx % widget.gridSize;
        ekstraPuan += _harfPuanlari[gridBoard[r][c].letter] ?? 0;
      }
    }
    currentScore += ekstraPuan;

    int wordLen = currentWord.length;
    if (wordLen >= 4) {
      int sonIndex = selectedIndices.last;
      yokEdilecekler.remove(sonIndex);
      int r = sonIndex ~/ widget.gridSize;
      int c = sonIndex % widget.gridSize;
      if (wordLen == 4)
        gridBoard[r][c].power = "row";
      else if (wordLen == 5)
        gridBoard[r][c].power = "bomb";
      else if (wordLen == 6)
        gridBoard[r][c].power = "col";
      else if (wordLen >= 7)
        gridBoard[r][c].power = "mega";
    }

    _belirliHarfleriYokEt(yokEdilecekler);
  }

  void _skoruKaydet() {
    int sureMin = DateTime.now().difference(baslangicZamani).inMinutes;
    if (sureMin == 0) sureMin = 1;

    Globals.addGameRecord(
      GameRecord(
        id: Globals.gameHistory.length + 1,
        date:
            "${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}",
        grid: "${widget.gridSize}x${widget.gridSize}",
        score: currentScore,
        wordCount: bulunanKelimeSayisi,
        longestWord: enUzunKelime,
        durationMin: sureMin,
      ),
    );
  }

  void _oyunuBitir() {
    _skoruKaydet();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Oyun Bitti!"),
        content: Text(
          "Hamleleriniz tükendi.\n\nToplam Puan: $currentScore\nBulunan Kelime: $bulunanKelimeSayisi",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Ana Menüye Dön"),
          ),
        ],
      ),
    );
  }

  void _geriyeCikisSorgula() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış"),
        content: const Text("Oyundan çıkmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hayır"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _skoruKaydet();
              Navigator.pop(context);
            },
            child: const Text("Evet"),
          ),
        ],
      ),
    );
  }

  void _jokerBalik() {
    if (Globals.countBalik <= 0 || currentMoves <= 0) return;
    setState(() {
      Globals.countBalik--;
      Globals.saveData();
      Set<int> sansliHarfler = {};
      while (sansliHarfler.length < 5)
        sansliHarfler.add(_random.nextInt(widget.gridSize * widget.gridSize));
      _belirliHarfleriYokEt(sansliHarfler);
    });
  }

  void _jokerTekerlek() {
    if (Globals.countTekerlek <= 0 || currentMoves <= 0) return;
    setState(
      () => currentJokerMode = currentJokerMode == JokerMode.tekerlek
          ? JokerMode.none
          : JokerMode.tekerlek,
    );
  }

  void _jokerLolipop() {
    if (Globals.countLolipop <= 0 || currentMoves <= 0) return;
    setState(
      () => currentJokerMode = currentJokerMode == JokerMode.lolipop
          ? JokerMode.none
          : JokerMode.lolipop,
    );
  }

  void _jokerSerbestDegistirme() {
    if (Globals.countSerbest <= 0 || currentMoves <= 0) return;
    setState(
      () => currentJokerMode = currentJokerMode == JokerMode.swapFirst
          ? JokerMode.none
          : JokerMode.swapFirst,
    );
  }

  void _jokerKaristirma() {
    if (Globals.countKaristirma <= 0 || currentMoves <= 0) return;
    setState(() {
      Globals.countKaristirma--;
      Globals.saveData();
      List<Tile> tumHarfler = [];
      for (int i = 0; i < widget.gridSize; i++) {
        for (int j = 0; j < widget.gridSize; j++)
          tumHarfler.add(gridBoard[i][j]);
      }
      tumHarfler.shuffle(_random);
      int idx = 0;
      for (int i = 0; i < widget.gridSize; i++) {
        for (int j = 0; j < widget.gridSize; j++) {
          // Yeni ID vererek patlama efekti sağlıyoruz
          _tileIdCounter++;
          Tile t = tumHarfler[idx++];
          gridBoard[i][j] = Tile(
            id: "tile_$_tileIdCounter",
            letter: t.letter,
            power: t.power,
          );
        }
      }
      _gridiAnalizEtVeDuzelt();
    });
  }

  void _jokerParti() {
    if (Globals.countParti <= 0 || currentMoves <= 0) return;
    setState(() {
      Globals.countParti--;
      Globals.saveData();
      Set<int> tumu = {};
      for (int i = 0; i < widget.gridSize * widget.gridSize; i++) tumu.add(i);
      _belirliHarfleriYokEt(tumu);
    });
  }

  void _onPanStart(Offset localPosition, double gridWidth) {
    if (currentMoves <= 0 || _isExplodingAnimation) return;
    double spacing = 4.0;
    double totalSpacing = (widget.gridSize - 1) * spacing;
    double cellSize = (gridWidth - totalSpacing) / widget.gridSize;
    double cellTotalSize = cellSize + spacing;

    int col = ((localPosition.dx + (spacing / 2)) / cellTotalSize).floor();
    int row = ((localPosition.dy + (spacing / 2)) / cellTotalSize).floor();

    if (row >= 0 &&
        col >= 0 &&
        row < widget.gridSize &&
        col < widget.gridSize) {
      int index = row * widget.gridSize + col;

      if (currentJokerMode == JokerMode.lolipop) {
        setState(() {
          Globals.countLolipop--;
          Globals.saveData();
          currentJokerMode = JokerMode.none;
          _belirliHarfleriYokEt({index});
        });
        return;
      } else if (currentJokerMode == JokerMode.tekerlek) {
        setState(() {
          Globals.countTekerlek--;
          Globals.saveData();
          currentJokerMode = JokerMode.none;
          Set<int> yok = {};
          for (int i = 0; i < widget.gridSize; i++) {
            yok.add(row * widget.gridSize + i);
            yok.add(i * widget.gridSize + col);
          }
          _belirliHarfleriYokEt(yok);
        });
        return;
      } else if (currentJokerMode == JokerMode.swapFirst) {
        setState(() {
          swapFirstIndex = index;
          currentJokerMode = JokerMode.swapSecond;
        });
        return;
      } else if (currentJokerMode == JokerMode.swapSecond) {
        int r1 = swapFirstIndex! ~/ widget.gridSize;
        int c1 = swapFirstIndex! % widget.gridSize;
        if ((row - r1).abs() <= 1 &&
            (col - c1).abs() <= 1 &&
            swapFirstIndex != index) {
          setState(() {
            Globals.countSerbest--;
            Globals.saveData();
            currentJokerMode = JokerMode.none;
            Tile temp = gridBoard[r1][c1];
            gridBoard[r1][c1] = gridBoard[row][col];
            gridBoard[row][col] = temp;
            _gridiAnalizEtVeDuzelt();
          });
        } else {
          setState(() {
            currentJokerMode = JokerMode.none;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sadece temas eden harfleri değiştirebilirsin!'),
              ),
            );
          });
        }
        return;
      }

      setState(() {
        selectedIndices.clear();
        currentWord = "";
        selectedIndices.add(index);
        currentWord += gridBoard[row][col].letter;
      });
    }
  }

  void _onPanUpdate(Offset localPosition, double gridWidth) {
    if (currentMoves <= 0 ||
        currentJokerMode != JokerMode.none ||
        _isExplodingAnimation)
      return;
    double spacing = 4.0;
    double totalSpacing = (widget.gridSize - 1) * spacing;
    double cellSize = (gridWidth - totalSpacing) / widget.gridSize;
    double cellTotalSize = cellSize + spacing;

    int col = ((localPosition.dx + (spacing / 2)) / cellTotalSize).floor();
    int row = ((localPosition.dy + (spacing / 2)) / cellTotalSize).floor();

    if (row >= 0 &&
        col >= 0 &&
        row < widget.gridSize &&
        col < widget.gridSize) {
      int index = row * widget.gridSize + col;
      if (selectedIndices.isNotEmpty && !selectedIndices.contains(index)) {
        int lastIndex = selectedIndices.last;
        int lastRow = lastIndex ~/ widget.gridSize;
        int lastCol = lastIndex % widget.gridSize;

        if ((row - lastRow).abs() <= 1 && (col - lastCol).abs() <= 1) {
          setState(() {
            selectedIndices.add(index);
            currentWord += gridBoard[row][col].letter;
          });
        }
      }
    }
  }

  void _onPanEnd() {
    if (selectedIndices.isEmpty || currentJokerMode != JokerMode.none) return;

    setState(() {
      currentMoves--;

      if (currentWord.length >= 3) {
        if (_kelimeSozlukteVarMi(currentWord)) {
          List<String> tumKelimeler = _altKelimeleriBul(currentWord);
          bulunanKelimeSayisi += tumKelimeler.length;
          for (String k in tumKelimeler) {
            if (k.length > enUzunKelime.length) enUzunKelime = k;
          }

          int comboSayisi = tumKelimeler.length;
          int toplamKazanilanPuan = 0;
          for (String kelime in tumKelimeler)
            toplamKazanilanPuan += _puaniHesapla(kelime);

          currentScore += toplamKazanilanPuan;
          _patlatmaVeGucIslemleri();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                comboSayisi > 1
                    ? 'Müthiş! $comboSayisi x Combo! +$toplamKazanilanPuan Puan'
                    : 'Tebrikler! +$toplamKazanilanPuan Puan',
              ),
              backgroundColor: comboSayisi > 1 ? Colors.orange : Colors.green,
              duration: const Duration(milliseconds: 1000),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sözlükte bulunamadı! Hamle gitti.'),
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 800),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçersiz! En az 3 harf seçmelisin.'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 800),
          ),
        );
      }

      selectedIndices.clear();
      currentWord = "";

      if (currentMoves <= 0) {
        Future.delayed(const Duration(milliseconds: 1000), _oyunuBitir);
      }
    });
  }

  Widget _buildPowerIcon(String power) {
    IconData iconData;
    Color color;
    switch (power) {
      case "row":
        iconData = Icons.swap_horiz;
        color = Colors.yellowAccent;
        break;
      case "col":
        iconData = Icons.swap_vert;
        color = Colors.yellowAccent;
        break;
      case "bomb":
        iconData = Icons.local_fire_department;
        color = Colors.redAccent;
        break;
      case "mega":
        iconData = Icons.flash_on;
        color = Colors.cyanAccent;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87, // Arka plan koyuluğu korundu
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      padding: const EdgeInsets.all(3), // Boşluğu kıstık
      child: Icon(
        iconData,
        size: 14,
        color: color,
      ), // Boyutu küçülttük, köşeye tam oturacak!
    );
  }

  Widget _buildJokerButton(
    IconData icon,
    String label,
    int count,
    VoidCallback onTap,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: count > 0 ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.redAccent
                    : (count > 0 ? Colors.deepPurple : Colors.grey),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 2),
            Text(
              "$label\n($count)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: count > 0 ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridPadding = 24.0;
    double gridWidth = screenWidth - gridPadding;

    String durumMesaji = currentWord.isEmpty ? "Kelime Seçin..." : currentWord;
    if (currentJokerMode == JokerMode.lolipop)
      durumMesaji = "Kırılacak Harfi Seç!";
    if (currentJokerMode == JokerMode.tekerlek)
      durumMesaji = "Satır/Sütun Seç!";
    if (currentJokerMode == JokerMode.swapFirst)
      durumMesaji = "Değişecek 1. Harf!";
    if (currentJokerMode == JokerMode.swapSecond)
      durumMesaji = "Değişecek 2. Harf!";

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _geriyeCikisSorgula();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: Text("${widget.gridSize}x${widget.gridSize} Kelime Avı"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _geriyeCikisSorgula,
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Gridde Oluşturulabilir Kelime Sayısı: $possibleWordCount",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "KALAN HAMLE",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$currentMoves",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: currentMoves < 5
                                  ? Colors.red
                                  : Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "ANLIK PUAN",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$currentScore",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      durumMesaji,
                      style: TextStyle(
                        fontSize:
                            currentWord.isEmpty &&
                                currentJokerMode == JokerMode.none
                            ? 20
                            : 28,
                        fontWeight: FontWeight.bold,
                        color: currentJokerMode != JokerMode.none
                            ? Colors.red
                            : (currentWord.isEmpty
                                  ? Colors.grey.shade400
                                  : Colors.orange),
                        letterSpacing:
                            currentWord.isEmpty &&
                                currentJokerMode == JokerMode.none
                            ? 0
                            : 4.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onPanStart: (details) =>
                      _onPanStart(details.localPosition, gridWidth),
                  onPanUpdate: (details) =>
                      _onPanUpdate(details.localPosition, gridWidth),
                  onPanEnd: (details) => _onPanEnd(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: currentJokerMode != JokerMode.none
                          ? Border.all(color: Colors.redAccent, width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.gridSize * widget.gridSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.gridSize,
                        childAspectRatio: 1.05,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemBuilder: (context, index) {
                        int row = index ~/ widget.gridSize;
                        int col = index % widget.gridSize;
                        Tile tile = gridBoard[row][col];

                        bool isSelected = selectedIndices.contains(index);
                        if (currentJokerMode == JokerMode.swapSecond &&
                            swapFirstIndex == index) {
                          isSelected = true;
                        }

                        // STACK ARTIK EN DIŞTA! (Taşmaya izin veriyor ve kırpmayı engelliyor)
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // --- 1. KATMAN: NORMAL KUTU VEYA ŞOK DALGASI (Şov Kısmı) ---
                            tile.isExploding
                                ? TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 350),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale:
                                            1.0 +
                                            value, // Kutu büyüyerek patlıyor
                                        child: Opacity(
                                          opacity:
                                              1.0 -
                                              value, // Giderek silikleşiyor (Duman efekti)
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(
                                                8 + (value * 20),
                                              ), // Köşeler yuvarlaklaşıp dağılıyor
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.orange
                                                      .withOpacity(1.0 - value),
                                                  blurRadius: 15 * value,
                                                  spreadRadius: 5 * value,
                                                ),
                                              ],
                                            ),
                                            child: Transform.rotate(
                                              angle:
                                                  value *
                                                  3.14, // Ekseni etrafında dönerek yok oluyor
                                              child: const Text(
                                                "💥",
                                                style: TextStyle(fontSize: 32),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: Alignment
                                        .center, // Harfi merkeze sabitler
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.orange.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            )
                                          : null,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(2, 2),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      transitionBuilder:
                                          (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            return ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            );
                                          },
                                      child: Text(
                                        tile.letter,
                                        key: ValueKey(tile.id),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                            // --- 2. KATMAN: KÖŞEYE İLİŞTİRİLMİŞ ROZET (SİMGE) ---
                            if (tile.power != "none")
                              Positioned(
                                top: -6, // Kutunun üstünden hafifçe taşırır
                                right: -6, // Kutunun sağından hafifçe taşırır
                                child: _buildPowerIcon(tile.power),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 85,
              padding: const EdgeInsets.symmetric(vertical: 5),
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildJokerButton(
                    Icons.set_meal,
                    "Balık",
                    Globals.countBalik,
                    _jokerBalik,
                    false,
                  ),
                  _buildJokerButton(
                    Icons.settings,
                    "Tekerlek",
                    Globals.countTekerlek,
                    _jokerTekerlek,
                    currentJokerMode == JokerMode.tekerlek,
                  ),
                  _buildJokerButton(
                    Icons.hardware,
                    "Lolipop",
                    Globals.countLolipop,
                    _jokerLolipop,
                    currentJokerMode == JokerMode.lolipop,
                  ),
                  _buildJokerButton(
                    Icons.swap_horiz,
                    "Değiştir",
                    Globals.countSerbest,
                    _jokerSerbestDegistirme,
                    currentJokerMode == JokerMode.swapFirst ||
                        currentJokerMode == JokerMode.swapSecond,
                  ),
                  _buildJokerButton(
                    Icons.shuffle,
                    "Karıştır",
                    Globals.countKaristirma,
                    _jokerKaristirma,
                    false,
                  ),
                  _buildJokerButton(
                    Icons.celebration,
                    "Parti",
                    Globals.countParti,
                    _jokerParti,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
