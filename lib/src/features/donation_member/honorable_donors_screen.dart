import 'package:cached_network_image/cached_network_image.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Honorable donors: members who have donated blood more than 30 times,
/// ordered most -> least.
class HonorableDonorsScreen extends ConsumerStatefulWidget {
  const HonorableDonorsScreen({super.key});
  static const routeName = '/honorable-donors';

  @override
  ConsumerState<HonorableDonorsScreen> createState() =>
      _HonorableDonorsScreenState();
}

class _HonorableDonorsScreenState extends ConsumerState<HonorableDonorsScreen> {
  late Future<List<Member>> _future;
  dynamic _uploadingId;
  // Local messenger so snackbars never look up a deactivated Scaffold from the
  // surrounding desktop shell.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Member>> _load() async {
    final raw =
        await ref.read(memberServiceProvider).getHonorableDonors(min: 30);
    return raw
        .map<Member>((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
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
          body: FutureBuilder<List<Member>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('ရယူ၍ မရပါ — ${snap.error}',
                        textAlign: TextAlign.center),
                  ),
                );
              }
              final donors = snap.data ?? [];
              if (donors.isEmpty) {
                return const Center(
                    child: Text('၃၀ ကြိမ်အထက် လှူဒါန်းထားသူ မရှိသေးပါ'));
              }
              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: donors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _donorTile(donors[i], i + 1),
                ),
              );
            },
          ),
        ));
  }

  Widget _donorTile(Member m, int rank) {
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                _buildDonorMetadata(m),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${m.totalCount ?? 0} ကြိမ်',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorMetadata(Member member) {
    final hasBloodType = (member.bloodType ?? '').isNotEmpty;
    final hasMemberId = (member.memberId ?? '').isNotEmpty;

    if (MediaQuery.of(context).size.width < 480) {
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

    return Row(
      children: [
        if (hasBloodType) ...[
          Icon(Icons.bloodtype, size: 14, color: primaryColor),
          const SizedBox(width: 2),
          Text(
            member.bloodType!,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(width: 10),
        ],
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
