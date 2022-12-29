import 'dart:io';
import 'package:intl/intl.dart';

var decimalFormat = NumberFormat("###.#", "en_US");
final formatter = NumberFormat("#,###", "en_US");

const String deliverPending = "pending";
const String deliverProcess = "approved";
const String deliverDone = "delivered";
const String deliverReturn = "return";

const String baseUrl = "https://customer.exfcs-mm.com";
const apiKey = "1ffc0105cb204ceb50bad4e63ce96c92";

const version = "1.1.0";

const apiKeyM = "3878eb1b-74b9-46c7-b978-80c65e797731";

const String imageSize = "imgWidth=300&imgHeight=300";
const String bannerSize = "bannerWidth=700&bannerHeight=200";
const String sliderSize = "sliderWidth=100&sliderHeight=120";
const String categorySize = "categoryWidth=300&categoryHeight=300";

Map<String, String> headers_2 = {
  "Accept": "application/json",
  'content-type': 'application/json',
  "X-APP-VERSION": version,
  "X-API-TOKEN": apiKeyM
};

Map<String, String> headers(String token, String locale, String timezone) => {
      "Accept": "application/json",
      'content-type': 'application/json',
      "X-API-TOKEN": apiKey,
      "X-APP-VERSION": version,
      "timezone": timezone,
      HttpHeaders.authorizationHeader: "Bearer $token",
      "lang": locale
    };

Map<String, String> headersPlain(String token) => {
      "Accept": "application/json",
      'content-type': 'application/json',
      "X-API-TOKEN": apiKey,
      "X-APP-VERSION": version,
      HttpHeaders.authorizationHeader: "Bearer $token"
    };

Map<String, String> headersNoAuth() => {
      "Accept": "application/json",
      'content-type': 'application/json',
      "X-API-TOKEN": apiKey,
      "X-APP-VERSION": version,
    };

Map<String, String> headers_1(String locale, String timezone) => {
      "Accept": "application/json",
      'content-type': 'application/json',
      "X-API-TOKEN": apiKey,
      "X-APP-VERSION": version,
      "timezone": timezone,
      "lang": locale
    };
