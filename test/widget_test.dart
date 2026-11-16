import 'package:flutter_test/flutter_test.dart';

import 'package:saksi/main.dart';
import 'package:saksi/utils/formatters.dart';

void main() {
  testWidgets('Uygulama açılır ve logo görünür', (tester) async {
    await tester.pumpWidget(const SaksiApp());
    expect(find.text('Saksı'), findsOneWidget);
    // Veri yükleme gecikmesinin (simülasyon) tamamlanmasını bekle
    await tester.pump(const Duration(seconds: 1));
  });

  test('Fiyat Türkçe biçimde gösterilir', () {
    expect(formatPrice(1250.5), '₺1.250,50');
    expect(formatPrice(119.9), '₺119,90');
  });
}
