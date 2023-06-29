import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUser extends StatelessWidget {
  const ManageUser({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final userData = users[index].data() as Map<String, dynamic>?;

                if (userData != null) {
                  final email = userData['email']?.toString();
                  final name = userData['name']?.toString();

                  return ListTile(
                    title: Text('${name ?? ''} (${email ?? ''})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Handle delete action for the corresponding user
                        _deleteUser(users[index].reference);
                      },
                    ),
                  );
                } else {
                  return const SizedBox(); // Placeholder for empty data
                }
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error retrieving users');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteUser(DocumentReference? userRef) async {
    if (userRef == null) {
      return;
    }

    try {
      await userRef.delete();
      print('User deleted successfully');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
