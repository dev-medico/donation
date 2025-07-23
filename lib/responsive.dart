import 'package:flutter/material.dart';
import 'package:donation/utils/responsive_utils.dart';

/// Legacy responsive widget - maintained for backward compatibility
/// New code should use ResponsiveLayout from responsive_utils.dart
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  /// Check if mobile - uses new standardized breakpoints
  static bool isMobile(BuildContext context) =>
      ResponsiveUtils.isMobile(context);

  /// Check if tablet - uses new standardized breakpoints
  static bool isTablet(BuildContext context) =>
      ResponsiveUtils.isTablet(context);

  /// Check if desktop - uses new standardized breakpoints
  static bool isDesktop(BuildContext context) =>
      ResponsiveUtils.isDesktopOrLarger(context);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop ?? tablet,
    );
  }
}
