import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/buildingtax.dart'; // Import the BuildingTaxScreen.dart file

class DueDatePage extends StatefulWidget {
  const DueDatePage({Key? key}) : super(key: key);

  @override
  _DueDatePageState createState() => _DueDatePageState();
}

class _DueDatePageState extends State<DueDatePage> {
  DateTime? selectedDate;
  double finePerDay = 0.0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return date != null ? formatter.format(date) : '';
  }

  void _saveDataToFirebase() {
    if (selectedDate != null && finePerDay != 0.0) {
      final data = {
        'dueDate': selectedDate,
        'finePerDay': finePerDay,
      };

      FirebaseFirestore.instance
          .collection('TaxRate') // Replace with your collection name
          .doc('AhupZ06Ku222LJQAJZPj') // Replace with the document ID you want to update
          .set(data)
          .then((_) {
        // Data updated successfully
        print('Data updated successfully: $data');

        // Go back to BuildingTaxScreen
        Navigator.pop(context);
      }).catchError((error) {
        // Error occurred while updating data
        print('Error updating data: $error');
      });
    } else {
      // Handle the case when either the due date or the fine per day is not selected/entered
      print('Please select due date and enter fine per day');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Due Date'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected Due Date:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Select due date',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: formatDate(selectedDate),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Fine Per Day:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    finePerDay = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter fine per day',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _saveDataToFirebase,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Due Date App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BuildingTaxScreen(), // Replace with the appropriate initial screen
    );
  }
}
