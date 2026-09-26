import 'package:cached_network_image/cached_network_image.dart';
import 'package:donation/src/features/donation_member/domain/honour_roll.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Honour roll: donors with 10 or more lifetime donations, in the bands the
/// group asked for (10–19, 20–29, 30–39, 40–49, and 50+ once reached), most
/// first within each band.
class HonorableDonorsScreen extends ConsumerStatefulWidget {
  const HonorableDonorsScreen({super.key});
  static const routeName = '/honorable-donors';

  @override
  ConsumerState<HonorableDonorsScreen> createState() =>
      _HonorableDonorsScreenState();
}

class _HonorableDonorsScreenState extends ConsumerState<HonorableDonorsScreen> {
  late Future<List<HonourRollEntry>> _future;
  dynamic _uploadingId;
  int _tierIndex = 0;
  // Local messenger so snackbars never look up a deactivated Scaffold from the
  // surrounding desktop shell.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<HonourRollEntry>> _load() async {
    // One request for every band: the server returns everyone at or above the
    // minimum, most first, and the bands are cut here.
    final raw = await ref
        .read(memberServiceProvider)
        .getHonorableDonors(min: honourRollMinimum);
    return raw
        .map((e) => HonourRollEntry.fromJson(e as Map<String, dynamic>))
        .where((e) => e.total >= honourRollMinimum)
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  Future<void> _pickAndUpload(Member m) async {
    try {
      // A plain file picker (no camera) — works on web and every platform.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // load bytes (required on web)
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;
      final bytes = picked.bytes;
      if (bytes == null) {
        _messengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('ဖိုင် ဖတ်၍ မရပါ')),
        );
        return;
      }
      var filename = picked.name;
      if (!filename.contains('.')) filename = 'photo.jpg';

      if (mounted) setState(() => _uploadingId = m.id);
      await ref
          .read(memberServiceProvider)
          .uploadMemberPhoto(m.id.toString(), bytes, filename);
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('ဓာတ်ပုံ တင်ပြီးပါပြီ')),
      );
      _refresh();
    } catch (e) {
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('ဓာတ်ပုံ တင်၍ မရပါ — $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _messengerKey,
        child: Scaffold(
          backgroundColor: const Color(0xfff2f2f2),
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [primaryColor, primaryDark],
                ),
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'ဂုဏ်ထူးဆောင် သွေးအလှူရှင်များ',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          body: FutureBuilder<List<HonourRollEntry>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ရယူ၍ မရပါ — ${snap.error}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('ပြန်ရယူမည်'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _roll(snap.data ?? const []);
            },
          ),
        ));
  }

  Widget _roll(List<HonourRollEntry> donors) {
    final tiers = honourTiersFor(donors.map((e) => e.total));
    final tierIndex = _tierIndex.clamp(0, tiers.length - 1);
    final tier = tiers[tierIndex];
    final counts = [
      for (final t in tiers) donors.where((e) => t.contains(e.total)).length,
    ];
    final inTier = donors.where((e) => tier.contains(e.total)).toList();
    final ranks = competitionRanks([for (final e in inTier) e.total]);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: _TierStrip(
                tiers: tiers,
                counts: counts,
                selected: tierIndex,
                onSelect: (i) => setState(() => _tierIndex = i),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: inTier.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                            child: Text(
                              '${tier.label} ကြိမ် လှူဒါန်းထားသူ မရှိသေးပါ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        key: PageStorageKey('honour-tier-${tier.label}'),
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: inTier.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _donorTile(inTier[i], ranks[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _donorTile(HonourRollEntry entry, int rank) {
    final m = entry.member;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: rank <= 3 ? primaryColor : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _avatar(m),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                _buildDonorMetadata(m),
                if (entry.hasBreakdown) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ယခင် ${entry.previous} + အဖွဲ့နှင့် ${entry.recorded}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _TotalMark(total: entry.total),
        ],
      ),
    );
  }

  Widget _buildDonorMetadata(Member member) {
    final hasBloodType = (member.bloodType ?? '').isNotEmpty;
    final hasMemberId = (member.memberId ?? '').isNotEmpty;

    return Wrap(
      spacing: 10,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasBloodType)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bloodtype, size: 14, color: primaryColor),
              const SizedBox(width: 2),
              Text(
                member.bloodType!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        if (hasMemberId)
          Text(
            member.memberId!,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _avatar(Member m) {
    final url = m.profileUrl;
    final hasUrl = url != null && url.isNotEmpty;
    final uploading = _uploadingId != null && _uploadingId == m.id;
    return GestureDetector(
      onTap: uploading ? null : () => _pickAndUpload(m),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[200],
            backgroundImage: hasUrl ? CachedNetworkImageProvider(url) : null,
            child: hasUrl
                ? null
                : Icon(Icons.person, color: Colors.grey[400], size: 28),
          ),
          if (uploading)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black38, shape: BoxShape.circle),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
            )
          else
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child:
                    const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// The bands as one row of equal tabs: the range large, the number of donors
/// in it underneath. Scrolls sideways only if a phone is too narrow to fit
/// them all.
class _TierStrip extends StatelessWidget {
  const _TierStrip({
    required this.tiers,
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  final List<HonourTier> tiers;
  final List<int> counts;
  final int selected;
  final ValueChanged<int> onSelect;

  static const _gap = 6.0;
  // Five bands fit a 320-pixel phone at this width.
  static const _minTabWidth = 52.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fits = constraints.maxWidth >=
          tiers.length * _minTabWidth + (tiers.length - 1) * _gap;
      final tabs = [
        for (var i = 0; i < tiers.length; i++)
          _TierTab(
            key: ValueKey('honour-tier-${tiers[i].label}'),
            tier: tiers[i],
            count: counts[i],
            selected: i == selected,
            onTap: () => onSelect(i),
          ),
      ];
      if (fits) {
        return Row(
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Expanded(child: tabs[i]),
            ],
          ],
        );
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              SizedBox(width: _minTabWidth + 8, child: tabs[i]),
            ],
          ],
        ),
      );
    });
  }
}

class _TierTab extends StatelessWidget {
  const _TierTab({
    super.key,
    required this.tier,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final HonourTier tier;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : Colors.black87;
    return Semantics(
      button: true,
      selected: selected,
      label: '${tier.spokenLabel} $count ဦး',
      excludeSemantics: true,
      child: Material(
        color: selected ? primaryColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tier.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count ဦး',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A donor's lifetime total: the number carries the row, the unit sits under
/// it.
class _TotalMark extends StatelessWidget {
  const _TotalMark({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$total ကြိမ်',
      excludeSemantics: true,
      child: SizedBox(
        width: 44,
        child: Column(
          children: [
            Text(
              '$total',
              style: TextStyle(
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Text(
              'ကြိမ်',
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
