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
#           farklı bir hedef için ->  .\calistir.ps1 -Device chrome -Port 5000

param(
    [string]$Device = "chrome",
    [int]$Port = 0
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
