import 'package:donation/src/features/patient/widgets/age_input.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Staff keyboards (Myanmar3 & friends) emit Myanmar digits ၀-၉ on the number
// row, and legacy patient records already store ages that way (e.g. "၅၄").
// The age fields must accept them; they are normalised to ASCII so the birth
// date can be computed.
void main() {
  Future<void> pumpAgeInput(
    WidgetTester tester,
    ValueChanged<DateTime?> onChanged,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgeInput(onChanged: onChanged),
        ),
      ),
    );
  }

  testWidgets('typing Myanmar digits into years is accepted and normalised',
      (tester) async {
    DateTime? birthDate;
    await pumpAgeInput(tester, (d) => birthDate = d);

    // Years field is the first TextFormField ("အသက် (နှစ်)").
    final yearsField = find.byType(TextFormField).first;
    await tester.enterText(yearsField, '၅၄');
    await tester.pump();

    // The field shows the normalised ASCII value...
    expect(find.text('54'), findsOneWidget);
    // ...and the birth date is derived from it (age recomputes to 54).
    expect(birthDate, isNotNull);
    expect(ageFromBirthDate(birthDate!).years, 54);
  });

  testWidgets('ASCII digits still work', (tester) async {
    DateTime? birthDate;
    await pumpAgeInput(tester, (d) => birthDate = d);

    await tester.enterText(find.byType(TextFormField).first, '30');
    await tester.pump();

    expect(find.text('30'), findsOneWidget);
    expect(birthDate, isNotNull);
    expect(ageFromBirthDate(birthDate!).years, 30);
  });

  testWidgets('mixed Myanmar/ASCII input normalises, non-digits dropped',
      (tester) async {
    DateTime? birthDate;
    await pumpAgeInput(tester, (d) => birthDate = d);

    await tester.enterText(find.byType(TextFormField).first, '၁2a');
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
    expect(birthDate, isNotNull);
    expect(ageFromBirthDate(birthDate!).years, 12);
  });

  test('normalizeMyanmarDigits converts legacy age strings', () {
    expect(normalizeMyanmarDigits('၅၄'), '54');
    expect(normalizeMyanmarDigits('၀'), '0');
    expect(normalizeMyanmarDigits('40'), '40');
    expect(normalizeMyanmarDigits(''), '');
    expect(int.tryParse(normalizeMyanmarDigits('၆၇')), 67);
  });
}
