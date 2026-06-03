import 'package:donation/src/features/monthly_sponsor/models/monthly_sponsor.dart';
import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final monthlySponsorServiceProvider =
    Provider<MonthlySponsorService>((ref) => MonthlySponsorService());

class MonthlySponsorService extends BaseService {
  final String _base = '/monthly-sponsor';
  final String _donBase = '/monthly-sponsor-donation';

  bool _ok(dynamic res) =>
      res.statusCode == 200 && res.data?['status'] == 'ok';

  Future<Map<String, dynamic>> getSponsors(
      {int page = 0, int limit = 50, String q = ''}) async {
    final headers = await getAuthHeaders();
    final qp = <String, dynamic>{'page': page, 'limit': limit};
    if (q.isNotEmpty) qp['q'] = q;
    final res = await apiClient.get(
      '$_base/index',
      queryParameters: qp,
      options: {'headers': headers},
    );
    if (_ok(res)) {
      return {
        'data': (res.data!['data'] as List<dynamic>),
        'total': res.data!['total'] ?? 0,
        'hasMore': res.data!['hasMore'] ?? false,
      };
    }
    throw Exception('Failed to load sponsors');
  }

  Future<MonthlySponsor> getSponsor(int id) async {
    final headers = await getAuthHeaders();
    final res = await apiClient.get(
      '$_base/view',
      queryParameters: {'id': id},
      options: {'headers': headers},
    );
    if (_ok(res)) {
      return MonthlySponsor.fromJson(res.data!['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load sponsor');
  }

  Future<void> createSponsor(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final res = await apiClient.post('$_base/create',
        data: data, options: {'headers': headers});
    if (!_ok(res)) throw Exception('Failed to create sponsor');
  }

  Future<void> updateSponsor(int id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final res = await apiClient.post('$_base/update',
        queryParameters: {'id': id}, data: data, options: {'headers': headers});
    if (!_ok(res)) throw Exception('Failed to update sponsor');
  }

  Future<void> deleteSponsor(int id) async {
    final headers = await getAuthHeaders();
    await apiClient.post('$_base/delete',
        queryParameters: {'id': id}, options: {'headers': headers});
  }

  Future<void> addDonation(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final res = await apiClient.post('$_donBase/create',
        data: data, options: {'headers': headers});
    if (!_ok(res)) throw Exception('Failed to add donation');
  }

  Future<void> updateDonation(int id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final res = await apiClient.post('$_donBase/update',
        queryParameters: {'id': id}, data: data, options: {'headers': headers});
    if (!_ok(res)) throw Exception('Failed to update donation');
  }

  Future<void> deleteDonation(int id) async {
    final headers = await getAuthHeaders();
    await apiClient.post('$_donBase/delete',
        queryParameters: {'id': id}, options: {'headers': headers});
  }
}
