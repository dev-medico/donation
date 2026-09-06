import 'package:donation/data/township_detail/township_detail.dart';
import 'package:donation/src/features/patient/widgets/location_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = TownshipDetailRepository.instance;
  const kawkareikTownship = 'ကော့ကရိတ်မြို့နယ်';
  const hpaAnTownship = 'ဘားအံမြို့နယ်';
  const wardsOneToFour = [
    'အမှတ်(၁)ရပ်ကွက်',
    'အမှတ်(၂)ရပ်ကွက်',
    'အမှတ်(၃)ရပ်ကွက်',
    'အမှတ်(၄)ရပ်ကွက်',
  ];
  const wardsOneToSeven = [
    ...wardsOneToFour,
    'အမှတ်(၅)ရပ်ကွက်',
    'အမှတ်(၆)ရပ်ကွက်',
    'အမှတ်(၇)ရပ်ကွက်',
  ];
  const wardsOneToNine = [
    ...wardsOneToSeven,
    'အမှတ်(၈)ရပ်ကွက်',
    'အမှတ်(၉)ရပ်ကွက်',
  ];

  setUpAll(repository.ensureLoaded);

  test('keeps Kawkareik and Kyundoe numbered wards in their town groups', () {
    final wards = repository
        .placesFor(kawkareikTownship)
        .where((place) => place.isWard)
        .toList();

    final kawkareikNumbered = wards
        .where(
          (place) =>
              place.group == 'ကော့ကရိတ်မြို့' &&
              wardsOneToSeven.contains(place.name),
        )
        .map((place) => place.name)
        .toList();
    final kyundoeNumbered = wards
        .where(
          (place) =>
              place.group == 'ကျုံဒိုးမြို့' &&
              wardsOneToFour.contains(place.name),
        )
        .map((place) => place.name)
        .toList();

    expect(kawkareikNumbered, wardsOneToSeven);
    expect(kyundoeNumbered, wardsOneToFour);

    for (final ward in wardsOneToFour) {
      final groups = wards
          .where((place) => place.name == ward)
          .map((place) => place.group);
      expect(groups, unorderedEquals(['ကော့ကရိတ်မြို့', 'ကျုံဒိုးမြို့']));
      expect(repository.findPlace(kawkareikTownship, ward), isNull);
      expect(
        repository.unambiguousTownForWard(kawkareikTownship, ward),
        isEmpty,
      );
    }

    for (final ward in wardsOneToSeven.skip(4)) {
      expect(
        repository.findPlace(kawkareikTownship, ward)?.group,
        'ကော့ကရိတ်မြို့',
      );
      expect(
        repository.unambiguousTownForWard(kawkareikTownship, ward),
        'ကော့ကရိတ်မြို့',
      );
    }
  });

  test('includes Hpa-An numbered wards one through nine', () {
    final numberedWards = repository
        .placesFor(hpaAnTownship)
        .where(
          (place) =>
              place.isWard &&
              place.group == 'ဘားအံမြို့' &&
              wardsOneToNine.contains(place.name),
        )
        .map((place) => place.name)
        .toList();

    expect(numberedWards, wardsOneToNine);
    for (final ward in wardsOneToNine) {
      expect(
        repository.unambiguousTownForWard(hpaAnTownship, ward),
        'ဘားအံမြို့',
      );
    }
  });

  testWidgets('legacy ambiguous ward does not backfill an arbitrary town',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocationSelector(
            initial: const LocationValue(
              township: kawkareikTownship,
              placeName: 'အမှတ်(၁)ရပ်ကွက်',
            ),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('အမှတ်(၁)ရပ်ကွက်၊ကော့ကရိတ်မြို့နယ်'),
      findsOneWidget,
    );
    expect(find.text('မြို့: ကော့ကရိတ်မြို့'), findsNothing);
    expect(find.text('မြို့: ကျုံဒိုးမြို့'), findsNothing);
  });

  test('combined patient addresses retain the selected town', () {
    const kawkareikAddress = LocationValue(
      township: kawkareikTownship,
      placeName: 'အမှတ်(၁)ရပ်ကွက်',
      placeType: 'ward',
      group: 'ကော့ကရိတ်မြို့',
    );
    const kyundoeAddress = LocationValue(
      township: kawkareikTownship,
      placeName: 'အမှတ်(၁)ရပ်ကွက်',
      placeType: 'ward',
      group: 'ကျုံဒိုးမြို့',
    );
    const hpaAnAddress = LocationValue(
      township: hpaAnTownship,
      placeName: 'အမှတ်(၉)ရပ်ကွက်',
      placeType: 'ward',
      group: 'ဘားအံမြို့',
    );

    expect(
      kawkareikAddress.combinedAddress,
      'အမှတ်(၁)ရပ်ကွက်၊ကော့ကရိတ်မြို့၊ကော့ကရိတ်မြို့နယ်',
    );
    expect(
      kyundoeAddress.combinedAddress,
      'အမှတ်(၁)ရပ်ကွက်၊ကျုံဒိုးမြို့၊ကော့ကရိတ်မြို့နယ်',
    );
    expect(
      hpaAnAddress.combinedAddress,
      'အမှတ်(၉)ရပ်ကွက်၊ဘားအံမြို့၊ဘားအံမြို့နယ်',
    );
  });
}
