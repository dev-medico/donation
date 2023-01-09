import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Map<String, String> headers = {
  "Accept": "application/json",
  "content-type": 'application/json',
  "Authorization": "Bearer xau_n8jyl0ncOhjMYXFMQvgU5re57VDW9vSX2"
};

class XataRepository {
  XataRepository();

  Future<http.Response> uploadNewEvent(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Records/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> getMembersTotal() async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Totals/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "filter": {"id": "members_total"}
        }));

    return response;
  }

  Future<http.Response> getDonationsTotal() async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Totals/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "filter": {"id": "donations_total"}
        }));

    return response;
  }

  Future<http.Response> getMemberList(String after) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Members/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200, if (after != "") "after": after},
        }));

    return response;
  }

  Future<http.Response> searchMemberList(String search) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Members/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200},
          "filter": {
            "name": {"\$contains": search}
          }
        }));

    return response;
  }

  Future<http.Response> updateMember(
      String memberId, int donationCount, int totalCount) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Members/data/$memberId?columns=id'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "donation_counts": donationCount,
          "total_count": totalCount
        }));
    log("Update Response - ${response.statusCode.toString()}");
    log("Update Response - ${response.body}");

    return response;
  }

  Future<http.Response> uploadNewMember(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Members/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> updateMembersTotal(int totalCount) async {
    final response = await http.patch(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Totals/data/members_total?columns=id'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{"value": totalCount}));

    return response;
  }

  Future<http.Response> getDonationsList(String after) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donations/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "columns": ["*", "member.*"],
          "page": {"size": 200, if (after != "") "after": after},
        }));

    return response;
  }

  Future<http.Response> getDonationsListByMemberId(String memberId) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donations/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200},
          "columns": ["*", "member.*"],
          "filter": {"member.member_id": memberId}
        }));

    return response;
  }

  Future<http.Response> deleteDonationByID(String donationId) async {
    final response = await http.delete(
      Uri.parse(
          'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donations/data/$donationId?columns=id'),
      headers: headers,
    );
    log(response.statusCode.toString());
    log(response.body);

    return response;
  }

  Future<http.Response> uploadNewDonations(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donations/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> updateDonationsTotal(int totalCount) async {
    final response = await http.patch(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Totals/data/donations_total?columns=id'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{"value": totalCount}));

    return response;
  }

  Future<http.Response> updateMemberData(String id, String data) async {
    final response = await http.patch(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Members/data/$id?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> updateDonationData(String id, String data) async {
    final response = await http.patch(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donations/data/$id?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> uploadNewDonor(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donors/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> updateDonor(String id, String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donors/data/$id?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> uploadNewExpense(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Expenses/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> getDonorsList(String after) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donors/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200, if (after != "") "after": after},
        }));

    return response;
  }

  Future<http.Response> getExpensesList(String after) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Expenses/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "page": {"size": 200, if (after != "") "after": after},
        }));

    return response;
  }

  Future<http.Response> deleteDonorByID(String donorID) async {
    final response = await http.delete(
      Uri.parse(
          'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Donors/data/$donorID?columns=id'),
      headers: headers,
    );
    log(response.statusCode.toString());
    log(response.body);

    return response;
  }

  Future<http.Response> deleteExpenseByID(String expenseID) async {
    final response = await http.delete(
      Uri.parse(
          'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/Expenses/data/$expenseID?columns=id'),
      headers: headers,
    );
    log(response.statusCode.toString());
    log(response.body);

    return response;
  }

  Future<http.Response> uploadNewClosingBalance(String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/ClosingBalances/data?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

   Future<http.Response> updatewClosingBalance(String id,String data) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/ClosingBalances/data/$id?columns=id'),
        headers: headers,
        body: data);

    return response;
  }

  Future<http.Response> getClosingBalance(int month, String year) async {
    final response = await http.post(
        Uri.parse(
            'https://sithu-aung-s-workspace-oc5cng.us-east-1.xata.sh/db/next:main/tables/ClosingBalances/query'),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          "filter": {"month": "$month-$year"}
        }));

    return response;
  }
}
