import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: YourNotifications(),
      ),
    );
  }
}

class YourNotifications extends StatelessWidget {
  const YourNotifications({Key? key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authenticatedUserEmail = user != null ? user.email : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Employee/Notifications/notification')
            .where('loginId', isEqualTo: authenticatedUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notifications = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index].data();

                final title = notification['title'] as String?;
                final message = notification['message'] as String?;

                return Card(
                  child: ListTile(
                    title: Text(title ?? ''),
                    subtitle: Text(message ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Delete the notification from the collection
                        FirebaseFirestore.instance
                            .collection('Employee/Notifications/notification')
                            .doc(notifications[index].id)
                            .delete();
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return CircularProgressIndicator(); // Show a loading indicator
        },
      ),
    );
  }
}
