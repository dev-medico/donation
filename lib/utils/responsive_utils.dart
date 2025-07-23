import 'package:flutter/material.dart';

/// Standardized responsive breakpoints for the Blood Donation app
class ResponsiveBreakpoints {
  /// Mobile devices (phones)
  static const double mobile = 600;
  
  /// Tablet devices (iPads, small laptops)
  static const double tablet = 900;
  
  /// Desktop devices (laptops, monitors)
  static const double desktop = 1200;
  
  /// Large desktop devices (large monitors)
  static const double largeDesktop = 1800;
}

/// Responsive utility class for layout decisions
class ResponsiveUtils {
  /// Check if current device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  
  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile && width < ResponsiveBreakpoints.tablet;
  }
  
  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet && width < ResponsiveBreakpoints.largeDesktop;
  }
  
  /// Check if current device is large desktop
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.largeDesktop;
  
  /// Check if device is at least tablet size
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile;
  
  /// Check if device is at least desktop size
  static bool isDesktopOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;
  
  /// Get current device type as enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < ResponsiveBreakpoints.largeDesktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }
  
  /// Get responsive value based on device type
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
      largeDesktop: const EdgeInsets.all(40),
    );
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseSize,
  }) {
    return getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
      largeDesktop: baseSize * 1.3,
    );
  }
  
  /// Get number of grid columns based on screen size
  static int getResponsiveGridColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive layout widget that automatically switches between layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.largeDesktop && largeDesktop != null) {
          return largeDesktop!;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive builder widget for more complex responsive logic
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils.getDeviceType(context));
  }
}