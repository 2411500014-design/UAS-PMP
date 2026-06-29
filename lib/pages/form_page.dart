import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_theme.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final int? boxIndex;

  const FormPage({super.key, this.existingData, this.boxIndex});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final box = Hive.box('komikBox');

  // Controllers
  final _judulController    = TextEditingController();
  final _genreController    = TextEditingController();
  final _chapterController  = TextEditingController();
  final _ratingController   = TextEditingController();
  final _sinopsisController = TextEditingController();

  String _selectedTipe   = 'Manhwa';
  String _selectedStatus = 'Ongoing';

  bool get isEdit => widget.existingData != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final d = widget.existingData!;
      _judulController.text    = d['judul']    ?? '';
      _genreController.text    = d['genre']    ?? '';
      _chapterController.text  = d['chapter']?.toString() ?? '';
      _ratingController.text   = d['rating']?.toString()  ?? '';
      _sinopsisController.text = d['sinopsis'] ?? '';
      _selectedTipe   = d['tipe']   ?? 'Manhwa';
      _selectedStatus = d['status'] ?? 'Ongoing';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _genreController.dispose();
    _chapterController.dispose();
    _ratingController.dispose();
    _sinopsisController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'judul':    _judulController.text.trim(),
      'tipe':     _selectedTipe,
      'genre':    _genreController.text.trim(),
      'status':   _selectedStatus,
      'chapter':  int.tryParse(_chapterController.text.trim()) ?? 0,
      'rating':   double.tryParse(_ratingController.text.trim()) ?? 0.0,
      'sinopsis': _sinopsisController.text.trim(),
    };

    if (isEdit) {
      box.putAt(widget.boxIndex!, data);
    } else {
      box.add(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Data berhasil diperbarui' : 'Data berhasil ditambahkan'),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.greenDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Data Komik' : 'Tambah Komik Baru',
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Informasi Utama ──────────────────
              _buildSectionHeader('Informasi Utama', Icons.info_outline),
              const SizedBox(height: 12),

              _buildCard(
                child: Column(
                  children: [
                    // Judul
                    _buildTextFormField(
                      controller: _judulController,
                      label: 'Judul',
                      hint: 'Contoh: Solo Leveling',
                      icon: Icons.title,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Tipe (Manhwa / Manga / Manhua)
                    _buildLabel('Tipe', Icons.category_outlined),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Manhwa', 'Manga', 'Manhua'].map((tipe) {
                        Color tipeColor;
                        switch (tipe) {
                          case 'Manhwa':
                            tipeColor = AppTheme.manhwaColor;
                            break;
                          case 'Manga':
                            tipeColor = AppTheme.mangaColor;
                            break;
                          default:
                            tipeColor = AppTheme.manhuaColor;
                        }
                        final selected = _selectedTipe == tipe;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTipe = tipe),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin:
                                  const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? tipeColor
                                    : tipeColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSm),
                                border: Border.all(
                                  color: selected
                                      ? tipeColor
                                      : tipeColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                tipe,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppTheme.white
                                      : tipeColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Genre
                    _buildTextFormField(
                      controller: _genreController,
                      label: 'Genre',
                      hint: 'Contoh: Action, Fantasy, Romance',
                      icon: Icons.label_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Genre tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section: Detail & Status ──────────────────
              _buildSectionHeader('Detail & Status', Icons.bar_chart),
              const SizedBox(height: 12),

              _buildCard(
                child: Column(
                  children: [
                    // Status
                    _buildLabel('Status', Icons.radio_button_checked_outlined),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusOption('Ongoing', AppTheme.ongoing),
                        const SizedBox(width: 8),
                        _buildStatusOption('Completed', AppTheme.completed),
                        const SizedBox(width: 8),
                        _buildStatusOption('Hiatus', AppTheme.hiatus),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Chapter & Rating (side by side)
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _chapterController,
                            label: 'Total Chapter',
                            hint: '0',
                            icon: Icons.bookmarks_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _ratingController,
                            label: 'Rating (0–10)',
                            hint: '8.5',
                            icon: Icons.star_outline,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              final d = double.tryParse(v.trim());
                              if (d == null || d < 0 || d > 10) {
                                return 'Masukkan 0–10';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section: Sinopsis ─────────────────────────
              _buildSectionHeader('Sinopsis', Icons.article_outlined),
              const SizedBox(height: 12),

              _buildCard(
                child: TextFormField(
                  controller: _sinopsisController,
                  maxLines: 5,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.black),
                  decoration: InputDecoration(
                    hintText: 'Tulis sinopsis singkat cerita...',
                    hintStyle: const TextStyle(
                        color: AppTheme.grey, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                      borderSide:
                          BorderSide(color: AppTheme.greyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                      borderSide:
                          BorderSide(color: AppTheme.greyLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                      borderSide: const BorderSide(
                          color: AppTheme.green, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Sinopsis tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // ── Tombol Simpan ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: Icon(
                      isEdit ? Icons.save_outlined : Icons.add_circle_outline,
                      size: 20),
                  label: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambahkan Komik',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenDark,
                    foregroundColor: AppTheme.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.greenDark, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.greenDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.grey),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.blackMid,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, color: AppTheme.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppTheme.grey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              borderSide: BorderSide(color: AppTheme.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              borderSide:
                  const BorderSide(color: AppTheme.green, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              borderSide:
                  const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusSm),
              borderSide:
                  const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildStatusOption(String status, Color color) {
    final selected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                selected ? color : color.withOpacity(0.08),
            borderRadius:
                BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: selected ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppTheme.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
