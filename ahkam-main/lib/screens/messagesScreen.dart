import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/screens/browse.dart';
import 'package:ahakam_v8/screens/chat.dart';
import 'package:ahakam_v8/screens/home.dart';
import 'package:ahakam_v8/screens/pay.dart';
import 'package:ahakam_v8/screens/request.dart';
import 'package:ahakam_v8/services/auth_service.dart';
import 'package:ahakam_v8/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.account});
  final Account account;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isSelectionMode = false;
  Set<String> selectedMessages = {};

  final ChatService chatService = ChatService();
  late AuthService authService;
  User? currentUser;

  int selectedIndex = 1; // Persistent state for bottom nav selection
  @override
  void initState() {
    super.initState();
    authService = AuthService();
    currentUser = authService.getCurrentUser();
  }

  // Handles bottom navigation
  void onItemTapped(int index) {
    if (index == selectedIndex) return;

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
        break;
      default:
        return;
    }

    Get.offAll(() => nextScreen, transition: Transition.noTransition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          isSelectionMode ? '${selectedMessages.length} selected' : "Messages",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _buildUserList(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Bottom Navigation Bar styling
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: const Color.fromARGB(255, 147, 96, 0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.search),
          label: "search",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.messageCircle),
          label: "Wallet",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.clipboardList),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchACCRequests() async {
    var _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.account.uid)
        .where('status', isEqualTo: "Accepted")
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Widget _buildUserList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchACCRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching requests'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No requests yet.'));
        }

        List<Map<String, dynamic>> requests = snapshot.data!;

        return LiquidPullToRefresh(
          onRefresh: () async {
            setState(() {}); // re-trigger build and refresh data
          },
          color: Colors.orange,
          backgroundColor: Colors.white,
          showChildOpacityTransition: false,
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              var _firestore = FirebaseFirestore.instance;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('account')
                    .doc(request['lawyerId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile();
                  } else if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      !userSnapshot.data!.exists) {
                    return ListTile();
                  }
                  final lawyerData = userSnapshot.data;
                  final dynamic paidField = request['paid'];
                  final bool isPaid = paidField is bool ? paidField : false;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Card(
                      color: const Color(0xFFFFF8F2),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onLongPress: () {
                          setState(() {
                            isSelectionMode = true;
                            selectedMessages.add(request['id']);
                          });
                        },
                        onTap: () {
                          if (isSelectionMode) return;
                          if (request['paid'] == true) {
                            Get.to(
                              transition: Transition.rightToLeft,
                              () => Chat(
                                receivername: request['lawyerName'] ?? '',
                                senderId: request["userId"] ?? '',
                                receiverID: request["lawyerId"] ?? '',
                                rid: request['rid'] ?? '',
                                imageurl: lawyerData?["imageUrl"] ?? '',
                              ),
                            );
                          }
                        },
                        selected: isSelectionMode &&
                            selectedMessages.contains(request['id']),
                        selectedTileColor: Colors.orange[100],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        title: Text(
                          lawyerData?["name"] ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isPaid ? "Tap to chat" : "Payment required",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: !isPaid
                            ? ElevatedButton(
                                onPressed: () {
                                  Get.to(PayPage(
                                      account: widget.account,
                                      rid: request['rid']));
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                child: const Text("Pay"),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
