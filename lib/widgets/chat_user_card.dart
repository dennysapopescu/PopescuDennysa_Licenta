import 'package:chitchat/api/api.dart';
import 'package:chitchat/helper/date_references.dart';
import 'package:chitchat/main.dart';
import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/models/message.dart';
import 'package:chitchat/screens/chat_screen.dart';
import 'package:chitchat/widgets/dialogs%08%08%08/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //color: Colors.blue.shade100,
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                //pentru poza utilizatorului
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      width: mq.height * .065,
                      height: mq.height * .065,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                //username
                title: Text(widget.user.name),

                //ultimul mesaj
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'Sent an image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),

                //ora ultimului mesaj
                trailing: _message == null
                    ? null //nu afiseaza nimic cand nu e niciun mesaj
                    : _message!.read.isEmpty &&
                            _message!.fromid != APIs.user.uid

                        //afiseaza mesajele necitite
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )

                        // ora cand a fost trimis mesajul
                        : Text(
                            DateRefs.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    ); //pentru efect la casuta de conversatie
  }
}
