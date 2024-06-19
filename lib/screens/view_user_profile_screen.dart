import 'package:cached_network_image/cached_network_image.dart';

import 'package:chitchat/helper/date_references.dart';

import 'package:chitchat/main.dart';
import 'package:chitchat/models/chat_user.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewUserProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewUserProfileScreen({super.key, required this.user});

  @override
  State<ViewUserProfileScreen> createState() => _ViewUserProfileScreenState();
}

class _ViewUserProfileScreenState extends State<ViewUserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //appbar
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('User of ChitChat since: 2024',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              /*Text(
                DateRefs.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),*/
            ],
          ),

          //body
          body: Padding(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  SizedBox(height: mq.height * .05),
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),

                  SizedBox(height: mq.height * .02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('About: ',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
