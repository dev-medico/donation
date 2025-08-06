import 'package:donation/src/features/patient/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/utils/utils.dart';

class PatientDataSource extends DataGridSource {
  PatientDataSource({required List<Patient> patientData}) {
    _patientData = patientData
        .map<DataGridRow>((patient) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'လူနာအမည်', value: patient.patientName ?? ''),
              DataGridCell<String>(
                  columnName: 'အသက်', value: patient.patientAge ?? ''),
              DataGridCell<String>(
                  columnName: 'ရောဂါ', value: patient.patientDisease ?? ''),
              DataGridCell<String>(
                  columnName: 'ဆေးရုံ', value: patient.hospital ?? ''),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: patient.bloodGroup ?? ''),
              DataGridCell<String>(
                  columnName: 'လိပ်စာ', value: patient.patientAddress ?? ''),
              DataGridCell<int>(
                  columnName: 'လှူဒါန်းမှု', value: patient.donationCount ?? 0),
              DataGridCell<String>(
                  columnName: 'နောက်ဆုံးလှူဒါန်းသည့်ရက်',
                  value: _formatDate(patient.latestDonationDate)),
            ]))
        .toList();
  }

  List<DataGridRow> _patientData = [];

  @override
  List<DataGridRow> get rows => _patientData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      final columnName = dataGridCell.columnName;
      final value = dataGridCell.value.toString();
      
      // Special handling for blood group column
      if (columnName == 'သွေးအုပ်စု' && value.isNotEmpty && value != '-') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
      
      // Determine alignment based on column type
      Alignment alignment = Alignment.centerLeft;
      if (columnName == 'အသက်' || columnName == 'လှူဒါန်းမှု') {
        alignment = Alignment.center;
      } else if (columnName == 'နောက်ဆုံးလှူဒါန်းသည့်ရက်') {
        alignment = Alignment.center;
      }

      // Add padding based on column
      EdgeInsets padding = const EdgeInsets.all(8.0);
      if (columnName == 'လိပ်စာ' || columnName == 'ရောဂါ') {
        padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
      }

      return Container(
        alignment: alignment,
        padding: padding,
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: columnName == 'လူနာအမည်'
                ? FontWeight.w600
                : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      );
    }).toList());
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}