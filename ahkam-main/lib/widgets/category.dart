import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/screens/browse.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Category {
  final String name;
  final String imagePath;
  Category({required this.name, required this.imagePath});
}

List<Category> categories = [
  Category(name: "Criminal", imagePath: 'assets/images/criminal.png'),
  Category(name: "Commercial", imagePath: 'assets/images/commercial.png'),
  Category(name: "Insurance", imagePath: 'assets/images/insurance.png'),
  Category(name: "International", imagePath: 'assets/images/international.png'),
  Category(name: "Labor", imagePath: 'assets/images/labor.png'),
  Category(name: "Civil", imagePath: 'assets/images/civil.png'),
];

class CategoryCard extends StatelessWidget {
  final Category category;
  final Account account;
  const CategoryCard({
    super.key,
    required this.category,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          BrowseScreen('', account: account),
          transition: Transition.downToUp,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 246, 236, 206),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              category.imagePath,
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 5),
            Text(
              category.name,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 72, 47, 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
