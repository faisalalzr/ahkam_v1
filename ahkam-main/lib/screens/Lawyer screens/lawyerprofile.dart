import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/editlawprofile.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerHomeScreen.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerMessages.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerWalletScreen.dart';
import 'package:ahakam_v8/screens/login.dart';
import 'package:ahakam_v8/widgets/reviewWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class lawyerProfileScreen extends StatefulWidget {
  final Lawyer lawyer;
  const lawyerProfileScreen({super.key, required this.lawyer});

  @override
  State<lawyerProfileScreen> createState() => _lawyerProfileScreenState();
}

class _lawyerProfileScreenState extends State<lawyerProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var _selectedIndex = 0;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getInfo() async {
    try {
      var querySnapshot = await firestore
          .collection('account')
          .where('email', isEqualTo: widget.lawyer.email)
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

  void onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.off(
          () => lawyerProfileScreen(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 1:
        Get.off(
          () => LawyerWalletScreen(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 2:
        Get.off(
          () => Lawyermessages(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 3:
        Get.off(
          () => LawyerHomeScreen(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: GoogleFonts.poppins(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Get.to(
                () => EditLawyerProfileScreen(lawyer: widget.lawyer),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageCircle),
            label: "Chat",
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Error loading profile data."));
          }

          final userData = snapshot.data!.data() ?? {};

          return LiquidPullToRefresh(
            onRefresh: () async {
              setState(() {}); // Re-fetch the data
              await Future.delayed(Duration(milliseconds: 300));
            },
            color: const Color.fromARGB(151, 0, 35, 96),
            backgroundColor: Colors.white,
            height: 140,
            animSpeedFactor: 2,
            showChildOpacityTransition: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    (userData['imageUrl'] != null &&
                                            userData['imageUrl'].isNotEmpty)
                                        ? NetworkImage(userData['imageUrl'])
                                        : const AssetImage(
                                            'assets/images/brad.webp',
                                          ) as ImageProvider,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData['name'],
                                      style: GoogleFonts.lato(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      userData['specialization'] ?? 'Unknown',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 13),
                          Divider(height: 24, thickness: 1.2),
                          _infoRow(
                            Icons.work_history,
                            'Years of Experience: ${userData['exp']}',
                          ),
                          _infoRow(
                            Icons.location_city,
                            'Province: ${userData['province']}',
                          ),
                          _infoRow(
                            Icons.monetization_on,
                            'Consultation Fee: \$${userData['fees']}',
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            userData['desc'] ?? 'No description available.',
                            style: GoogleFonts.lato(fontSize: 14, height: 1.5),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard("Balance", "0.0", LucideIcons.wallet),
                      _buildStatCard("Cases", "${userData['cases']}",
                          LucideIcons.folderArchive),
                      _buildStatCard(
                          "Rating", "${userData['rating']}", LucideIcons.star),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Reviews',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LawyerReviewsWidget(lawyerId: widget.lawyer.uid!),
                  SizedBox(height: 50),

                  // Options
                  _buildOptionCard(
                    LucideIcons.fileArchive,
                    "Your cases",
                    () {},
                  ),
                  _buildOptionCard(Icons.payment, "Payment", () {}),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.off(() => LoginScreen());
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.redAccent.withOpacity(0.05),
                        shadowColor: Colors.redAccent.withOpacity(0.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color ?? Colors.black87),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Color(0xFF1E3A5F), size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String label, VoidCallback? onTap) {
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF1E3A5F)),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
