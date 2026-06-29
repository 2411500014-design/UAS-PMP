import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'form_page.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final int boxIndex;

  const DetailPage({
    super.key,
    required this.data,
    required this.boxIndex,
  });

  Color _tipeColor(String tipe) {
    switch (tipe) {
      case 'Manhwa':
        return AppTheme.manhwaColor;
      case 'Manga':
        return AppTheme.mangaColor;
      case 'Manhua':
        return AppTheme.manhuaColor;
      default:
        return AppTheme.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return AppTheme.ongoing;
      case 'Completed':
        return AppTheme.completed;
      case 'Hiatus':
        return AppTheme.hiatus;
      default:
        return AppTheme.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tipe    = data['tipe']    ?? '';
    final String status  = data['status']  ?? '';
    final String judul   = data['judul']   ?? '';
    final String genre   = data['genre']   ?? '';
    final String sinopsis = data['sinopsis'] ?? '-';
    final double rating  =
        double.tryParse(data['rating'].toString()) ?? 0.0;
    final int chapter    =
        int.tryParse(data['chapter'].toString()) ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar dengan cover ─────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.greenDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppTheme.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.white),
                tooltip: 'Edit',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormPage(
                        existingData: data,
                        boxIndex: boxIndex,
                      ),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.greenDark,
                      _tipeColor(tipe).withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Cover icon besar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd),
                          border: Border.all(
                              color: AppTheme.white.withOpacity(0.35),
                              width: 1.5),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 40,
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Judul + Chips ───────────────────────
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.black,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(tipe, _tipeColor(tipe)),
                      _chip(status, _statusColor(status)),
                      ...genre.split(',').map(
                            (g) => _chip(
                              g.trim(),
                              AppTheme.green.withOpacity(0.8),
                            ),
                          ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Stats row ───────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFFFC107),
                          label: 'Rating',
                          value: rating.toStringAsFixed(1),
                        ),
                        _divider(),
                        _statItem(
                          icon: Icons.bookmarks_rounded,
                          iconColor: AppTheme.green,
                          label: 'Chapter',
                          value: chapter.toString(),
                        ),
                        _divider(),
                        _statItem(
                          icon: Icons.category_rounded,
                          iconColor: _tipeColor(tipe),
                          label: 'Tipe',
                          value: tipe,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sinopsis ────────────────────────────
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.greenDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Text(
                      sinopsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.blackMid,
                        height: 1.65,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.85),
        ),
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.grey),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.greyLight,
    );
  }
}
