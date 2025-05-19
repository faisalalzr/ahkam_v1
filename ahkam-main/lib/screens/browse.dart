import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/account.dart';
import '../models/lawyer.dart';
import '../screens/home.dart';
import '../screens/messagesScreen.dart';
import '../screens/request.dart';
import '../widgets/LawyerCardBrowse.dart';

class BrowseScreen extends StatefulWidget {
  final String? search;
  final Account account;
  final String? category;

  const BrowseScreen(
    this.search, {
    super.key,
    required this.account,
    this.category,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String sortOption = 'Fees'; // default

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                "Province",
                                provinces,
                                selectedProvince,
                                (val) =>
                                    setModalState(() => selectedProvince = val),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                "Specialization",
                                specializations,
                                selectedSpecialization,
                                (val) => setModalState(
                                  () => selectedSpecialization = val,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildSlider(
                          "Minimum Rating",
                          minRating,
                          0,
                          5,
                          (val) => setModalState(() => minRating = val),
                        ),
                        SizedBox(height: 12),
                        _buildSlider(
                          "Maximum Fees",
                          maxFees,
                          0,
                          100,
                          (val) => setModalState(() => maxFees = val),
                        ),
                        SizedBox(height: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sort By:",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: DropdownButtonFormField2<String>(
                                      value: sortOption,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                              0,
                                              139,
                                              94,
                                              60,
                                            ),
                                          ),
                                        ),
                                      ),
                                      items: ['Fees', 'Rating', 'Experience']
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setModalState(
                                        () => sortOption = val!,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ), // <--- Rounded corners here
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    _clearFilters();
                                    setModalState(
                                      () {},
                                    ); // Refresh modal after clearing
                                  },
                                  label: Text(
                                    "Clear",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 31, 31),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _saveFilterPreferences();
      setState(() {}); // Refresh main screen after closing modal
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  double minRating = 0;
  double maxFees = 100;
  String selectedProvince = 'All';

  String selectedSpecialization = 'All';
  List<String> provinces = [
    'All',
    "Amman",
    "Zarqaa",
    "ma'an",
    "Irbid",
    "Aqaba",
  ];
  List<String> specializations = [
    'All',
    "Civil",
    "Criminal",
    "Commercial",
    "Labor",
    "Insurance",
    "International",
  ];

  List<Map<String, dynamic>> filteredLawyers = [];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.search ?? '';
    searchController.text = _searchQuery;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
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
      case 3:
        Get.to(
          HomeScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;
    }
  }

  Future<void> _saveFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('minRating', minRating);
    await prefs.setDouble('maxFees', maxFees);
    await prefs.setString('province', selectedProvince);
    await prefs.setString('specialization', selectedSpecialization);
    await prefs.setString('sortOption', sortOption);
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      minRating = 0;
      maxFees = 100;
      selectedProvince = 'All';

      selectedSpecialization = 'All';
      sortOption = 'Fees';
    });
  }

  List<Map<String, dynamic>> _applyLocalFilters(
    List<QueryDocumentSnapshot> docs,
  ) {
    final lawyers = docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .where((data) {
      final name = data['name']?.toString().toLowerCase() ?? '';
      final rating = data['rating']?.toDouble() ?? 0.0;
      final fees = data['fees']?.toDouble() ?? 0.0;
      final province = data['province']?.toString() ?? '';
      final spec = data['specialization']?.toString() ?? '';
      final exp = data['exp']?.toString() ?? '';
      final cases = data['cases'].toString() ?? 0;

      return name.contains(_searchQuery.toLowerCase()) &&
          rating >= minRating &&
          fees <= maxFees &&
          (selectedProvince == 'All' || province == selectedProvince) &&
          (selectedSpecialization == 'All' || spec == selectedSpecialization);
    }).toList();

    if (sortOption == 'Rating') {
      lawyers.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    } else if (sortOption == 'Fees') {
      lawyers.sort((a, b) => (a['fees'] ?? 0).compareTo(b['fees'] ?? 0));
    } else if (sortOption == 'Experience') {
      lawyers.sort(
        (b, a) => (a['experience'] ?? 0).compareTo(b['experience'] ?? 0),
      );
    }

    return lawyers;
  }

  @override
  Widget build(BuildContext context) {
    Query query =
        _firestore.collection('account').where('isLawyer', isEqualTo: true);
    if (widget.category != null) {
      query = query.where('specialization', isEqualTo: widget.category);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        title: Text(
          widget.category ?? "Browse Lawyers",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF482F00),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.filter, color: Colors.black),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: Color(0xFFE0BF6D),
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        height: 90,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  filteredLawyers = _applyLocalFilters(snapshot.data!.docs);

                  if (filteredLawyers.isEmpty) {
                    return Center(
                      child: Text(
                        'No lawyers found.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredLawyers.length,
                    itemBuilder: (context, index) {
                      final lawyerData = filteredLawyers[index];
                      final lawyer = Lawyer(
                        uid: lawyerData['uid'],
                        name: lawyerData['name'] ?? 'Unknown',
                        email: lawyerData['email'] ?? 'Unknown',
                        specialization:
                            lawyerData['specialization'] ?? 'Unknown',
                        rating: lawyerData['rating'] ?? 0.0,
                        province: lawyerData['province'] ?? 'Unknown',
                        number: lawyerData['number'] ?? 'N/A',
                        desc: lawyerData['desc'] ?? '',
                        fees: lawyerData['fees'] ?? 0,
                        exp: lawyerData['exp'] ?? 0,
                        cases: lawyerData['cases'] ?? 0,
                      );
                      return LawyerCardBrowse(
                        lawyer: lawyer,
                        account: widget.account,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 20,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF482F00),
        unselectedItemColor: Colors.grey,
        items: [
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: searchController,
        onChanged: (query) => setState(() => _searchQuery = query),
        decoration: InputDecoration(
          hintText: "Search for a lawyer...",
          prefixIcon: Icon(Icons.search, color: Colors.black),
          filled: true,
          fillColor: Color(0xFFFFF7F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B2F2F),
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField2<String>(
          value: selected,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 11)),
                ),
              )
              .toList(),
          onChanged: (val) => onChanged(val!),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    Color activeColor = Colors.black,
    Color labelColor = const Color(0xFF3B2F2F),
  }) {
    final divisions = (max - min) >= 1 ? (max - min).round() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: labelColor),
            ),
            label == "Maximum Fees"
                ? Text(
                    "\$${value.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  )
                : Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          activeColor: activeColor,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
