import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globio_exam_ready/services/auth_service.dart';
import 'package:globio_exam_ready/services/offer_service.dart';
import 'package:globio_exam_ready/services/wallet_service.dart';
import 'package:globio_exam_ready/widgets/welcome_offer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const email = 'asha@example.com';

  Future<void> openPopup(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => WelcomeOfferDialog.show(context, email: email),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthService.instance..resetForTest();
    await auth.init();
    await auth.signUp(name: 'Asha Rao', email: email, password: 'secret123');
  });

  testWidgets('new user: claim 100 coins, card flips to the offer, buy 3 mocks', (tester) async {
    await tester.runAsync(() async {
      await openPopup(tester);
      expect(find.text('Welcome to Globio, Asha!'), findsOneWidget);
      expect(await Wallet.balance(email), 0, reason: 'coins are only added when claimed');

      await tester.tap(find.text('Claim 100 coins'));
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(await Wallet.balance(email), 100);

      if (!LaunchOffer.isOpen()) {
        // After 25 Nov 2026 the popup just closes after claiming.
        expect(find.text('Claim 100 coins'), findsNothing);
        return;
      }
      expect(find.text('3 mocks for 100 coins'), findsOneWidget);
      await tester.tap(find.text('Get 3 mocks for 100 coins'));
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(await LaunchOffer.left(email), 3);
      expect(await Wallet.balance(email), 0);
      expect(find.text('3 mocks for 100 coins'), findsNothing, reason: 'popup closes after buying');
    });
  });
}
