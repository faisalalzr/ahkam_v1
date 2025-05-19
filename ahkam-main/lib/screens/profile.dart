// main_profile_screen.dart
import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/screens/editprofile.dart';
import 'package:ahakam_v8/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final Account account;

  const ProfileScreen({super.key, required this.account});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getInfo() async {
    try {
      var querySnapshot =
          await fyre
              .collection('account')
              .where('email', isEqualTo: widget.account.email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print("Error fetching profile data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Profile"),
        backgroundColor: Color.fromARGB(255, 255, 255, 254),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.to(() => EditProfileScreen(account: widget.account));
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(child: Text("Error loading profile data."));
          }

          var userData = snapshot.data!.data() ?? {};

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (userData['imageUrl'] != null &&
                                userData['imageUrl'].isNotEmpty)
                            ? NetworkImage(userData['imageUrl'])
                            : AssetImage('assets/images/brad.webp')
                                as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    userData['name'] ?? "No Name",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData['email'] ?? "No Email",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          buildInfoTile(
                            Icons.phone,
                            "Phone Number",
                            userData['number'],
                          ),
                          buildInfoTile(
                            Icons.calendar_today,
                            "Joined Date",
                            userData['joinedDate'],
                          ),
                          buildInfoTile(
                            Icons.home,
                            "Address",
                            userData['address'],
                          ),
                          buildInfoTile(Icons.info, "Bio", userData['bio']),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.off(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoTile(IconData icon, String title, String? subtitle) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title),
          subtitle: Text(
            subtitle ?? "Not provided",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Divider(),
      ],
    );
  }
}
