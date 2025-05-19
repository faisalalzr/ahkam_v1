import 'package:ahakam_v8/screens/about.dart';
import 'package:ahakam_v8/screens/disclaimerPage.dart';
import 'package:ahakam_v8/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/lawyer.dart';
import 'lawyerHomeScreen.dart';
import 'lawyerMessages.dart';
import 'lawyerWalletScreen.dart';

class Morelawyer extends StatefulWidget {
  final Lawyer lawyer;
  const Morelawyer({super.key, required this.lawyer});

  @override
  State<Morelawyer> createState() => _MorelawyerState();
}

class _MorelawyerState extends State<Morelawyer> {
  int _selectedIndex = 0; // Initialize correctly as an int

  final List<Map<String, dynamic>> options = [
    {'title': 'Profile Settings', 'icon': LucideIcons.user},
    {'title': 'About Us', 'icon': LucideIcons.info},
    {'title': 'Terms of Service', 'icon': LucideIcons.fileText},
    {'title': 'Notifications', 'icon': LucideIcons.bell},
    {'title': 'Security', 'icon': LucideIcons.shield},
    {'title': 'Payment Methods', 'icon': LucideIcons.creditCard},
    {'title': 'Help Center', 'icon': LucideIcons.helpCircle},
    {'title': 'Contact Support', 'icon': LucideIcons.phone},
    {'title': 'Privacy Policy', 'icon': LucideIcons.lock},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          'More',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                options[index]['icon'],
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              title: Text(
                options[index]['title'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
              onTap: () {
                if (options[index]['title'] == 'About Us') {
                  Get.to(AboutPage());
                }
                if (options[index]['title'] == 'Profile Settings') {
                  Get.to(ProfileScreen(account: widget.lawyer));
                }
                if (options[index]['title'] == 'Terms of Service') {
                  Get.to(DisclaimerPage());
                }
              },
            ),
          );
        },
      ),
    );
  }

  void onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Get.off(
          () => Morelawyer(lawyer: widget.lawyer),
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
}
