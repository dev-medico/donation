import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class MoneyDonorDataSource extends DataGridSource {
  MoneyDonorDataSource({required List<MoneyDonor> donorData}) {
    _donorData = donorData
        .asMap()
        .entries
        .map<DataGridRow>((entry) {
          final index = entry.key;
          final donor = entry.value;
          return DataGridRow(cells: [
            DataGridCell<int>(columnName: 'id', value: index + 1), // Show row number instead of actual ID
            DataGridCell<String>(columnName: 'name', value: donor.name ?? ''),
            DataGridCell<String>(columnName: 'phone', value: donor.phone ?? ''),
            DataGridCell<String>(columnName: 'totalAmount', value: _formatAmount(donor.totalAmount)),
            DataGridCell<int>(columnName: 'donationCount', value: donor.donationCount ?? 0),
            DataGridCell<String>(columnName: 'address', value: donor.address ?? ''),
          ]);
        })
        .toList();
  }

  List<DataGridRow> _donorData = [];

  @override
  List<DataGridRow> get rows => _donorData;

  String _formatAmount(double? amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      final columnName = dataGridCell.columnName;
      final value = dataGridCell.value.toString();

      // Special handling for total amount column
      if (columnName == 'totalAmount') {
        return Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$value ကျပ်',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.green[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }

      // Determine alignment based on column type
      Alignment alignment = Alignment.centerLeft;
      if (columnName == 'id' || columnName == 'donationCount') {
        alignment = Alignment.center;
      }

      // Add padding based on column
      EdgeInsets padding = const EdgeInsets.all(8.0);
      if (columnName == 'address') {
        padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
      }

      return Container(
        alignment: alignment,
        padding: padding,
        child: Text(
          value,
          overflow: columnName == 'name' ? TextOverflow.visible : TextOverflow.ellipsis,
          softWrap: columnName == 'name',
          maxLines: columnName == 'name' ? 2 : 1,
          style: TextStyle(
            fontWeight: columnName == 'name' ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      );
    }).toList());
  }
}
