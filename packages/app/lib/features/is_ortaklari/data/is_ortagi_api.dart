import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/is_ortagi_modeli.dart';

class IsOrtagiApi {
  IsOrtagiApi({
    required this.baseUrl,
  });

  final String baseUrl;

  Future<List<IsOrtagiModeli>> tumunuGetir() async {
    final uri = Uri.parse(
      '$baseUrl/api/v1/is-ortaklari',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'İş ortakları alınamadı. Kod: ${response.statusCode}',
      );
    }

    final jsonBody = jsonDecode(response.body)
        as Map<String, dynamic>;

    final data = jsonBody['data'] as List<dynamic>;

    return data
        .map(
          (item) => IsOrtagiModeli.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}