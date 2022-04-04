import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/data/request/login_request/login_request.dart';
import 'package:merchant/data/response/label_count_response/label_count_response.dart';
import 'package:merchant/data/response/label_detail_response/label_detail_response.dart';
import 'package:merchant/data/response/label_list_response/label_list_response.dart';
import 'package:merchant/data/response/login_response/login_response.dart';
import 'package:merchant/utils/constants.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider((ref) => Dio());

final repositoryProvider = Provider((ref) => MerchantRepository(ref.read));

class MerchantRepository {
  MerchantRepository(this._read);

  final Reader _read;

  Future<LoginResponse?> userLogin({
    LoginRequest? loginRequest,
    CancelToken? cancelToken,
  }) async {
    try {
      final result = await _read(dioProvider).post(
        "$baseUrl/api/login",
        data: loginRequest,
        options: Options(
          headers: {
            'X-API-TOKEN': apiKey,
            'Accept': "application/json",
          },
        ),
      );
      return LoginResponse.fromJson(Map<String, Object>.from(result.data!));
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        print(e.response!.data!);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future<LabelCountResponse?> fetchDashboard({
    CancelToken? cancelToken,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token1 = prefs.getString("token");
      final result = await _read(dioProvider).get(
        "$baseUrl/mobile/dashboard",
        options: Options(
          headers: {
            'X-API-TOKEN': apiKey,
            'Accept': "application/json",
            'Authorization': "Bearer " + token1!,
          },
        ),
      );
      return LabelCountResponse.fromJson(
          Map<String, Object>.from(result.data!));
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        print(e.response!.data!);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future<LabelListResponse?> fetchLabelList({
    String? token,
    String? status,
    int? page,
    CancelToken? cancelToken,
  }) async {
    try {
      final result = await _read(dioProvider).get(
        "$baseUrl/mobile/label/list?status_key=$status&page=$page",
        options: Options(
          headers: {
            'X-API-TOKEN': apiKey,
            'Accept': "application/json",
            'Authorization': "Bearer " + token!,
          },
        ),
      );
      return LabelListResponse.fromJson(Map<String, Object>.from(result.data!));
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        print(e.response!.data!);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future<LabelDetailResponse?> fetchLabelDetail({
    String? token,
    String? trackingCode,
    CancelToken? cancelToken,
  }) async {
    try {
      final result = await _read(dioProvider).get(
        "$baseUrl/mobile/label/track-label?tracking_code=$trackingCode&mobile=true",
        options: Options(
          headers: {
            'X-API-TOKEN': apiKey,
            'Accept': "application/json",
            'Authorization': "Bearer " + token!,
          },
        ),
      );
      developer.log(result.toString());
      return LabelDetailResponse.fromJson(
          Map<String, Object>.from(result.data!));
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response!.statusCode);
        print(e.response!.data!);
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }
}
