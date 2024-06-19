import 'dart:developer';

import 'package:chitchat/api/api.dart';
import 'package:chitchat/main.dart';
import 'package:chitchat/screens/auth/login_screen.dart';
import 'package:chitchat/screens/homescreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      //iese din modul fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        //navigheaza la homescreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //navigheaza la login
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to ChitChat! <3'),
      ),
      body: Stack(children: [
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('images/bubble_nobg.png')),
        Positioned(
          bottom: mq.height * .15,
          width: mq.width,
          child: const Text('Glad to have you here! <3',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: Color.fromRGBO(132, 109, 98, 1),
                  letterSpacing: .5)),
        )
      ]),
    );
  }
}
