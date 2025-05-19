import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 17,
            )),
        backgroundColor: const Color(0xFFF5EEDC),
        title: Text(
          "Ahkam Disclaimer",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 72, 47, 0),
          ),
        ),

        elevation: 0, // Removes the shadow for a clean look
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EEDC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 80,
                    color: Color(0xFFB94D4D), // Nice shade of red
                  ),
                  const SizedBox(height: 20),
                  Text(
                    " Ahkam does not offer legal advice directly and does not participate in or monitor the communications between users and lawyers beyond providing the technical means for such interactions The legal advice, opinions, and content shared by lawyers through the Ahkam application are entirely their own and are provided independently of Ahkam. We do not verify, endorse, or guarantee the accuracy, legality, or effectiveness of any legal information or guidance given. Users are advised to exercise their own judgment when relying on legal advice received through the platform and, where necessary, seek a second opinion or in-person consultation with a licensed attorney.Ahkam shall not be held liable for any outcomes, actions, or decisions taken by users based on the advice received through the application. Any engagement between users and lawyers, including legal outcomes, payments, and services rendered, is strictly between the parties involved.By using the Ahkam platform.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto', // Changed font to Roboto
                      fontSize: 12,
                      color: Color.fromARGB(255, 72, 47, 0),
                      fontWeight: FontWeight
                          .w400, // Slightly lighter weight for easier reading
                      height: 1.6, // Better spacing between lines
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBCA18D), // Lighter brown
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Got it!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
