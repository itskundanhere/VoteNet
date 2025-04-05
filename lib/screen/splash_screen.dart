import 'package:flutter/material.dart';
//import 'package:voter_app/screen/face_registration_screen.dart';
//import 'package:voter_app/screen/voting_verification_screen.dart';
import 'package:voter_app/screens/home_page_screen.dart';
import 'package:voter_app/widgets/custom_loading.dart';
///import 'package:voter_app/screen/face_registration_screen.dart';

//import 'package:voter_app/widgets/customlaoding.dart';
//import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        ); // Navigate to LoginScreen after 3 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: const Color.fromARGB(255, 95, 5, 180),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(mq.width * 0.05),
                child: Image.asset('assets/images/logo.jpg', width: mq.width * 0.5),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const CustomLoading()
 // Loading indicator
          ],
        ),
      ),
    );
  }
}
