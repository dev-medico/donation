import 'dart:io';

import 'package:donation/utils/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visible release version matches the package version', () {
    final packageVersion = RegExp(r'^version:\s*([^+\s]+)', multiLine: true)
        .firstMatch(File('pubspec.yaml').readAsStringSync())!
        .group(1);
    expect(appVersion, packageVersion);
  });
}
