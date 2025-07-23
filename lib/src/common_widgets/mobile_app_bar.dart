import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced mobile app bar with modern design
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool implyLeading;
  final VoidCallback? onBack;
  
  const MobileAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.implyLeading = true,
    this.onBack,
  }) : super(key: key);
  
  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;
    final fgColor = foregroundColor ?? Colors.black;
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: fgColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      leading: leading ?? (implyLeading ? _buildLeading(context) : null),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: 
            bgColor.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light,
      ),
    );
  }
  
  Widget? _buildLeading(BuildContext context) {
    if (!Navigator.canPop(context)) return null;
    
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: onBack ?? () => Navigator.pop(context),
      splashRadius: 24,
    );
  }
}

/// Search app bar for mobile
class MobileSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final List<Widget>? actions;
  final bool autofocus;
  final TextEditingController? controller;
  
  const MobileSearchAppBar({
    Key? key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.actions,
    this.autofocus = false,
    this.controller,
  }) : super(key: key);
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  @override
  State<MobileSearchAppBar> createState() => _MobileSearchAppBarState();
}

class _MobileSearchAppBarState extends State<MobileSearchAppBar> {
  late TextEditingController _controller;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged(_controller.text);
  }
  
  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
        splashRadius: 24,
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
            suffixIcon: _hasText
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
                    onPressed: _clearSearch,
                    splashRadius: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      actions: widget.actions,
    );
  }
}

/// Sliver app bar for scrollable screens
class MobileSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  
  const MobileSliverAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.expandedHeight = 120,
    this.flexibleSpace,
    this.bottom,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace ?? _buildDefaultFlexibleSpace(),
      bottom: bottom,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }
  
  Widget _buildDefaultFlexibleSpace() {
    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}