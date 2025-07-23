import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Navigation style preference
enum NavigationStyle {
  drawer,
  bottomNav,
}

/// Provider for navigation style preference
final navigationStyleProvider = StateProvider<NavigationStyle>((ref) => NavigationStyle.drawer);

/// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation item model
class NavigationItem {
  final String title;
  final IconData icon;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool showInBottomNav;
  
  const NavigationItem({
    required this.title,
    required this.icon,
    this.imagePath,
    this.onTap,
    this.showInBottomNav = true,
  });
}

/// Mobile bottom navigation bar widget
class MobileBottomNavigation extends ConsumerWidget {
  final List<NavigationItem> items;
  final Function(int)? onIndexChanged;
  
  const MobileBottomNavigation({
    Key? key,
    required this.items,
    this.onIndexChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final bottomNavItems = items.where((item) => item.showInBottomNav).toList();
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, bottomNavItems.length - 1),
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
          onIndexChanged?.call(index);
          
          // Handle custom onTap if provided
          bottomNavItems[index].onTap?.call();
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: bottomNavItems.map((item) {
          return BottomNavigationBarItem(
            icon: _buildIcon(item, false),
            activeIcon: _buildIcon(item, true),
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildIcon(NavigationItem item, bool isActive) {
    if (item.imagePath != null) {
      return Image.asset(
        item.imagePath!,
        width: 24,
        height: 24,
        color: isActive ? Colors.red : Colors.grey,
      );
    }
    return Icon(
      item.icon,
      size: 24,
      color: isActive ? Colors.red : Colors.grey,
    );
  }
}

/// Enhanced drawer with modern design
class EnhancedMobileDrawer extends ConsumerWidget {
  final List<NavigationItem> items;
  final Widget? header;
  final Function(int)? onIndexChanged;
  final VoidCallback? onClose;
  
  const EnhancedMobileDrawer({
    Key? key,
    required this.items,
    this.header,
    this.onIndexChanged,
    this.onClose,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    
    return Drawer(
      child: Column(
        children: [
          // Header
          if (header != null) header!,
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ref.read(navigationIndexProvider.notifier).state = index;
                        onIndexChanged?.call(index);
                        item.onTap?.call();
                        onClose?.call();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (item.imagePath != null)
                              Image.asset(
                                item.imagePath!,
                                width: 24,
                                height: 24,
                                color: isSelected ? Colors.red : Colors.black54,
                              )
                            else
                              Icon(
                                item.icon,
                                size: 24,
                                color: isSelected ? Colors.red : Colors.black54,
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.red : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating action button with menu
class MobileFABMenu extends StatefulWidget {
  final List<FABMenuItem> items;
  final IconData mainIcon;
  final Color? backgroundColor;
  
  const MobileFABMenu({
    Key? key,
    required this.items,
    this.mainIcon = Icons.add,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  State<MobileFABMenu> createState() => _MobileFABMenuState();
}

class _MobileFABMenuState extends State<MobileFABMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Menu items
        ..._buildMenuItems(),
        
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: widget.backgroundColor ?? Colors.red,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animation,
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildMenuItems() {
    final items = <Widget>[];
    
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      items.add(
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                _animation.value * -(56.0 * (i + 1)),
              ),
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.label != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () {
                    _toggle();
                    item.onTap();
                  },
                  backgroundColor: item.backgroundColor ?? Colors.red.shade400,
                  child: Icon(
                    item.icon,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return items;
  }
}

/// FAB menu item model
class FABMenuItem {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  
  const FABMenuItem({
    required this.icon,
    this.label,
    required this.onTap,
    this.backgroundColor,
  });
}