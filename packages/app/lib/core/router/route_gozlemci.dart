// Tek, uygulama genelinde paylaşılan RouteObserver. Ekranlar (örn.
// FirmalarEkrani) bunu dinleyerek "üzerine açılan bir sayfa kapatılıp bana
// geri dönüldü" anını (didPopNext) yakalayıp listelerini tazeleyebilir.
// Neden tek/global bir örnek: GoRouter'ın `observers` listesine VE ekranın
// `RouteObserver.subscribe`ına AYNI nesne verilmeli, yoksa ikisi birbirini
// hiç görmez.

import 'package:flutter/material.dart';

final RouteObserver<PageRoute<dynamic>> routeGozlemci =
    RouteObserver<PageRoute<dynamic>>();
