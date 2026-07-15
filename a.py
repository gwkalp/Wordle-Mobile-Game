import urllib.request

# Çalışan güncel Türkçe kelime listesi linki
url = "https://raw.githubusercontent.com/mertemin/turkish-word-list/master/words.txt"
print("Kelime listesi indiriliyor, lütfen bekleyin...")

try:
    # İnternetten dosyayı okuyoruz
    response = urllib.request.urlopen(url)
    kelimeler = response.read().decode('utf-8').splitlines()

    temiz_sozluk = set()

    # Türkçe karakter uyumu için özel çeviri tablosu
    tr_upper = str.maketrans("abcçdefgğhıijklmnoöprsştuüvyz", "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ")

    print("Kelimeler ayıklanıyor ve kurala (minimum 3 harf) uygun hale getiriliyor...")
    for kelime in kelimeler:
        k = kelime.strip().translate(tr_upper)
        # Proje kuralı: En az 3 harfli olmalı ve boşluk içermemeli
        if len(k) >= 3 and " " not in k:
            temiz_sozluk.add(k)

    # Dosyayı projenin assets klasörüne uygun şekilde kaydet
    with open("sozluk.txt", "w", encoding="utf-8") as f:
        for k in sorted(temiz_sozluk):
            f.write(k + "\n")

    print(f"Harika! İşlem tamamlandı. Tam {len(temiz_sozluk)} adet kelime 'sozluk.txt' dosyasına kaydedildi.")

except Exception as e:
    print(f"Bir hata oluştu. İnternet bağlantınızı kontrol edin. Hata detayı: {e}")