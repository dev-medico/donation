import 'package:flutter/material.dart';

/// Mobile-optimized card widget with various styles
class MobileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Border? border;
  
  const MobileCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.border,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: backgroundColor ?? Colors.white,
        elevation: elevation,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Member card widget for list display
class MemberCard extends StatelessWidget {
  final String name;
  final String? memberId;
  final String? bloodType;
  final String? phone;
  final String? lastDonation;
  final String? avatar;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final bool showActions;
  
  const MemberCard({
    Key? key,
    required this.name,
    this.memberId,
    this.bloodType,
    this.phone,
    this.lastDonation,
    this.avatar,
    this.onTap,
    this.onCall,
    this.showActions = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MobileCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              image: avatar != null
                  ? DecorationImage(
                      image: NetworkImage(avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatar == null
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (bloodType != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bloodType!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (memberId != null)
                  Text(
                    'ID: $memberId',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (lastDonation != null)
                  Text(
                    'Last donation: $lastDonation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Actions
          if (showActions && phone != null)
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: onCall,
              splashRadius: 24,
            ),
        ],
      ),
    );
  }
}

/// Donation card widget
class DonationCard extends StatelessWidget {
  final String donorName;
  final String date;
  final String? hospital;
  final String? patientName;
  final String? bloodType;
  final String? status;
  final VoidCallback? onTap;
  
  const DonationCard({
    Key? key,
    required this.donorName,
    required this.date,
    this.hospital,
    this.patientName,
    this.bloodType,
    this.status,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MobileCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bloodtype, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  donorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(status!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, date),
          if (hospital != null)
            _buildInfoRow(Icons.local_hospital, hospital!),
          if (patientName != null)
            _buildInfoRow(Icons.person, 'Patient: $patientName'),
          if (bloodType != null)
            _buildInfoRow(Icons.opacity, bloodType!),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Event card widget
class EventCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? date;
  final String? location;
  final String? imageUrl;
  final int? participantCount;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;
  
  const EventCard({
    Key? key,
    required this.title,
    this.description,
    this.date,
    this.location,
    this.imageUrl,
    this.participantCount,
    this.onTap,
    this.onRegister,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MobileCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.event,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                if (date != null)
                  _buildEventInfo(Icons.calendar_today, date!),
                if (location != null)
                  _buildEventInfo(Icons.location_on, location!),
                if (participantCount != null)
                  _buildEventInfo(Icons.people, '$participantCount participants'),
                if (onRegister != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Register'),
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
  
  Widget _buildEventInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Finance card widget
class FinanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final String? category;
  final String? description;
  final bool isExpense;
  final VoidCallback? onTap;
  
  const FinanceCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
    this.description,
    this.isExpense = true,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MobileCard(
      onTap: onTap,
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category != null)
                  Text(
                    category!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '${isExpense ? '-' : '+'} ${amount.toStringAsFixed(0)} Ks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}