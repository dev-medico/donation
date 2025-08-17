// import 'package:flutter/material.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:intl/intl.dart';

import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class SearchMemberDataSource extends DataGridSource {
  final List<Member> members;
  
  SearchMemberDataSource({required List<Member> memberData}) : members = memberData {
    _memberData = memberData
        .map<DataGridRow>((member) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'အမှတ်စဥ်', value: member.memberId ?? ''),
              DataGridCell<String>(
                  columnName: 'အမည်', value: member.name ?? ''),
              DataGridCell<String>(
                  columnName: 'အဖအမည်', value: member.fatherName ?? ''),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: member.bloodType ?? ''),
              DataGridCell<String>(
                  columnName: 'ဖုန်းနံပါတ်', value: member.phone ?? ''),
              DataGridCell<String>(
                  columnName: 'နောက်ဆုံးလှူဒါန်းသည့်ရက်', value: member.lastDate ?? ''),
              DataGridCell<String>(
                  columnName: 'အခြေအနေ', value: member.status ?? 'available'),
              DataGridCell<String>(
                  columnName: 'မှတ်ချက်', value: member.note ?? ''),
            ]))
        .toList();
  }

  List<DataGridRow> _memberData = [];
  
  // Helper function to check if donation is within 4 months
  bool _isRecentDonation(String? lastDateStr) {
    if (lastDateStr == null || lastDateStr.isEmpty) return false;
    
    try {
      // Try to parse the date string (handles various formats)
      DateTime? lastDate;
      
      // Try parsing ISO format with time
      if (lastDateStr.contains('T') || lastDateStr.contains(' ')) {
        lastDate = DateTime.tryParse(lastDateStr);
      }
      
      // If that fails, try other formats
      if (lastDate == null) {
        // Try "yyyy-MM-dd HH:mm:ss" format
        try {
          lastDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(lastDateStr);
        } catch (e) {
          // Try other formats if needed
        }
      }
      
      if (lastDate != null) {
        final now = DateTime.now();
        final fourMonthsAgo = DateTime(now.year, now.month - 4, now.day);
        return lastDate.isAfter(fourMonthsAgo) || lastDate.isAtSameMomentAs(fourMonthsAgo);
      }
    } catch (e) {
      // If parsing fails, return false
    }
    
    return false;
  }
  
  // Format date string to show only date part
  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    
    try {
      DateTime? date;
      
      // Try parsing ISO format with time
      if (dateStr.contains('T') || dateStr.contains(' ')) {
        date = DateTime.tryParse(dateStr);
      }
      
      // If that fails, try specific format
      if (date == null) {
        try {
          date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
        } catch (e) {
          // Return original if can't parse
          return dateStr;
        }
      }
      
      if (date != null) {
        // Format as "yyyy MMM dd" (e.g., "2024 May 08")
        return DateFormat('yyyy MMM dd').format(date);
      }
    } catch (e) {
      // If parsing fails, return original
    }
    
    return dateStr;
  }

  @override
  List<DataGridRow> get rows => _memberData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // Get the row index to find the corresponding member
    final rowIndex = _memberData.indexOf(row);
    if (rowIndex < 0 || rowIndex >= members.length) {
      return null;
    }
    
    final member = members[rowIndex];
    final isRecentDonation = _isRecentDonation(member.lastDate);
    
    return DataGridRowAdapter(
        color: isRecentDonation ? Colors.red.shade50 : null,
        cells: row.getCells().map<Widget>((dataGridCell) {
      // Apply background color for recent donations
      final cellBackgroundColor = isRecentDonation ? Colors.red.shade50 : null;
      
      // Special handling for status column
      if (dataGridCell.columnName == 'အခြေအနေ') {
        final status = dataGridCell.value.toString();
        final isAvailable = status == 'available';
        return Container(
          color: cellBackgroundColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAvailable ? Colors.green.shade300 : Colors.red.shade300,
                width: 1,
              ),
            ),
            child: Text(
              isAvailable ? 'လှူနိုင်' : 'မလှူနိုင်',
              style: TextStyle(
                color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
      
      // Special handling for note column - show full text with ellipsis
      if (dataGridCell.columnName == 'မှတ်ချက်') {
        final note = dataGridCell.value.toString();
        return Container(
          color: cellBackgroundColor,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(4.0),
          child: Tooltip(
            message: note.isNotEmpty ? note : 'မှတ်ချက်မရှိ',
            child: Text(
              note.isNotEmpty ? note : '-',
              style: TextStyle(
                fontSize: 12,
                color: note.isNotEmpty ? Colors.black87 : Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      }
      
      // Special handling for last donation date
      if (dataGridCell.columnName == 'နောက်ဆုံးလှူဒါန်းသည့်ရက်') {
        final dateStr = dataGridCell.value.toString();
        final formattedDate = _formatDateString(dateStr);
        
        return Container(
          color: cellBackgroundColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Text(
            formattedDate.isNotEmpty ? formattedDate : '-',
            style: TextStyle(
              fontSize: 12,
              color: formattedDate.isNotEmpty ? Colors.black87 : Colors.grey,
              fontWeight: isRecentDonation ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
      
      // Default handling for other columns
      return Container(
        color: cellBackgroundColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList());
  }
}
