// 401 yanıtlarını Dio interceptor'ından (api_client.dart) uygulama köküne
// (main.dart) taşıyan basit event bus.
//
// Neden Riverpod provider'ı DEĞİL: apiClientProvider zaten
// authApiProvider -> apiClientProvider zincirinde authProvider'a
// bağımlı (authApiProvider onu watch ediyor). İnterceptor buradan
// authProvider'ı okumaya/watch etmeye çalışsa apiClientProvider ->
// authProvider -> authApiProvider -> apiClientProvider döngüsü oluşurdu.
// yonlendirici.dart'taki `tetikleyici` ValueNotifier'ı da aynı sebeple
// Riverpod grafiğinin dışında tutuluyor — burada aynı desen tekrarlandı.
import 'dart:async';

final StreamController<void> yetkisizIstekAkisi =
    StreamController<void>.broadcast();
