import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/inbox.dart';
import 'package:ahakam_v8/screens/about.dart';
import 'package:ahakam_v8/screens/browse.dart';
import 'package:ahakam_v8/screens/messagesScreen.dart';
import 'package:ahakam_v8/screens/profile.dart';
import 'package:ahakam_v8/screens/request.dart';
import 'package:ahakam_v8/widgets/lawyerHomecard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../widgets/category.dart';
import 'disclaimerPage.dart';
// No changes to your imports

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.account});
  final Account account;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 3;
  TextEditingController searchController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Get.to(
          BrowseScreen(account: widget.account, ''),
          transition: Transition.noTransition,
        );
        break;
      case 1:
        Get.to(
          MessagesScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;
      case 2:
        Get.to(
          RequestsScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    "assets/images/ehkaam-seeklogo.png",
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _buildDrawerItem(
                Icons.info_outline,
                "Disclaimer",
                () => Get.to(() => DisclaimerPage()),
              ),
              _buildDrawerItem(
                Icons.info,
                "About",
                () => Get.to(() => AboutPage()),
              ),
              _buildDrawerItem(Icons.person, "Profile", () {
                Get.to(
                  () => ProfileScreen(account: widget.account),
                  transition: Transition.noTransition,
                );
              }),
              _buildDrawerItem(Icons.settings, "Settings", () {}),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color.fromARGB(255, 224, 191, 109),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.account.imageUrl?.isNotEmpty == true
                    ? NetworkImage(widget.account.imageUrl!)
                    : const AssetImage("assets/images/default_avatar.png")
                        as ImageProvider,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    widget.account.name?.isNotEmpty == true
                        ? widget.account.name!
                        : 'User',
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => InboxScreen(),
              transition: Transition.rightToLeftWithFade,
            ),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: const Color.fromARGB(255, 224, 191, 109),
          backgroundColor: Colors.white,
          animSpeedFactor: 2.0,
          height: 90,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Categories"),
                const SizedBox(height: 8),
                GridView.builder(
                  itemCount: categories.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    return Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      child: CategoryCard(
                        category: categories[index],
                        account: widget.account,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _sectionTitle("Top Lawyers"),
                const SizedBox(height: 10),
                FutureBuilder<List<Lawyer>>(
                  future: Lawyer.getTopLawyers(limit: 3),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error loading lawyers: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No top-rated lawyers available"),
                      );
                    }

                    return Column(
                      children: snapshot.data!
                          .map(
                            (lawyer) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: LawyerCard(
                                lawyer: lawyer,
                                account: widget.account,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 87, 56, 0),
        unselectedItemColor: Colors.grey,
        elevation: 10,
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

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
      ),
      onTap: onTap,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF4A2F00),
        letterSpacing: 0.3,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }
}
