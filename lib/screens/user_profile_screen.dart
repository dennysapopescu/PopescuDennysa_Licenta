//import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/main.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/screens/auth/login_screen.dart';
//import 'package:chitchat/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  final ChatUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //appbar
          appBar: AppBar(
            title: const Text('User Profile'),
          ),

          //floatingactionbutton //butonul de logout
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              backgroundColor: const Color.fromRGBO(132, 109, 98, 1),
              onPressed: () async {
                //signout
                Dialogs.showProgressCircle(context);

                await APIs.updateActiveStatus(false);

                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout,
                  color: Color.fromRGBO(248, 223, 205, 1)),
              label: const Text(
                'LOGOUT',
                style: TextStyle(color: Color.fromRGBO(248, 223, 205, 1)),
              ),
            ),
          ),

          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * .05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        width: mq.width,
                        height: mq.height * .03), //spatiu deasupra pozei
                    //pentru poza utilizatorului
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          //buton de edit la poza de profil
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: const CircleBorder(),
                              color: Colors.white,
                              child: const Icon(
                                Icons.edit,
                                color: Color.fromRGBO(132, 109, 98, 1),
                              )),
                        ),
                      ],
                    ),

                    SizedBox(height: mq.height * .05),
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),

                    SizedBox(height: mq.height * .03),

                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (value) => APIs.me.name = value ?? '',
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'This field must be completed!',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromRGBO(132, 109, 98, 1),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'ex. Dennysa Popescu',
                          label: Text('Name:')),
                    ),

                    SizedBox(height: mq.height * .03),

                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (value) => APIs.me.about = value ?? '',
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'This field must be completed!',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info,
                            color: Color.fromRGBO(132, 109, 98, 1),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'ex. Hi, I am a new user of ChitChat!',
                          label: Text('Say something about you:')),
                    ),

                    //buton de update profile
                    SizedBox(height: mq.height * .03),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            minimumSize: Size(mq.width * .3, mq.height * .05),
                            backgroundColor:
                                const Color.fromRGBO(248, 223, 205, 1)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, 'User info updated succesfully!');
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Color.fromRGBO(132, 109, 98, 1),
                        ),
                        label: const Text(
                          'UPDATE',
                          style: TextStyle(
                              color: Color.fromRGBO(132, 109, 98, 1),
                              fontSize: 15),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

//pentru alegerea pozei de profil
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .05),
            children: [
              const Text('Choose a profile picture: ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image path: ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updatePfp(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(
                        Icons.photo_album,
                        color: Color.fromRGBO(132, 109, 98, 1),
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updatePfp(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(Icons.photo_camera,
                          color: Color.fromRGBO(132, 109, 98, 1))),
                ],
              )
            ],
          );
        });
  }
}
