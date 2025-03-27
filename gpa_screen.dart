import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

typedef GradeEntry = Map<String, dynamic>;

class GradeBookScreen extends StatefulWidget {
  @override
  _GradeBookScreenState createState() => _GradeBookScreenState();
}

class _GradeBookScreenState extends State<GradeBookScreen> {
  List<GradeEntry> grades = [];
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;
  TextEditingController marksController = TextEditingController();
  TextEditingController creditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final prefs = await SharedPreferences.getInstance();
    final String? gradesData = prefs.getString('grades');
    if (gradesData != null) {
      setState(() {
        grades = List<GradeEntry>.from(json.decode(gradesData));
      });
    }
  }

  Future<void> _saveGrades() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grades', json.encode(grades));
  }

  String _calculateGrade(int marks) {
    if (marks > 90) {
      return 'A';
    } else if (marks > 70) {
      return 'B';
    } else if (marks > 60) {
      return 'C';
    } else if (marks > 50) {
      return 'D';
    } else {
      return 'Fail';
    }
  }

  void _addGrade() {
    if (_formKey.currentState!.validate()) {
      final String subject = selectedSubject!;
      final int marks = int.parse(marksController.text);
      final int creditHours = int.parse(creditHoursController.text);
      final String grade = _calculateGrade(marks);

      setState(() {
        grades.add({
          'subject': subject,
          'marks': marks,
          'grade': grade,
          'creditHours': creditHours,
        });
      });
      _saveGrades();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GPAScreen(grades: grades)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gradebook')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSubject,
                    hint: Text('Select Subject'),
                    items:
                        [
                              'OOP',
                              'Software Engineering',
                              'Web Development',
                              'Mobile App Development',
                              'Operating System',
                            ]
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: marksController,
                    decoration: InputDecoration(labelText: 'Marks'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: creditHoursController,
                    decoration: InputDecoration(labelText: 'Credit Hours'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _addGrade, child: Text('Submit')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GPAScreen extends StatelessWidget {
  final List<GradeEntry> grades;
  GPAScreen({required this.grades});

  double _calculateGPA() {
    if (grades.isEmpty) return 0.0;
    double totalPoints = 0;
    double totalCredits = 0;
    Map<String, int> gradePoints = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'Fail': 0};

    for (var grade in grades) {
      totalPoints += gradePoints[grade['grade']]! * grade['creditHours'];
      totalCredits += grade['creditHours'];
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    double gpa = _calculateGPA();
    return Scaffold(
      appBar: AppBar(title: Text('GPA Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your GPA: ${gpa.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Subject')),
                    DataColumn(label: Text('Marks')),
                    DataColumn(label: Text('Grade')),
                    DataColumn(label: Text('Credit Hrs')),
                  ],
                  rows:
                      grades.map((grade) {
                        return DataRow(
                          cells: [
                            DataCell(Text(grade['subject'])),
                            DataCell(Text(grade['marks'].toString())),
                            DataCell(Text(grade['grade'])),
                            DataCell(Text(grade['creditHours'].toString())),
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
