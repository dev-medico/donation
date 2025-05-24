import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class SpecialEventDataSource extends DataGridSource {
  /// Creates the special event data source class with required details.
  SpecialEventDataSource({required List<dynamic> eventData}) {
    for (int i = 0; i < eventData.length; i++) {
      final event = eventData[i];

      // Parse date safely
      String dateStr;
      try {
        final dateString = event['date'].toString();
        if (dateString.contains(' ')) {
          try {
            final date = DateFormat('dd MMM yyyy').parse(dateString);
            dateStr = dateString;
          } catch (e) {
            final date = DateTime.parse(dateString);
            dateStr = DateFormat('dd MMM yyyy').format(date);
          }
        } else {
          final date = DateTime.parse(dateString);
          dateStr = DateFormat('dd MMM yyyy').format(date);
        }
      } catch (e) {
        dateStr = 'Invalid date';
      }

      _eventData.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'စဥ်', value: Utils.strToMM((i + 1).toString())),
        DataGridCell<String>(columnName: 'ရက်စွဲ', value: dateStr),
        DataGridCell<String>(
            columnName: 'Lab Name', value: event['lab_name'] ?? ''),
        DataGridCell<String>(
            columnName: 'Haemoglobin',
            value: event['haemoglobin']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'HBs Ag', value: event['hbs_ag']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'HCV Ab', value: event['hcv_ab']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'MP ICT', value: event['mp_ict']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'Retro', value: event['retro_test']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'VDRL', value: event['vdrl_test']?.toString() ?? '0'),
        DataGridCell<String>(
            columnName: 'စုစုပေါင်း', value: event['total']?.toString() ?? '0'),
      ]));
    }
  }

  final List<DataGridRow> _eventData = [];

  @override
  List<DataGridRow> get rows => _eventData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      final bool isNumber = e.columnName == 'စဥ်' ||
          e.columnName == 'Haemoglobin' ||
          e.columnName == 'HBs Ag' ||
          e.columnName == 'HCV Ab' ||
          e.columnName == 'MP ICT' ||
          e.columnName == 'Retro' ||
          e.columnName == 'VDRL' ||
          e.columnName == 'စုစုပေါင်း';

      Color? textColor;
      FontWeight? fontWeight;

      if (e.columnName == 'စုစုပေါင်း') {
        textColor = Colors.blue[700];
        fontWeight = FontWeight.bold;
      }

      return Container(
        alignment: isNumber ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      );
    }).toList());
  }
}
