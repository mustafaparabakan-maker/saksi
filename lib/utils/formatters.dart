/// 1250.5 -> "₺1.250,50" biçiminde Türkçe fiyat metni üretir.
/// (Ekstra paket kullanmamak için intl yerine basit bir fonksiyon.)
String formatPrice(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts[0];
  final buffer = StringBuffer();

  for (var i = 0; i < whole.length; i++) {
    buffer.write(whole[i]);
    final remaining = whole.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }
  return '₺$buffer,${parts[1]}';
}

/// Türkçe karakterleri doğru küçülterek arama için metni hazırlar.
/// ("İ" -> "i", "I" -> "ı")
String normalizeForSearch(String text) {
  return text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
}
