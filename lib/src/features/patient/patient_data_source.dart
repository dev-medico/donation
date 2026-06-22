import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientDataSource extends DataGridSource {
  PatientDataSource({required List<Patient> patientData}) {
    _patientData = patientData
        .asMap()
        .entries
        .map<DataGridRow>((entry) {
          final index = entry.key;
          final patient = entry.value;
          return DataGridRow(cells: [
              DataGridCell<int>(columnName: 'no', value: index + 1), // Serial number starts from 1
              DataGridCell<String>(columnName: 'name', value: patient.name ?? ''),
              DataGridCell<String>(columnName: 'phone', value: patient.phone ?? ''),
              DataGridCell<String>(columnName: 'gender', value: _getGenderDisplay(patient.gender)),
              DataGridCell<String>(columnName: 'bloodType', value: patient.bloodType ?? '-'),
              DataGridCell<String>(columnName: 'age', value: displayAge(patient.birthDate, fallbackAge: patient.age, detailed: false)),
              DataGridCell<String>(columnName: 'address', value: patient.address ?? ''),
              DataGridCell<int>(columnName: 'donationCount', value: patient.donationCount ?? 0),
            ]);
        })
        .toList();
  }

  List<DataGridRow> _patientData = [];

  @override
  List<DataGridRow> get rows => _patientData;

  String _getGenderDisplay(String? gender) {
    if (gender == null || gender.isEmpty) return '-';
    switch (gender.toLowerCase()) {
      case 'male':
        return 'ကျား';
      case 'female':
        return 'မ';
      default:
        return gender;
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      final columnName = dataGridCell.columnName;
      final value = dataGridCell.value.toString();

      // Special handling for gender column
      if (columnName == 'gender' && value.isNotEmpty && value != '-') {
        final isMale = value == 'ကျား';
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isMale ? Colors.blue.shade700 : Colors.pink.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }

      // Special handling for blood type column
      if (columnName == 'bloodType' && value.isNotEmpty && value != '-') {
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
      if (columnName == 'no' || columnName == 'age' || columnName == 'donationCount') {
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
        // No ellipsis: let long Myanmar names/addresses wrap so they stay fully
        // visible. The grid grows the row to fit via onQueryRowHeight.
        child: Text(
          value,
          style: TextStyle(
            fontWeight: columnName == 'name' ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      );
    }).toList());
  }
}
