import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/DueDate.dart';

class BuildingTaxScreen extends StatefulWidget {
  const BuildingTaxScreen({Key? key}) : super(key: key);

  @override
  _BuildingTaxScreenState createState() => _BuildingTaxScreenState();
}

class _BuildingTaxScreenState extends State<BuildingTaxScreen> {
  List<String> aadharNumbers = [];
  int selectedAadharIndex = 0;
  TextEditingController taxValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _retrieveAadharNumbers();
  }

  Future<void> _retrieveAadharNumbers() async {
    final userQuerySnapshot = await FirebaseFirestore.instance.collection('Users').get();

    final List<String> numbers = userQuerySnapshot.docs
        .map((doc) => doc.data()['aadharNumber'].toString())
        .toList();

    setState(() {
      aadharNumbers = numbers;
    });
  }

  void selectAadharNumber(String number) {
    final selectedIndex = aadharNumbers.indexOf(number);
    if (selectedIndex != -1) {
      setState(() {
        selectedAadharIndex = selectedIndex;
      });
    } else {
      print('Number not found: $number');
    }
  }

  void saveDataToFirebase() {
    final enteredValue = taxValueController.text;
    final aadharNumber = aadharNumbers[selectedAadharIndex];

    final taxData = {
      'aadharNumber': aadharNumber,
      'tax': enteredValue,
    };

    FirebaseFirestore.instance
        .collection('Buildingtax')
        .where('aadharNumber', isEqualTo: aadharNumber)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        FirebaseFirestore.instance
            .collection('Buildingtax')
            .doc(docId)
            .update(taxData)
            .then((_) {
          print('Tax data updated successfully: $taxData');
          moveToNextAadharNumber();
        }).catchError((error) {
          print('Error updating tax data: $error');
        });
      } else {
        FirebaseFirestore.instance
            .collection('Buildingtax')
            .add(taxData)
            .then((_) {
          print('Tax data stored successfully: $taxData');
          moveToNextAadharNumber();
        }).catchError((error) {
          print('Error storing tax data: $error');
        });
      }
    }).catchError((error) {
      print('Error retrieving tax data: $error');
    });

    // Clear the text field
    taxValueController.clear();
  }

  void moveToNextAadharNumber() {
    if (selectedAadharIndex < aadharNumbers.length - 1) {
      setState(() {
        selectedAadharIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BuildingTax'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aadhar Numbers:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: aadharNumbers.length,
                itemBuilder: (context, index) {
                  final number = aadharNumbers[index];
                  final isSelected = index == selectedAadharIndex;

                  return ListTile(
                    title: Text(
                      number,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      selectAadharNumber(number);
                    },
                  );
                },
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selected Aadhar Number:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      aadharNumbers.isNotEmpty ? aadharNumbers[selectedAadharIndex] ?? '' : '',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Enter tax value:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: taxValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter tax money',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              saveDataToFirebase();
                            },
                            child: Text('Save'),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DueDatePage()));
                              // Handle 'Set Due Date' button action
                            },
                            child: Text('Set Due Date'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
