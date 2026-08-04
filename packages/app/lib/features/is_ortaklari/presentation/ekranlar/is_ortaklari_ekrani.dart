import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/is_ortagi_api.dart';
import '../../domain/is_ortagi_modeli.dart';
import '../widgetlar/is_ortagi_karti.dart';

class IsOrtaklariEkrani extends StatefulWidget {
  const IsOrtaklariEkrani({super.key});

  @override
  State<IsOrtaklariEkrani> createState() =>
      _IsOrtaklariEkraniState();
}

class _IsOrtaklariEkraniState
    extends State<IsOrtaklariEkrani> {
  final IsOrtagiApi _isOrtagiApi = IsOrtagiApi(
    baseUrl: 'http://localhost:3000',
  );

  late Future<List<IsOrtagiModeli>> _isOrtaklariGelecegi;

  @override
  void initState() {
    super.initState();

    _isOrtaklariGelecegi =
        _isOrtagiApi.tumunuGetir();
  }

  void _yenidenYukle() {
    setState(() {
      _isOrtaklariGelecegi =
          _isOrtagiApi.tumunuGetir();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          tooltip: 'Geri',
        ),
        title: const Text(
          'Dış Tedarikçi ve Hizmetler',
        ),
      ),
      body: FutureBuilder<List<IsOrtagiModeli>>(
        future: _isOrtaklariGelecegi,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<IsOrtagiModeli>> snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'İş ortakları yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _yenidenYukle,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'Tekrar dene',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final isOrtaklari =
              snapshot.data ?? <IsOrtagiModeli>[];

          if (isOrtaklari.isEmpty) {
            return const Center(
              child: Text(
                'Henüz iş ortağı bulunmuyor.',
              ),
            );
          }

          return LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final double ekranGenisligi =
                  constraints.maxWidth;

              final int sutunSayisi;

              if (ekranGenisligi >= 1100) {
                sutunSayisi = 5;
              } else if (ekranGenisligi >= 800) {
                sutunSayisi = 4;
              } else if (ekranGenisligi >= 550) {
                sutunSayisi = 3;
              } else {
                sutunSayisi = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: isOrtaklari.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: sutunSayisi,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150,
                ),
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  final isOrtagi =
                      isOrtaklari[index];

                  return IsOrtagiKarti(
                    isOrtagi: isOrtagi,
                    genislik: double.infinity,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${isOrtagi.ad} seçildi',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}