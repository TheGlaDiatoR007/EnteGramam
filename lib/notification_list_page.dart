import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationList extends StatefulWidget {
  final String? fullName;
  final String? role;

  const NotificationList({Key? key, this.fullName, this.role}) : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          _buildBackgroundBlur(), // Background blur effect
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Employee/Notifications/notification').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              List<NotificationModel> notifications = snapshot.data!.docs.map((doc) {
                return NotificationModel(
                  title: doc['title'],
                  content: doc['content'],
                  timestamp: doc['timestamp'],
                  loginId: doc['loginId'],
                );
              }).toList();

              // Sort the notifications by timestamp in descending order
              notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return notifications.isEmpty
                  ? _buildDefaultContainer() // Show the default container
                  : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  NotificationModel notification = notifications[index];
                  bool isExpanded = _expandedIndex == index;
                  double scale = isExpanded ? 1.05 : 0.9;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Employee')
                        .where('email', isEqualTo: notification.loginId)
                        .limit(1)
                        .get()
                        .then((snapshot) => snapshot.docs.first),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                        return Container(); // Return an empty container while waiting for the future to complete
                      }

                      String? fullName = snapshot.data!['fullName'];
                      String? role = snapshot.data!['role'];

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        transform: Matrix4.identity()..scale(scale),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isExpanded ? Colors.deepPurple : Colors.black,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.timestamp.toDate().toString(),
                                        style: TextStyle(
                                          color: isExpanded ? Colors.deepPurple : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'By: $fullName',
                                        style: TextStyle(
                                          color: isExpanded ? Colors.deepPurple : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        ' ,$role',
                                        style: TextStyle(
                                          color: isExpanded ? Colors.deepPurple : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isExpanded)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text(
                                      notification.content,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlur() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.white70.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContainer() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationModel {
  final String title;
  final String content;
  final Timestamp timestamp;
  final String? loginId;

  NotificationModel({
    required this.title,
    required this.content,
    required this.timestamp,
    this.loginId,
  });
}
