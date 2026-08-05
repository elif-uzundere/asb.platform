// Google giriş düğmesi PLATFORMA GÖRE farklı bir şey — web'de Google
// Identity Services kendi düğmesinin tıklanmasını zorunlu kılıyor
// (programatik tetikleme yasak, tarayıcı güvenlik kısıtı), mobilde ise
// bizim kendi stilimizdeki dairesel butonla `authenticate()` çağrılabiliyor.
//
// Bu koşullu export, `dart.library.js_interop` sadece web derlemesinde
// mevcut olduğu için doğru dosyayı DERLEME ZAMANINDA seçiyor — ikisi de
// aynı `GoogleGirisDugmesi` adını, aynı imzayla dışa veriyor.
export 'google_giris_dugmesi_mobil.dart'
    if (dart.library.js_interop) 'google_giris_dugmesi_web.dart';
