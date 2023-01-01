import 'dart:convert';

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
}
