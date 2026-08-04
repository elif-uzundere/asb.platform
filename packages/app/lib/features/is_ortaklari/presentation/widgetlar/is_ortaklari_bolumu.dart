import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/is_ortagi_api.dart';
import '../../domain/is_ortagi_modeli.dart';
import 'is_ortagi_karti.dart';

class IsOrtaklariBolumu extends StatefulWidget {
  const IsOrtaklariBolumu({super.key});

  @override
  State<IsOrtaklariBolumu> createState() =>
      _IsOrtaklariBolumuState();
}

class _IsOrtaklariBolumuState extends State<IsOrtaklariBolumu> {
  final ScrollController _scrollController = ScrollController();

  final IsOrtagiApi _isOrtagiApi = IsOrtagiApi(
    baseUrl: 'http://localhost:3000',
  );

  late Future<List<IsOrtagiModeli>> _isOrtaklariGelecegi;

  @override
  void initState() {
    super.initState();

    _isOrtaklariGelecegi = _isOrtagiApi.tumunuGetir();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _yenidenYukle() {
    setState(() {
      _isOrtaklariGelecegi = _isOrtagiApi.tumunuGetir();
    });
  }

  void _sagaKaydir() {
    if (!_scrollController.hasClients) {
      return;
    }

    final yeniKonum = _scrollController.offset + 320;

    _scrollController.animateTo(
      yeniKonum.clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _solaKaydir() {
    if (!_scrollController.hasClients) {
      return;
    }

    final yeniKonum = _scrollController.offset - 320;

    _scrollController.animateTo(
      yeniKonum.clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'DIŞ TEDARİKÇİ VE HİZMETLER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/is-ortaklari');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tümünü Gör'),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: FutureBuilder<List<IsOrtagiModeli>>(
              future: _isOrtaklariGelecegi,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'İş ortakları yüklenemedi.',
                        ),
                        const SizedBox(height: 8),
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

                return Stack(
                  children: [
                    Positioned.fill(
                      child: ScrollConfiguration(
                        behavior:
                            const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: ListView.separated(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics:
                              const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          itemCount: isOrtaklari.length,
                          separatorBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            return const SizedBox(
                              width: 12,
                            );
                          },
                          itemBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            final isOrtagi =
                                isOrtaklari[index];

                            return IsOrtagiKarti(
                              isOrtagi: isOrtagi,
                              onTap: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${isOrtagi.ad} seçildi',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _KaydirmaButonu(
                        ikon:
                            Icons.chevron_left_rounded,
                        onPressed: _solaKaydir,
                        arkaPlanRengi:
                            renkler.surface.withValues(
                          alpha: 0.90,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _KaydirmaButonu(
                        ikon:
                            Icons.chevron_right_rounded,
                        onPressed: _sagaKaydir,
                        arkaPlanRengi:
                            renkler.surface.withValues(
                          alpha: 0.90,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KaydirmaButonu extends StatelessWidget {
  const _KaydirmaButonu({
    required this.ikon,
    required this.onPressed,
    required this.arkaPlanRengi,
  });

  final IconData ikon;
  final VoidCallback onPressed;
  final Color arkaPlanRengi;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: arkaPlanRengi,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(ikon),
        tooltip: 'Kaydır',
      ),
    );
  }
}