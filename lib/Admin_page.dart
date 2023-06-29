import 'package:flutter/material.dart';
import 'package:untitled3/manage_users.dart';
import 'package:untitled3/permissions.dart';

import 'manage_emp.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageUser()));
              // Handle onTap for managing users
            },
          ),
          ListTile(
            title: const Text('Manage Employees'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageEmp()));
              // Handle onTap for managing employees
            },
          ),
          ListTile(
            title: const Text('Permissions'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Permission()));
              // Handle onTap for managing permissions
            },
          ),
        ],
      ),
    );
  }
}

