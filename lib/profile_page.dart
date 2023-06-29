import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:untitled3/profiledetails.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const ProfileScreen({required this.profileData, Key? key}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

final nameController = TextEditingController();
final emailController = TextEditingController();
final mobileController = TextEditingController();
final roleController = TextEditingController();
final mailController = TextEditingController();

class _ProfileScreenState extends State<ProfileScreen> {
  String? profilePic;
  final picker = ImagePicker();
  late File _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  Future pickImage() async {
    await _fetchUserProfile(); // Fetch existing data
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        profilePic = pickedFile.path;
      });
    }
  }

  Future uploadImage() async {
    if (_image != null) {
      String fileName = FirebaseAuth.instance.currentUser!.uid + ".png";
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child(fileName);
      firebase_storage.UploadTask uploadTask = ref.putFile(_image);

      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        // Save the image URL to the user's profile document

        FirebaseFirestore.instance
            .collection('Employee')
            .where('email',
            isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .limit(1)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final documentSnapshot = querySnapshot.docs.first;
            documentSnapshot.reference.update({
              'profilePic': imageUrl,
            }).then((_) {
              print("Profile picture updated successfully!");
            }).catchError((error) {
              print("Error updating profile picture: $error");
            });
          }
        });
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userProfile = UserProfile.fromSnapshot(snapshot.docs.first);
      nameController.text = userProfile.fullName ?? '';
      mobileController.text = userProfile.phoneNo ?? '';
      roleController.text = userProfile.role ?? '';
      mailController.text = userProfile.mail ?? '';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your profile'),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    await pickImage();
                  },
                  child: Container(
                    child: profilePic == null
                        ? CircleAvatar(
                      radius: 70,
                      child: Image.asset(
                        'assets/man.png',
                        height: 80,
                        width: 80,
                      ),
                    )
                        : CircleAvatar(
                      radius: 70,
                      backgroundImage: FileImage(File(profilePic!)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildTextField(
                  "Name", "Enter your full name", nameController, null),
              buildTextField(
                  "Phone No", "Enter your phone no", mobileController, null),
              buildTextField("Role", "Enter your role", roleController, null),
              buildTextField("Mail", "Enter Mail", mailController, null),
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
                      uploadImage();


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
        'fullName': nameController.text,
        'mail': mailController.text,
        'phoneNo': mobileController.text,
        'role': roleController.text,
      });
    }
    Navigator.pop(context); // Return to the previous screen
  } catch (e) {
    print('Error updating user profile: $e');
    // Handle the error or show an error message to the user
  }
}
class UserProfile {
  final String fullName;
  final String mail;
  final String phoneNo;
  final String role;

  UserProfile({
    required this.fullName,
    required this.mail,
    required this.phoneNo,
    required this.role,
  });

  factory UserProfile.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      fullName: data['fullName'] ?? '',
      mail: data['mail'] ?? '',
      phoneNo: data['phoneNo'] ?? '',
      role: data['role'] ?? '',
    );
  }
}