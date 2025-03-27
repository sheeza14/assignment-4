import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class GPAListScreen extends StatefulWidget {
  final Database database;

  GPAListScreen({required this.database});

  @override
  _GPAListScreenState createState() => _GPAListScreenState();
}

class _GPAListScreenState extends State<GPAListScreen> {
  List<Map<String, dynamic>> gpaRecords = [];
  double calculatedGPA = 0.0;

  @override
  void initState() {
    super.initState();
    _loadGPARecords();
  }

  Future<void> _loadGPARecords() async {
    final List<Map<String, dynamic>> maps = await widget.database.query(
      'grades',
    );
    setState(() {
      gpaRecords = maps;
      _calculateGPA();
    });
  }

  double _getGPAPoints(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0;
    }
  }

  void _calculateGPA() {
    double totalPoints = 0;
    int totalCreditHours = 0;

    for (var record in gpaRecords) {
      double gradePoints = _getGPAPoints(record['grade']);
      int creditHours = record['creditHours'];

      totalPoints += gradePoints * creditHours;
      totalCreditHours += creditHours;
    }

    if (totalCreditHours > 0) {
      setState(() {
        calculatedGPA = totalPoints / totalCreditHours;
      });
    } else {
      setState(() {
        calculatedGPA = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GPA Records')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your GPA: ${calculatedGPA.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  gpaRecords.isEmpty
                      ? Center(child: Text('No data available'))
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue,
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Subject',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Marks',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Grade',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Credit Hrs',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          rows:
                              gpaRecords.map((record) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(record['subject'])),
                                    DataCell(Text('${record['marks']}')),
                                    DataCell(Text(record['grade'])),
                                    DataCell(Text('${record['creditHours']}')),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
