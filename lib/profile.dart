
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/profiledetails.dart';

class ProfileEdit extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const ProfileEdit({required this.profileData, Key? key}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

final timeController = TextEditingController();
final noteController = TextEditingController();


class _ProfileScreenState extends State<ProfileEdit> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }



  Future<void> _fetchUserProfile() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userProfile = UserProfile.fromSnapshot(snapshot.docs.first);
      timeController.text = userProfile.WorkingSchedule ?? '';
      noteController.text = userProfile.notes ?? '';

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: [
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              buildTextField(
                  "WorkingSchedule", "Enter your Working Schedule", timeController, null),
              buildTextField(
                  "notes","Enter any reminding notes", noteController, null),

              Row(
                children: [
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailsScreen(primaryKey: ""),
                        ),
                      );
                    },
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      _saveChanges(context); // Pass the context parameter



                    },

                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.2,
                        color: Colors.black,
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
}

Widget buildTextField(
    String labelText,
    String placeholder,
    TextEditingController controller,
    String? initialValue,
    ) {
  controller.text = initialValue ?? '';

  return Padding(
    padding: const EdgeInsets.all(35.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(bottom: 3),
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: placeholder,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
      readOnly: false,
      showCursor: true,
    ),
  );
}


Future<void> _saveChanges(BuildContext context) async {
  try {
    String email = FirebaseAuth.instance.currentUser?.email ?? '';

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      await documentSnapshot.reference.update({
        'WorkingSchedule': timeController.text,
        'notes': noteController.text,

      });
    }
    Navigator.pop(context); // Return to the previous screen
  } catch (e) {
    print('Error updating user profile: $e');
    // Handle the error or show an error message to the user
  }
}
class UserProfile {
  final String WorkingSchedule;
  final String notes;
  UserProfile({
    required this.WorkingSchedule,
    required this.notes,

  });

  factory UserProfile.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      WorkingSchedule: data['WorkingSchedule'] ?? '',
      notes: data['notes'] ?? '',

    );
  }
}