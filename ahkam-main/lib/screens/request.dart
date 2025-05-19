import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/screens/browse.dart';
import 'package:ahakam_v8/screens/home.dart';
import 'package:ahakam_v8/screens/messagesScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.account});
  final Account account;

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _selectedIndex = 2; // Default tab index

  // Stream that listens to requests related to the user
  Stream<List<Map<String, dynamic>>> fetchLawyerRequests() {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.account.uid) // Filter requests
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Handles bottom navigation
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = BrowseScreen('', account: widget.account);
        break;

      case 1:
        nextScreen = MessagesScreen(account: widget.account);
        break;
      case 2:
        nextScreen = RequestsScreen(account: widget.account);
        break;
      case 3:
        nextScreen = HomeScreen(account: widget.account);

      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.noTransition);
  }

  // Extracts and formats the request date safely
  String getFormattedDate(Map<String, dynamic> request) {
    Timestamp? timestamp;

    if (request['date'] != null) {
      final dynamic dateValue = request['date'];

      if (dateValue is Timestamp) {
        timestamp = dateValue; // Correct Firestore Timestamp
      } else if (dateValue is String) {
        try {
          timestamp = Timestamp.fromDate(DateTime.parse(dateValue));
        } catch (e) {
          debugPrint("Error parsing date string: $e");
          timestamp = null;
        }
      } else {
        debugPrint("Unexpected date format: $dateValue");
      }
    }

    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    return "Unknown Date";
  }

  Widget getRequestCard(Map<String, dynamic> request) {
    final String title = request['title'] ?? 'Unknown Title';
    final String lawyerName = request['lawyerName'] ?? 'Unknown Lawyer';
    final String status = request['status'] ?? 'Unknown Status';
    final String formattedDate = getFormattedDate(request);
    final String time = request['time'] ?? 'Unknown Time';
    final String rid = request['rid'] ?? '';
    final int fees = request['fees'] ?? 20;

    Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
      var query = await FirebaseFirestore.instance
          .collection('account')
          .where('name', isEqualTo: lawyerName)
          .limit(1)
          .get();
      return query.docs.isNotEmpty ? query.docs.first : null;
    }

    Color statusColor = status == 'Accepted'
        ? const Color.fromARGB(255, 76, 175, 79)
        : status == 'Pending'
            ? const Color.fromARGB(255, 255, 153, 0)
            : Colors.red;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: getinfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) return const Center();

        var lawyerdata = snapshot.data?.data() ?? {};

        ImageProvider backgroundImage;
        final imageUrl = lawyerdata['imageUrl'];
        if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
          backgroundImage = NetworkImage(imageUrl);
        } else {
          backgroundImage = const AssetImage('assets/images/brad.webp');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Card(
            elevation: 5,
            color: const Color(0xFFFFF8F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Status: $status",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (status == 'Rejected' || status == 'Cancelled')
                        Padding(
                          padding: const EdgeInsets.only(left: 80.0),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              final query = await FirebaseFirestore.instance
                                  .collection('requests')
                                  .where('rid', isEqualTo: rid)
                                  .limit(1)
                                  .get();

                              if (query.docs.isNotEmpty) {
                                await FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(query.docs.first.id)
                                    .delete();
                              }
                            },
                          ),
                        ),
                      if (status == 'Pending')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Cancellation"),
                                content: const Text(
                                    "Are you sure you want to cancel this request?"),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      "No",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    child: const Text(
                                      "Yes, Cancel",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                final query = await FirebaseFirestore.instance
                                    .collection('requests')
                                    .where('userId',
                                        isEqualTo: widget.account.uid)
                                    .where('title', isEqualTo: title)
                                    .where('lawyerName', isEqualTo: lawyerName)
                                    .limit(1)
                                    .get();

                                if (query.docs.isNotEmpty) {
                                  await query.docs.first.reference
                                      .update({'status': 'Cancelled'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Request cancelled')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to cancel request')),
                                );
                              }
                            }
                          },
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                        ),
                      if (status == 'Accepted')
                        ElevatedButton(
                          onPressed: () {
                            Get.to(MessagesScreen(account: widget.account),
                                transition: Transition.noTransition);
                          },
                          child: const Text(
                            'Open chat',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Profile info row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: backgroundImage,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lawyerName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            title,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: Color.fromARGB(77, 0, 0, 0)),
                  const SizedBox(height: 8),

                  // Request details
                  const Text(
                    "Case type: Online consultation",
                    style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color.fromARGB(179, 0, 0, 0), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            color: Color.fromARGB(179, 0, 0, 0)),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time,
                          color: Color.fromARGB(179, 0, 0, 0), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                            color: Color.fromARGB(179, 0, 0, 0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color.fromARGB(179, 0, 0, 0), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Fees: \$${fees}",
                        style: const TextStyle(
                            color: Color.fromARGB(179, 0, 0, 0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        toolbarHeight: 50,
        title: Text(
          "Your Requests",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: Color.fromARGB(255, 224, 191, 109),
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        height: 90,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fetchLawyerRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("Error fetching requests"));
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text("No requests sent."));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return getRequestCard(snapshot.data![index]);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color.fromARGB(255, 147, 96, 0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: ""),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageCircle),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboardList),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: ""),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate network call
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {});
  }
}
