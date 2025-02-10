import 'package:realm/realm.dart';
import 'package:donation/models/member.dart';
import 'package:donation/services/member_service.dart';
import 'package:donation/realm/schemas.dart' as realm_schemas;

class RealmMigrationUtility {
  final MemberService _memberService;
  final Realm _realm;

  RealmMigrationUtility({
    required Realm realm,
    MemberService? memberService,
  })  : _realm = realm,
        _memberService = memberService ?? MemberService();

  Future<MigrationResult> migrateMembersToBackend() async {
    final results = MigrationResult();
    final realmMembers = _realm.all<realm_schemas.Member>();

    for (final realmMember in realmMembers) {
      try {
        final member = Member(
          id: realmMember.id.toString(),
          birthDate: realmMember.birthDate,
          bloodBankCard: realmMember.bloodBankCard,
          bloodType: realmMember.bloodType,
          fatherName: realmMember.fatherName,
          lastDate: realmMember.lastDate,
          memberCount: realmMember.memberCount,
          memberId: realmMember.memberId,
          name: realmMember.name,
          note: realmMember.note,
          nrc: realmMember.nrc,
          phone: realmMember.phone,
          address: realmMember.address,
          gender: realmMember.gender,
          profileUrl: realmMember.profileUrl,
          registerDate: realmMember.registerDate,
          totalCount: realmMember.totalCount,
          status: realmMember.status,
          ownerId: realmMember.ownerId,
        );

        final response = await _memberService.createMember(
          name: member.name ?? '',
          bloodType: member.bloodType ?? '',
          birthDate: member.birthDate,
          fatherName: member.fatherName,
          phone: member.phone,
          address: member.address,
          nrc: member.nrc,
          gender: member.gender,
          ownerId: member.ownerId,
        );

        if (response.success) {
          results.successful++;
        } else {
          results.failed++;
          results.errors.add(
              'Failed to migrate member ${member.name}: ${response.message}');
        }
      } catch (e) {
        results.failed++;
        results.errors.add('Error migrating member: $e');
      }
    }

    return results;
  }

  Future<void> validateMigration() async {
    final realmMemberCount = _realm.all<realm_schemas.Member>().length;
    final backendResponse = await _memberService.getAllMembers();

    if (!backendResponse.success) {
      throw Exception(
          'Failed to validate migration: ${backendResponse.message}');
    }

    final backendMemberCount = backendResponse.data?.length ?? 0;

    if (realmMemberCount != backendMemberCount) {
      throw Exception(
        'Migration validation failed: Realm has $realmMemberCount members, '
        'but backend has $backendMemberCount members',
      );
    }
  }
}

class MigrationResult {
  int successful = 0;
  int failed = 0;
  final List<String> errors = [];

  bool get hasErrors => failed > 0;

  @override
  String toString() {
    return '''
Migration Results:
  Successful: $successful
  Failed: $failed
  ${hasErrors ? '\nErrors:\n${errors.join('\n')}' : ''}
''';
  }
}
