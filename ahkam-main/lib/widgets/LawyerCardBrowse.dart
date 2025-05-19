import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/lawyerdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerCardBrowse extends StatelessWidget {
  final Lawyer lawyer;
  final Account account;

  const LawyerCardBrowse({
    super.key,
    required this.lawyer,
    required this.account,
  });

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    var query = await FirebaseFirestore.instance
        .collection('account')
        .where('uid', isEqualTo: lawyer.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: getinfo(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading lawyer info"));
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          // You could show a loading spinner here if you want
          return const Center(child: SizedBox.shrink());
        }

        final userdata = snapshot.data!.data() ?? {};

        ImageProvider avatarImage;
        if (userdata['imageUrl'] != null &&
            userdata['imageUrl'] is String &&
            userdata['imageUrl'].isNotEmpty) {
          avatarImage = NetworkImage(userdata['imageUrl']);
        } else {
          avatarImage = const AssetImage('assets/images/brad.webp');
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: avatarImage,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.name ?? 'Unknown Lawyer',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "${lawyer.rating ?? 0.0} (${(lawyer.cases ?? 0).toInt()} Reviews)",
                          style: GoogleFonts.lato(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lawyer.specialization ?? 'Legal Expert',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => LawyerDetailsScreen(
                      lawyerId: lawyer.uid!,
                      account: account,
                    ),
                    transition: Transition.fade,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 72, 45, 0),
                  backgroundColor: const Color.fromARGB(255, 255, 241, 219),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: GoogleFonts.lato(fontSize: 12),
                ),
                child: Text("View", style: GoogleFonts.lato()),
              ),
            ],
          ),
        );
      },
    );
  }
}
