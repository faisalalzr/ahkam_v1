import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/Lawyer screens/lawSuitDetails.dart';

class LawsuitCard extends StatefulWidget {
  final String title;
  final String status;
  final bool ended;
  final String rid;
  final String username;
  final String date;
  final String time;

  const LawsuitCard({
    super.key,
    required this.title,
    required this.status,
    required this.rid,
    required this.username,
    required this.date,
    required this.time,
    required this.ended,
  });

  @override
  State<LawsuitCard> createState() => _LawsuitCardState();
}

class _LawsuitCardState extends State<LawsuitCard> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;
  String? requestId;
  String? status;
  String? userImageUrl;
  String consultationDuration = '';

  @override
  void initState() {
    super.initState();
    status = widget.status;
    fetchRequestId();
    fetchConsultationDuration();
    fetchUserPic();
  }

  Future<void> fetchUserPic() async {
    try {
      var querySnapshot = await fyre
          .collection('account')
          .where('name', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        setState(() {
          userImageUrl = data['imageUrl'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user pic: $e");
    }
  }

  Future<void> fetchRequestId() async {
    try {
      var querySnapshot = await fyre
          .collection('requests')
          .where('rid', isEqualTo: widget.rid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        requestId = querySnapshot.docs.first.id;
        setState(() {});
      }
    } catch (e) {
      print("Error fetching request ID: $e");
    }
  }

  Future<void> fetchConsultationDuration() async {
    try {
      var querySnapshot = await fyre
          .collection('requests')
          .where('rid', isEqualTo: widget.rid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        Timestamp startTimestamp = data['timestamp'];
        Duration duration = DateTime.now().difference(startTimestamp.toDate());

        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;

        setState(() {
          consultationDuration =
              '${hours > 0 ? '$hours hr${hours > 1 ? 's' : ''} ' : ''}${minutes > 0 ? '$minutes min${minutes > 1 ? 's' : ''}' : ''}';
        });
      }
    } catch (e) {
      print("Error fetching consultation duration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Accepted'
        ? const Color.fromARGB(255, 75, 174, 80)
        : status == 'Pending'
            ? const Color.fromRGBO(255, 196, 0, 1)
            : status == 'Rejected'
                ? const Color.fromARGB(255, 255, 22, 22)
                : Colors.black;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: const Color.fromARGB(255, 0, 35, 73).withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Status + View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Status: ${widget.ended == false ? status : 'Finished'} ",
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(
                      Lawsuit(rid: widget.rid),
                      transition: Transition.downToUp,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    textStyle: GoogleFonts.lato(fontSize: 12),
                  ),
                  child: Text("View Details", style: GoogleFonts.lato()),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// User Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      userImageUrl != null && userImageUrl!.isNotEmpty
                          ? NetworkImage(userImageUrl!)
                          : const AssetImage('assets/images/brad.webp')
                              as ImageProvider,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.brown.shade200),
            const SizedBox(height: 8),

            /// Case Info
            Text(
              "Case: Online Consultation",
              style: GoogleFonts.lato(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  widget.date.substring(0, 10),
                  style: GoogleFonts.lato(color: Colors.black),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text(widget.time, style: GoogleFonts.lato(color: Colors.black)),
              ],
            ),
            if (consultationDuration.isNotEmpty && widget.ended == false) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.black),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "Duration: $consultationDuration",
                      style: GoogleFonts.lato(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
