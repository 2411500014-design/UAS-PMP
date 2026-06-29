import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_theme.dart';
import 'form_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('komikBox');

  String _searchQuery = '';
  String _filterTipe = 'Semua'; // Semua / Manhwa / Manga / Manhua

  List<Map<String, dynamic>> get _filteredData {
    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw != null) {
        result.add(Map<String, dynamic>.from(raw));
      }
    }

    // Filter tipe
    if (_filterTipe != 'Semua') {
      result = result
          .where((d) => d['tipe'] == _filterTipe)
          .toList();
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((d) =>
              d['judul']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              d['genre']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  void _hapusData(int boxIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: const Text(
          'Hapus Data',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: AppTheme.black),
        ),
        content: const Text(
          'Yakin ingin menghapus data ini?',
          style: TextStyle(color: AppTheme.blackMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              box.deleteAt(boxIndex);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data berhasil dihapus'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: AppTheme.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSm)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

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

  // Dapatkan index asli di box dari data yang sudah difilter
  int _getBoxIndex(Map<String, dynamic> item) {
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw != null) {
        final d = Map<String, dynamic>.from(raw);
        if (d['judul'] == item['judul'] &&
            d['tipe'] == item['tipe'] &&
            d['genre'] == item['genre']) {
          return i;
        }
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,

      // ── AppBar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.greenDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded,
                color: AppTheme.white, size: 22),
            const SizedBox(width: 8),
            const Text(
              'MangaKu',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (_, __, ___) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: Text(
                  '${box.length} judul',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Search & Filter Header ────────────────────────────
          Container(
            color: AppTheme.greenDark,
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.black),
                    decoration: InputDecoration(
                      hintText: 'Cari judul atau genre...',
                      hintStyle: const TextStyle(
                          color: AppTheme.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter chips
                Row(
                  children: ['Semua', 'Manhwa', 'Manga', 'Manhua']
                      .map((tipe) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _filterTipe = tipe),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _filterTipe == tipe
                                      ? AppTheme.white
                                      : AppTheme.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXl),
                                ),
                                child: Text(
                                  tipe,
                                  style: TextStyle(
                                    color: _filterTipe == tipe
                                        ? AppTheme.greenDark
                                        : AppTheme.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // ── List Body ─────────────────────────────────────────
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, value, child) {
                final data = _filteredData;

                if (data.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final boxIndex = _getBoxIndex(item);
                    return _buildKomikCard(item, boxIndex);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FormPage(),
            ),
          );
          setState(() {});
        },
        backgroundColor: AppTheme.greenDark,
        foregroundColor: AppTheme.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Empty state widget ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.greenLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 44,
              color: AppTheme.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterTipe != 'Semua'
                ? 'Tidak ada hasil ditemukan'
                : 'Belum ada data komik',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackMid,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty || _filterTipe != 'Semua'
                ? 'Coba kata kunci atau filter lain'
                : 'Tekan tombol + untuk menambahkan',
            style: const TextStyle(fontSize: 13, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }

  // ── Komik card widget ──────────────────────────────────────
  Widget _buildKomikCard(Map<String, dynamic> item, int boxIndex) {
    final String tipe = item['tipe'] ?? '';
    final String status = item['status'] ?? '';
    final double rating =
        double.tryParse(item['rating'].toString()) ?? 0.0;
    final String chapter = item['chapter']?.toString() ?? '0';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(data: item, boxIndex: boxIndex),
        ),
      ).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover placeholder ───────────────────────
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: _tipeColor(tipe).withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                      color: _tipeColor(tipe).withOpacity(0.3),
                      width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        color: _tipeColor(tipe), size: 24),
                    const SizedBox(height: 4),
                    Text(
                      tipe.isNotEmpty
                          ? tipe.substring(0, 2).toUpperCase()
                          : '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _tipeColor(tipe),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Info ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      item['judul'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Genre
                    Text(
                      item['genre'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Tipe + Status chips
                    Row(
                      children: [
                        _buildChip(tipe, _tipeColor(tipe)),
                        const SizedBox(width: 6),
                        _buildChip(status, _statusColor(status)),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Rating + Chapter
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.bookmarks_outlined,
                            color: AppTheme.grey, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          'Ch. $chapter',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Action buttons ───────────────────────────
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormPage(
                            existingData: item,
                            boxIndex: boxIndex,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit_outlined,
                        color: AppTheme.green, size: 20),
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    onPressed: () => _hapusData(boxIndex),
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red.shade400, size: 20),
                    tooltip: 'Hapus',
                    constraints: const BoxConstraints(
                        minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
