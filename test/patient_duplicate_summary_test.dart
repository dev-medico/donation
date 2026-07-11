import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/patient_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'duplicate summary shows the details needed to identify a patient',
    (tester) async {
      final patient = Patient(
        name: 'ဦးသန်းစိုး',
        age: '46',
        bloodType: 'O (Rh +)',
        address: 'သာယာအေးရပ်ကွက်၊ မော်လမြိုင်မြို့နယ်',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DuplicatePatientSummaryCard(patient: patient)),
        ),
      );

      expect(find.text('ဦးသန်းစိုး'), findsOneWidget);
      expect(find.text('အသက်:'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);
      expect(find.text('သွေးအုပ်စု:'), findsOneWidget);
      expect(find.text('O (Rh +)'), findsOneWidget);
      expect(find.text('လိပ်စာ:'), findsOneWidget);
      expect(find.text('သာယာအေးရပ်ကွက်၊ မော်လမြိုင်မြို့နယ်'), findsOneWidget);
    },
  );
}
