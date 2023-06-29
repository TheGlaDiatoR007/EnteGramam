import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled3/home_page.dart';
import 'package:untitled3/profile.dart';
import 'package:untitled3/profile_page.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String primaryKey;

  const ProfileDetailsScreen({required this.primaryKey, Key? key}) : super(key: key);

  @override
  _ProfileDetailsScreenState createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _profileStream;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color of the screen
      body: FutureBuilder<void>(
        future: fetchUserEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            _profileStream = FirebaseFirestore.instance
                .collection("Employee")
                .where("email", isEqualTo: userEmail)
                .snapshots();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Padding(
                  padding:  EdgeInsets.all(16.0),

                  child: Text(
                    'Profile Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: buildProfileDetails(),
                ),
              ],
            );
          }
        },
      ),
    );
  }


  Future<void> fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email!;
      });
    }
  }
  Widget buildProfileDetails() {
    if (userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final profileData = snapshot.data!.docs.first.data();

              if (profileData != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (profileData['profilePic'] != null)
                              CircleAvatar(
                                radius: 65,
                                backgroundImage: NetworkImage(profileData['profilePic']),
                              ),
                            if (profileData['profilePic'] == null)
                              CircleAvatar(
                                radius: 65,
                                child: Image.asset(
                                  'assets/man.png',
                                  height: 70,
                                  width: 70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profileData['fullName'] ?? ''}',
                                style:const  TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildProfileField('Phone No:', '${profileData['phoneNo'] ?? ''}'),
                              const Divider(),
                              const SizedBox(height: 10),
                              buildProfileField('Email:', '${profileData['mail'] ?? ''}'),
                              const Divider(),
                              const SizedBox(height: 25),
                              buildProfileField('Role:', '${profileData['role'] ?? ''}'),
                              const Divider(),
                              const SizedBox(height: 25),
                              buildProfileField('Working Schedule:', '${profileData['WorkingSchedule'] ?? ''}'),
                              const Divider(),
                              const SizedBox(height: 20),
                              buildProfileField('Notes:', '${profileData['notes'] ?? ''}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 65),
                        buildProfileAction(
                          Icons.lock_clock,
                          Colors.greenAccent,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileEdit(profileData: profileData)),
                            );
                          },
                        ),
                        const SizedBox(width: 40),
                        buildProfileAction(
                          Icons.home_outlined,
                          Colors.greenAccent,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
                        ),
                       const  SizedBox(width: 40),
                        buildProfileAction(
                          Icons.person,
                          Colors.greenAccent,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen(profileData: profileData)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }
  }

  Widget buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget buildProfileAction(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
      ),
    );
  }

}

