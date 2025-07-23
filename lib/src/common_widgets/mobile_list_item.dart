import 'package:flutter/material.dart';

/// Mobile-optimized list item with various styles
class MobileListItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool dense;
  final Color? backgroundColor;
  final Color? selectedColor;
  final bool selected;
  
  const MobileListItem({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.dense = false,
    this.backgroundColor,
    this.selectedColor,
    this.selected = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected 
          ? (selectedColor ?? Colors.red.withValues(alpha: 0.1))
          : (backgroundColor ?? Colors.transparent),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: padding ?? 
              EdgeInsets.symmetric(
                horizontal: 16,
                vertical: dense ? 8 : 12,
              ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: dense ? 12 : 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: dense ? 14 : 16,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: dense ? 12 : 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: dense ? 12 : 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipeable list item with actions
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final double actionExtentRatio;
  
  const SwipeableListItem({
    Key? key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.actionExtentRatio = 0.25,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (leftActions == null && rightActions == null) {
      return child;
    }
    
    return Dismissible(
      key: UniqueKey(),
      background: _buildBackground(leftActions, true),
      secondaryBackground: _buildBackground(rightActions, false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onSwipeLeft?.call();
        } else {
          onSwipeRight?.call();
        }
        return false; // Don't actually dismiss
      },
      child: child,
    );
  }
  
  Widget? _buildBackground(List<SwipeAction>? actions, bool isLeft) {
    if (actions == null || actions.isEmpty) return null;
    
    return Container(
      color: actions.first.backgroundColor,
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action.icon,
                  color: action.iconColor ?? Colors.white,
                ),
                if (action.label != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.label!,
                    style: TextStyle(
                      color: action.iconColor ?? Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Swipe action model
class SwipeAction {
  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final Color? iconColor;
  final VoidCallback onTap;
  
  const SwipeAction({
    required this.icon,
    this.label,
    required this.backgroundColor,
    this.iconColor,
    required this.onTap,
  });
}

/// Empty state widget
class MobileEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  
  const MobileEmptyState({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(height: 24),
          ] else ...[
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section header for lists
class MobileSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  
  const MobileSectionHeader({
    Key? key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey.shade100,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading list item placeholder
class MobileLoadingListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final EdgeInsetsGeometry? padding;
  
  const MobileLoadingListItem({
    Key? key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showAvatar) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}