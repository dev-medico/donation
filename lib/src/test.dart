// import 'package:flutter/material.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// /// The home page of the application which hosts the datagrid.
// class TestPagePage extends StatefulWidget {
//   /// Creates the home page.
//   const TestPagePage({Key? key}) : super(key: key);

//   @override
//   _TestPagePageState createState() => _TestPagePageState();
// }

// class _TestPagePageState extends State<TestPagePage> {
//   List<Employee> employees = <Employee>[];
//   late EmployeeDataSource employeeDataSource;

//   @override
//   void initState() {
//     super.initState();
//     employees = getEmployeeData();
//     employeeDataSource = EmployeeDataSource(employeeData: employees);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Syncfusion Flutter DataGrid'),
//       ),
//       body: SfDataGrid(
//         source: employeeDataSource,
//         gridLinesVisibility: GridLinesVisibility.both,
//         headerGridLinesVisibility: GridLinesVisibility.both,
//         columnWidthMode: ColumnWidthMode.auto,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'id',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(16.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'ID',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'name',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Name',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'designation',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Designation Name',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'salary',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Salary Long Term',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'salary',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Salary Short Term',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//         ],
//       ),
//     );
//   }

//   List<Employee> getEmployeeData() {
//     return [
//       Employee(
//           10001, 'James', 'Project Lead Data Managner For Long Term', 20000),
//       Employee(10002, 'Kathryn', 'Manager', 30000),
//       Employee(10003, 'Lara', 'Developer', 15000),
//       Employee(10004, 'Michael', 'Designer', 15000),
//       Employee(10005, 'Martin', 'Developer', 15000),
//       Employee(10006, 'Newberry', 'Developer', 15000),
//       Employee(10007, 'Balnc', 'Developer', 15000),
//       Employee(10008, 'Perry', 'Developer', 15000),
//       Employee(10009, 'Gable', 'Developer', 15000),
//       Employee(10010, 'Grimes', 'Developer', 15000),
//       Employee(
//           10001, 'James', 'Project Lead Data Managner For Long Term', 20000),
//       Employee(10002, 'Kathryn', 'Manager', 30000),
//       Employee(10003, 'Lara', 'Developer', 15000),
//       Employee(10004, 'Michael', 'Designer', 15000),
//       Employee(10005, 'Martin', 'Developer', 15000),
//       Employee(10006, 'Newberry', 'Developer', 15000),
//       Employee(10007, 'Balnc', 'Developer', 15000),
//     ];
//   }
// }

// /// Custom business object class which contains properties to hold the detailed
// /// information about the employee which will be rendered in datagrid.
// class Employee {
//   /// Creates the employee class with required details.
//   Employee(this.id, this.name, this.designation, this.salary);

//   /// Id of an employee.
//   final int id;

//   /// Name of an employee.
//   final String name;

//   /// Designation of an employee.
//   final String designation;

//   /// Salary of an employee.
//   final int salary;
// }

// /// An object to set the employee collection data source to the datagrid. This
// /// is used to map the employee data to the datagrid widget.
// class EmployeeDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   EmployeeDataSource({required List<Employee> employeeData}) {
//     _employeeData = employeeData
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//               DataGridCell<int>(columnName: 'id', value: e.id),
//               DataGridCell<String>(columnName: 'name', value: e.name),
//               DataGridCell<String>(
//                   columnName: 'designation', value: e.designation),
//               DataGridCell<int>(columnName: 'salary', value: e.salary),
//               DataGridCell<int>(columnName: 'salary', value: e.salary),
//             ]))
//         .toList();
//   }

//   List<DataGridRow> _employeeData = [];

//   @override
//   List<DataGridRow> get rows => _employeeData;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//       return Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.all(8.0),
//         child: Text(e.value.toString()),
//       );
//     }).toList());
//   }
// }

