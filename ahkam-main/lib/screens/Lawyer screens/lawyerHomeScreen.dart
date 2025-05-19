import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawSuitDetails.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/inbox.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerprofile.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/morelawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerWalletScreen.dart';
import 'package:ahakam_v8/screens/about.dart';
import 'package:ahakam_v8/screens/Lawyer screens/lawyerMessages.dart';
import 'package:ahakam_v8/screens/disclaimerPage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/lawsuitcard.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key, required this.lawyer});
  final Lawyer lawyer;

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _selectedIndex = 3;
  String? selectedStatus = 'Active';

  Future<List<Map<String, dynamic>>> fetchThisLawyer() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('account')
        .where('uid', isEqualTo: widget.lawyer.uid)
        .limit(1)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('lawyerId', isEqualTo: widget.lawyer.uid)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Widget buildStatusBadge(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = selectedStatus == label ? null : label;
        });
      },
      child: StatusBadge(
        label: label,
        color: color,
        icon: icon,
        isSelected: selectedStatus == label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DrawerHeader(
                  child: Image.asset(
                    height: 50,
                    width: 100,
                    "assets/images/ehkaam-seeklogo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.black),
                  title: Text(
                    "Disclaimer",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () => Get.to(DisclaimerPage()),
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.black),
                  title: Text(
                    "About",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () => Get.to(AboutPage()),
                ),
                ListTile(
                  leading: Icon(Icons.more_vert_sharp, color: Colors.black),
                  title: Text(
                    "More services",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () => Get.to(
                    Morelawyer(lawyer: widget.lawyer),
                    transition: Transition.noTransition,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.black),
                  title: Text(
                    "Settings",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 12),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchThisLawyer(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox();
                        }
                        final lawyerData = snapshot.data![0];
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: lawyerData['imageUrl'] != null &&
                                      lawyerData['imageUrl'].isNotEmpty
                                  ? NetworkImage(lawyerData['imageUrl'])
                                  : const AssetImage(
                                      'assets/images/brad.webp',
                                    ) as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome",
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  lawyerData['name'] ?? '',
                                  style: GoogleFonts.lato(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => Get.to(
                    InboxScreen(),
                    transition: Transition.rightToLeftWithFade,
                  ),
                ),
              ],
            ),
          ),
          body: LiquidPullToRefresh(
            onRefresh: () async {
              setState(() {});
            },
            height: 120,
            animSpeedFactor: 2.0,
            color: const Color.fromARGB(151, 0, 35, 96),
            backgroundColor: Colors.white,
            showChildOpacityTransition: false,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Case Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          buildStatusBadge('Finished', Color(0xFF4CAF50),
                              LucideIcons.checkCircle),
                          SizedBox(width: 16),
                          buildStatusBadge(
                              'Waiting', Color(0xFFFFC107), LucideIcons.timer),
                          SizedBox(width: 16),
                          buildStatusBadge('Active', Color(0xFF1E3A5F),
                              LucideIcons.briefcase),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Consultation Requests',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(child: Text('Error fetching requests'));
                        }

                        List<Map<String, dynamic>> requests = snapshot.data!;

                        List<Map<String, dynamic>> filtered =
                            requests.where((req) {
                          if (selectedStatus == 'Active') {
                            return req['status'] == 'Accepted' &&
                                req['ended?'] == false;
                          } else if (selectedStatus == 'Waiting') {
                            return req['status'] == 'Pending';
                          } else if (selectedStatus == 'Finished') {
                            return req['ended?'] == true;
                          }
                          return true;
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(child: Text('No requests'));
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final request = filtered[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  Lawsuit(rid: request['rid']),
                                  transition: Transition.downToUp,
                                );
                              },
                              child: LawsuitCard(
                                status: request['status'],
                                title: request['title'],
                                rid: request['rid'],
                                username: request['username'],
                                date: request['date'],
                                time: request['time'],
                                ended: request['ended?'],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "more"),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.wallet),
                label: "Wallet",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.messageCircle),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.home),
                label: "Home",
              ),
            ],
          ),
        ),
      ],
    );
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
          Lawyermessages(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 3:
        break;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
