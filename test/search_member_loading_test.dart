import 'dart:async';

import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _PendingSearchMemberRepository extends SearchMemberRepository {
  int requestCount = 0;
  final _firstRequest = Completer<SearchMemberPage>();
  final _retryRequest = Completer<SearchMemberPage>();

  void completeRetry() => _retryRequest.complete(
        const SearchMemberPage(
          members: [],
          total: 0,
          analysis: SearchMemberAnalysis(
            total: 0,
            green: 0,
            yellow: 0,
            red: 0,
          ),
          page: 0,
          limit: 50,
        ),
      );

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) {
    requestCount += 1;
    return requestCount == 1 ? _firstRequest.future : _retryRequest.future;
  }
}

void main() {
  testWidgets('a stalled member search times out and can be retried',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _PendingSearchMemberRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMemberRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: SearchMemberListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('သွေးလှူရှင်များ ရှာဖွေနေပါသည်...'), findsOneWidget);
    expect(repository.requestCount, 1);

    await tester.pump(const Duration(seconds: 21));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('ရှာဖွေမှု အချိန်ကြာနေပါသည်။'), findsOneWidget);
    expect(find.text('ပြန်လည်ကြိုးစားမည်'), findsOneWidget);

    await tester.tap(find.text('ပြန်လည်ကြိုးစားမည်'));
    await tester.pump();

    expect(find.text('သွေးလှူရှင်များ ရှာဖွေနေပါသည်...'), findsOneWidget);
    expect(repository.requestCount, 2);

    repository.completeRetry();
    await tester.pump();

    expect(find.text('ဤအခြေအနေတွင် သွေးလှူရှင် မရှိပါ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(repository.requestCount, 2);
  });
}
