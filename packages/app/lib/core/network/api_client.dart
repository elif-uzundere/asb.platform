// Kaynak: eski Expo src/core/api/client.ts (axios instance) + (silindi — bkz. izlence Ek A)
// auth.store.ts sonundaki request interceptor'ın karşılığı.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/auth_depo.dart';

/// Backend geliştirme adresi. Tüm endpoint'ler /api/v1 altında (setGlobalPrefix + versioning).
const String apiTabanAdresi = 'http://localhost:3000/api/v1';

Dio apiClientOlustur(AuthDepo authDepo) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiTabanAdresi,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (secenekler, isleyici) async {
        final token = await authDepo.tokenOku();
        if (token != null && token.isNotEmpty) {
          secenekler.headers['Authorization'] = 'Bearer $token';
        }
        isleyici.next(secenekler);
      },
    ),
  );

  return dio;
}

final apiClientProvider =
    Provider<Dio>((ref) => apiClientOlustur(ref.watch(authDepoProvider)));
