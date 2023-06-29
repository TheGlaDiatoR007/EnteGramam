import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/Admin_page.dart';
import 'package:untitled3/Notification_page.dart';
import 'package:untitled3/buildingtax.dart';
import 'package:untitled3/profile_page.dart';
import 'package:untitled3/login_page.dart';
import 'package:untitled3/profiledetails.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Card makeDashboardItem(String title, String image, int index, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(3.0, -1.0),
            colors: [
              Color(0xFF19C74C),
              Color(0xFFFFFFFF),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 3,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () async {
            if (index == 0) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final email = user.email;
                if (email != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileDetailsScreen(primaryKey: email)),
                  );
                }
              }
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BuildingTaxScreen()));
            } else if (index == 3) {
              if (title == "Admin Item") {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
              } else {
                // Perform sign out
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              }
            }
            else{
              FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }

          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              SizedBox(height: 50),
              Center(
                child: Image.asset(
                  image,
                  height: 50,
                  width: 50,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.9),
      body: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Employee",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "dashboard",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Admin')
                  .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // User is an admin, show the additional dashboard item
                  return GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    children: [
                      makeDashboardItem('Profile', 'assets/profile.png', 0, context),
                      makeDashboardItem('NotificationHub', 'assets/notification.png', 1, context),
                      makeDashboardItem('BuildingTax', 'assets/taxes.png', 2, context),
                      makeDashboardItem("Admin Item", 'assets/profile.png', 3, context),
                      makeDashboardItem("Sign Out", 'assets/profile.png', 4, context),
                    ],
                  );
                } else {
                  // User is not an admin, hide the additional dashboard item
                  return GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(20),
                    children: [
                      makeDashboardItem('Profile', 'assets/profile.png', 0, context),
                      makeDashboardItem('NotificationHub', 'assets/notification.png', 1, context),
                      makeDashboardItem('BuildingTax', 'assets/taxes.png', 2, context),
                      makeDashboardItem("Sign Out", 'assets/logout.png', 3, context),
                    ],
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
