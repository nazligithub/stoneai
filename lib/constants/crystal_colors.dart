import 'package:flutter/material.dart';

/// Uygulamanın renk sistemi.
///
/// Sıcak kireçtaşı zemin + mineral yeşili arayüz + bakır eylem rengi.
/// Önceki palet hazır bir paketten gelen "AquaSplash" gradyanıydı ve konuyla
/// ilgisi yoktu; bu palet taş/kristal dünyasına göre kuruldu.
///
/// Tek kural: [accent] arayüzün rengidir (aktif sekme, bağlantı, ikon),
/// [accentAction] ise yalnızca taramaya aittir. Bakırı başka bir yerde
/// kullanma — soğuk zemindeki tek sıcak nokta olduğu için işe yarıyor.
class CrystalColors {
  // ---------------------------------------------------------------- vurgu
  /// Arayüz vurgusu — mineral yeşili.
  static const Color accent = Color(0xFF1E6B72);

  /// Yalnızca tarama eylemi — bakır.
  static const Color accentAction = Color(0xFFC2551F);

  /// Vurgunun açık tonu: rozet ve ikon kutusu zeminleri.
  static const Color accentSoft = Color(0xFFE2ECED);

  /// Vurgunun koyu tonu: açık zemin üzerinde vurgulu metin.
  static const Color accentDeep = Color(0xFF175359);

  // -------------------------------------------------------------- zeminler
  /// Sayfa zemini.
  static const Color background = Color(0xFFFBF8F3);

  /// Kart yüzeyi.
  static const Color surface = Color(0xFFFFFDFA);

  /// İkincil yüzey: giriş alanları, pasif kutular.
  static const Color surfaceAlt = Color(0xFFF5EEE4);

  /// Ayırıcı çizgi ve kart kenarlığı.
  static const Color hairline = Color(0xFFEDE3D6);

  /// Koyu kart — tarama kartı gibi vurgulu anlar.
  static const Color inkDark = Color(0xFF241E1A);

  /// Sayfanın üstündeki sıcak geçiş.
  static const Gradient pageGradient = LinearGradient(
    colors: [Color(0xFFEFE1D0), Color(0xFFF7F1E9), Color(0xFFFBF8F3)],
    stops: [0.0, 0.3, 0.62],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ---------------------------------------------------------------- metin
  static const Color textPrimary = Color(0xFF221C17);
  static const Color textSecondary = Color(0xFF8A7768);
  static const Color textTertiary = Color(0xFFA08D7C);

  // --------------------------------------------------------- kart tonları
  static const Color tintAmethyst = Color(0xFFE7DDF1);
  static const Color tintEmerald = Color(0xFFD9E5D4);
  static const Color tintTiger = Color(0xFFF1E0C2);
  static const Color tintRose = Color(0xFFF3DEDE);

  // -------------------------------------------------------------- anlamsal
  /// Premium / PRO işaretleri.
  static const Color amberGold = Color(0xFFB8892A);

  /// Başarı.
  static const Color gemGreen = Color(0xFF3E8F6B);

  /// Hata, silme.
  static const Color rubyRed = Color(0xFFB3402F);

  static const Color rockBrown = Color(0xFF8A5A22);
  static const Color stoneGray = Color(0xFF7E6E60);
  static const Color crystalWhite = Color(0xFFFFFDFA);

  // ------------------------------------------------------ geriye dönük adlar
  // Uygulamanın 21 dosyası bu adları kullanıyor. Adlar duruyor, değerleri yeni
  // palete bağlandı; böylece tek dosyayla her ekran geçiş yaptı. Yeni kod
  // yukarıdaki adları kullanmalı.

  /// Yeni kodda [accent] kullan.
  static const Color primaryBlue = accent;

  /// Yeni kodda [accent] kullan.
  static const Color primary = accent;

  /// Yeni kodda [accentSoft] ya da [accent] kullan.
  static const Color primaryLight = Color(0xFF6FAAB0);

  /// Yeni kodda [accentDeep] kullan.
  static const Color primaryDark = accentDeep;

  /// Yeni kodda [background] kullan.
  static const Color backgroundLight = background;

  /// Yeni kodda [inkDark] kullan.
  static const Color backgroundDark = inkDark;

  /// Yeni kodda [textPrimary] kullan.
  static const Color text = textPrimary;

  /// Yeni kodda [textTertiary] kullan.
  static const Color textLight = textTertiary;

  static const Gradient crystalTabGradient = LinearGradient(
    colors: [accent, Color(0xFF3E8F94)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient crystalGradientVertical = LinearGradient(
    colors: [accent, Color(0xFF3E8F94)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient crystalGradientHorizontal = LinearGradient(
    colors: [accent, Color(0xFF3E8F94)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
