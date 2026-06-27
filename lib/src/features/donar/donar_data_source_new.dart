import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

String displayDonorRecordName(dynamic donor) {
  if (donor is! Map) return '';

  final recordName = donor['name']?.toString().trim() ?? '';
  if (recordName.isNotEmpty) return recordName;

  final moneyDonor = donor['moneyDonor'];
  if (moneyDonor is Map) {
    final donorName = moneyDonor['name']?.toString().trim() ?? '';
    if (donorName.isNotEmpty) return donorName;
  }

  return '';
}

class DonarDataSource extends DataGridSource {
  /// Creates the donar data source class with required details.
  DonarDataSource({required List<dynamic> donarData}) {
    for (int i = 0; i < donarData.length; i++) {
      final donar = donarData[i];
      final date = DateTime.parse(donar['date']);

      _donarData.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'စဥ်',
            value: Utils.strToMM((i + 1).toString())),
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value: DateFormat('dd MMM yyyy').format(date)),
        DataGridCell<String>(
            columnName: 'အမည်',
            value: displayDonorRecordName(donar)),
        DataGridCell<String>(
            columnName: 'အလှူငွေ',
            value: '${Utils.strToMM(donar['amount'].toString())} ကျပ်'),
        DataGridCell<String>(
            columnName: 'edit',
            value: ''),
        DataGridCell<String>(
            columnName: 'delete',
            value: ''),
      ]));
    }
  }

  final List<DataGridRow> _donarData = [];

  @override
  List<DataGridRow> get rows => _donarData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'edit') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
            color: Colors.grey[500],
          ),
        );
      }
      if (e.columnName == 'delete') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: Colors.red[400],
          ),
        );
      }
      final bool isAmount = e.columnName == 'အလှူငွေ' || e.columnName == 'စဥ်';
      return Container(
        alignment: isAmount ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(),
          softWrap: true,
          style: TextStyle(
            color: e.columnName == 'အလှူငွေ' ? Colors.green[700] : null,
            fontWeight: e.columnName == 'အလှူငွေ' ? FontWeight.bold : null,
          ),
        ),
      );
    }).toList());
  }
}

class ExpenseDataSource extends DataGridSource {
  /// Creates the expense data source class with required details.
  ExpenseDataSource({required List<dynamic> expenseData}) {
    for (int i = 0; i < expenseData.length; i++) {
      final expense = expenseData[i];
      final date = DateTime.parse(expense['date']);

      _expenseData.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'စဥ်',
            value: Utils.strToMM((i + 1).toString())),
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value: DateFormat('dd MMM yyyy').format(date)),
        DataGridCell<String>(
            columnName: 'အကြောင်းအရာ',
            value: expense['name'] ?? ''),
        DataGridCell<String>(
            columnName: 'အသုံးစရိတ်',
            value: '${Utils.strToMM(expense['amount'].toString())} ကျပ်'),
        DataGridCell<String>(
            columnName: 'edit',
            value: ''),
        DataGridCell<String>(
            columnName: 'delete',
            value: ''),
      ]));
    }
  }

  final List<DataGridRow> _expenseData = [];

  @override
  List<DataGridRow> get rows => _expenseData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'edit') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
            color: Colors.grey[500],
          ),
        );
      }
      if (e.columnName == 'delete') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: Colors.red[400],
          ),
        );
      }
      final bool isAmount = e.columnName == 'အသုံးစရိတ်' || e.columnName == 'စဥ်';
      return Container(
        alignment: isAmount ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(),
          style: TextStyle(
            color: e.columnName == 'အသုံးစရိတ်' ? Colors.red[700] : null,
            fontWeight: e.columnName == 'အသုံးစရိတ်' ? FontWeight.bold : null,
          ),
        ),
      );
    }).toList());
  }
}
