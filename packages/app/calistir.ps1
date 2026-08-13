# Windows'a özgü bilinen bir Flutter SDK hatası için otomatik hazırlık scripti.
#
# NEDEN GEREKLİ: Flutter'ın iOS Swift Package Manager şablonlama kodu
# "ios/Flutter/ephemeral/Packages/.packages" klasörünü salt-okunur (ReadOnly)
# olarak oluşturuyor. Flutter'ın kendi silme kodu (Windows'ta) salt-okunur
# reparse point'leri temizleyemiyor, bu yüzden bir SONRAKİ `flutter run`
# komutu "failed to delete a directory" hatasıyla patlıyor. Bu proje sadece
# web (Chrome) hedefli çalıştığı ve Windows'ta zaten iOS derlemesi mümkün
# olmadığı için, bu klasörü her çalıştırmadan önce temizlemek güvenli ve
# kalıcı bir çözüm — `flutter config --no-enable-swift-package-manager` TEK
# BAŞINA yetmiyor (denendi, sorunu çözmedi), bu yüzden bu script gerekli.
#
# KULLANIM: packages/app içinden  ->  .\calistir.ps1
#           farklı bir port için  ->  .\calistir.ps1 -Device chrome -Port 5001
#
# Port VARSAYILAN OLARAK 5000 — rastgele porta düşülmesin diye bilerek sabit.
# Google Cloud Console'daki Web OAuth Client'ın "Authorized JavaScript
# origins" listesi sadece http://localhost:5000'i tanıyor; farklı bir portta
# açılırsa Google Sign-In "origin_mismatch" hatası verir (06.08.2026'da
# yaşandı). Gerçekten farklı bir port gerekiyorsa Google Cloud Console'a o
# origin de eklenmeli.

param(
    [string]$Device = "chrome",
    [int]$Port = 5000
)

$kilitliKlasorler = @(
    "ios\Flutter\ephemeral",
    "build\flutter_assets"
)

foreach ($klasor in $kilitliKlasorler) {
    if (Test-Path $klasor) {
        Remove-Item -Recurse -Force $klasor -ErrorAction SilentlyContinue
    }
}

if ($Port -gt 0) {
    flutter run -d $Device --web-port $Port
} else {
    flutter run -d $Device
}
