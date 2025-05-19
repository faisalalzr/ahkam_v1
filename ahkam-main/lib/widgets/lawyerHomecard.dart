import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/lawyerdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  final Account account;

  const LawyerCard({super.key, required this.lawyer, required this.account});

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    var query = await FirebaseFirestore.instance
        .collection('account')
        .where('email', isEqualTo: lawyer.email)
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
        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(); // or a loading placeholder
        }

        final lawyerdata = snapshot.data?.data() ?? {};

        // Safe image handling
        ImageProvider backgroundImage;
        final imageUrl = lawyerdata['imageUrl'];
        if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
          backgroundImage = NetworkImage(imageUrl);
        } else {
          backgroundImage = const AssetImage('assets/images/brad.webp');
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
              // Lawyer Profile Pic or Placeholder
              CircleAvatar(
                radius: 25,
                backgroundImage: backgroundImage,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),

              // Lawyer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyerdata['name'] ?? 'Unknown Lawyer',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.brown[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          "${lawyerdata['rating'] ?? 0.0} (${(lawyerdata['cases'] ?? 0).toInt()} Reviews)",
                          style: GoogleFonts.lato(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lawyerdata['specialization'] ?? 'General'} law',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // View Button
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
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 246, 236, 206),
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
