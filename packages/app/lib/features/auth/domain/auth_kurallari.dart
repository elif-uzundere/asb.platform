// Auth modülünün framework'ten bağımsız, saf kuralları.
// Burada Flutter/dio/Riverpod import'u YOK — backend'deki `domain` katmanının
// karşılığı (bkz. docs/CLAUDE.md, Mimari Kuralları md. 2).

/// E-postadaki sıfırlama linkinden gelen token kullanılabilir mi?
/// Ekran bu kararı `if (token != null && token.isNotEmpty)` diye kendi
/// hesaplamaz; kural tek yerde durur.
bool sifirlamaTokeniGecerli(String? token) =>
    token != null && token.trim().isNotEmpty;

/// Kullanıcının girdiği serbest metni istekte kullanılacak hâle getirir
/// (baştaki/sondaki boşluklar kullanıcı hatasıdır, sunucuya taşınmaz).
String girdiyiTemizle(String ham) => ham.trim();

/// Opsiyonel alanlar için: boş girdi "gönderilmedi" demektir.
String? opsiyonelGirdi(String ham) {
  final temiz = ham.trim();
  return temiz.isEmpty ? null : temiz;
}
