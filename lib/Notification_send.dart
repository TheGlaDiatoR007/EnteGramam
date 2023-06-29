import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled3/Notification_page.dart';

class NotificationSender extends StatefulWidget {
  const NotificationSender({Key? key}) : super(key: key);

  @override
  _NotificationSenderState createState() => _NotificationSenderState();
}

class _NotificationSenderState extends State<NotificationSender> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _pdfUrlController = TextEditingController();
  TextEditingController _loginIdController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notifications'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter notification title',
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Date: ${dateFormat.format(now)}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter notification content',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _pdfUrlController,
                decoration: InputDecoration(
                  labelText: 'Attach PDF',
                  hintText: 'Choose a PDF file',
                  prefixIcon: Icon(Icons.attach_file),
                  border: OutlineInputBorder(),
                ),
                onTap: () {
                  // Handle PDF attachment logic
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _loginIdController,
                decoration: InputDecoration(
                  hintText: 'Enter login ID',
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _saveNotificationToFirestore();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      label: Text('Send'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSender()));
                        // Handle button press
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                      label: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNotificationToFirestore() async {
    String title = _titleController.text;
    String content = _contentController.text;
    String pdfUrl = _pdfUrlController.text;
    String loginId = _loginIdController.text;

    if (title.isEmpty || content.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Title and content fields cannot be empty'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return; // Stop the execution if there are empty fields
    }

    User? user = _auth.currentUser;
    if (user != null && user.email == loginId) {
      await _firestore.collection('/Employee/Notifications/notification').add({
        'title': title,
        'content': content,
        'pdfUrl': pdfUrl,
        'loginId': loginId,
        'timestamp': DateTime.now(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Notification saved to Firestore'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Login ID does not match the authenticated user'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}













