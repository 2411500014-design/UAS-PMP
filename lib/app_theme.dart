import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color bgLight    = Color(0xFFF5FBF5); // putih kehijauan sangat muda
  static const Color greenLight = Color(0xFFA5D6A7); // hijau muda
  static const Color green      = Color(0xFF4CAF50); // hijau utama
  static const Color greenDark  = Color(0xFF2E7D32); // hijau tua
  static const Color black      = Color(0xFF1A1A1A); // hitam soft
  static const Color blackMid   = Color(0xFF3D3D3D);
  static const Color grey       = Color(0xFF9E9E9E);
  static const Color greyLight  = Color(0xFFEEEEEE);
  static const Color cardBg     = Color(0xFFFFFFFF);

  // ── Status warna ─────────────────────────────────────────
  static const Color ongoing    = Color(0xFF66BB6A);
  static const Color completed  = Color(0xFF26A69A);
  static const Color hiatus     = Color(0xFFFFB74D);

  // ── Tipe komik tag warna ──────────────────────────────────
  static const Color manhwaColor  = Color(0xFF42A5F5);
  static const Color mangaColor   = Color(0xFFAB47BC);
  static const Color manhuaColor  = Color(0xFFFF7043);

  // ── Radius ───────────────────────────────────────────────
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 24.0;

  // ── Shadow ───────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: AppTheme.green.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
