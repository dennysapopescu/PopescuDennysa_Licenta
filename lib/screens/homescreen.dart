// ignore_for_file: unused_import

import 'dart:developer';

import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/dialogs.dart';
import 'package:chitchat/main.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/screens/AIChatBot.dart';
import 'package:chitchat/screens/user_profile_screen.dart';
import 'package:chitchat/widgets/chat_user_card.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = []; //all users
  final List<ChatUser> _listSearch = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getLoggedUserInfo();

    //APIs.updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resumed'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('paused'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            //appbar
            appBar: AppBar(
              leading: Icon(CupertinoIcons.home), //icon pentru butonul home
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name, Email, ... "),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (value) {
                        //search logic
                        _listSearch.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            _listSearch.add(i);
                          }
                          setState(() {
                            _listSearch;
                          });
                        }
                      },
                    )
                  : Text('ChitChat'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)), //icon pentru butonul search
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => UserProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: const Icon(Icons
                        .more_vert)) //icon pentru butonul cu puntele de 'more'
              ],
            ),

            //floatingactionbutton
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: Color.fromRGBO(248, 223, 205, 1),
                    onPressed: () {
                      _addChatUserDialog();
                    },
                    child: const Icon(
                      Icons.add_comment_rounded,
                      color: Color.fromRGBO(132, 109, 98, 1),
                    ), //butonul de conversatie noua
                  ),
                  SizedBox(width: 10), // Spațiu între butoane
                  FloatingActionButton(
                    backgroundColor: Color.fromRGBO(248, 223, 205, 1),
                    onPressed: () {
                      // Deschide pagina AI
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AIChatBot()),
                      );
                    },
                    child: const Icon(
                      Icons.question_mark_rounded,
                      color: Color.fromRGBO(132, 109, 98, 1),
                    ), //butonul de AI
                  ),
                ],
              ),
            ),

            //body
            body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              //id de la userii care au deja cont
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if any or all data loaded we'll show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs?.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());

                          //if any or all data loaded we'll show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _listSearch.length
                                      : _list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        user: _isSearching
                                            ? _listSearch[index]
                                            : _list[index]);

                                    //return Text('Name: ${list[index]}');
                                  });
                            } else {
                              return const Center(
                                child: Text('No conversation found.',
                                    style: TextStyle(fontSize: 20)),
                              );
                            }
                        }
                      },
                    );
                }
              },
            )),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.black,
                    size: 28,
                  ),
                  Text('  Add user')
                ],
              ),

              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty)
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User does not exist!');
                        }
                      });
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}
