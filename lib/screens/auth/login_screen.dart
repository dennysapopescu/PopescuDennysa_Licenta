import 'dart:developer';
import 'dart:io';

import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/main.dart';
import 'package:chitchat/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    //arata cercul de progres
    Dialogs.showProgressCircle(context);
    _signInWithGoogle().then((user) async {
      //ascunde progresul
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.existentUser())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');

      // Trigger pentru procesul de autentificare
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtine detaliile de autentificare de la request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Creeaza credentiale noi
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // O data realizat sign in, va returna credentialele utilizatorului
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n _signInWithGoogle: $e');
      Dialogs.showSnackbar(
          context, 'Something went wrong... Check your internet connection!');
      return null;
    }
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
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * 5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/bubble_nobg.png')),
        Positioned(
          bottom: mq.height * .15,
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .07,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(248, 223, 205, 1),
                  shape: const StadiumBorder(),
                  elevation: 1),
              onPressed: () {
                _handleGoogleButtonClick();
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
              icon: Image.asset(
                'images/bubble_nobg.png',
                height: mq.height * .10,
              ),
              label: RichText(
                text: const TextSpan(
                    style: TextStyle(
                        color: Color.fromRGBO(132, 109, 98, 1), fontSize: 18),
                    children: [
                      TextSpan(text: 'Login with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ]),
              )),
        ),
      ]),
    );
  }
}
