import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chitchat/models/chat_user.dart';
import 'package:chitchat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {
  //pentru autentificare
  static FirebaseAuth auth = FirebaseAuth.instance;

  //pentru a accesa cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //pentru a accesa firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //pentru notificarile push
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //get firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();

    await firebaseMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push token: $t');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');
      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  //trimite notificare push
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        {
          "to": chatUser.pushToken,
          "notification": {
            "title": chatUser.name,
            "body": msg,
            "android_channel_id": "chats",
          },
          "data": {
            "some_data": "User ID: ${me.id}",
          }
        }
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAXs2lxLs:APA91bHDkz7-BjMKzAu3o4AiIw3VphFnvf7k7F4n1hYwwa8hp25tACstYIkqXHLhqZTQR-p2bQ2UvKwakDdAcBas2ULvXX4C6lOi207bp-L_QIk7fYAYJYydt6HKnA-LXIUxyMntD-9U'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotification: $e');
    }
  }

  //pentru a colectiona informatii despre userul logat
  static late ChatUser me;

  //returneaza currentuser-ul
  static User get user => auth.currentUser!;

  //pentru a verifica daca userul exista deja in baza de date sau nu
  static Future<bool> existentUser() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

//adauga un user nou pt conv
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  //pentru a lua informatiile despre userul curent (logat)
  static Future<void> getLoggedUserInfo() async {
    return await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
        log('My data: ${user.data()}');
      } else {
        await createUser().then((value) => getLoggedUserInfo());
      }
    });
  }

  //pentru a crea un user nou
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hi! I am new to ChitChat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

//arata toti userii care nu sunt userul logat (cei cu care converseaza)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nuserIds: $userIds');

    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

//modifica informatiile despre userul logat
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update profile pic
  static Future<void> updatePfp(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data uploaded: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

//----------------------------------------------------------------------------
//--------------- APIs FOR THE CHAT SCREEN -----------------------------------
//----------------------------------------------------------------------------

  //ia id-ul conversatiei
  static String getConvId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //ia din firebase database toate mesajele dintr-o anumita conversatie
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConvId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //send messege
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //timpul trimiterii mesajului (message id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //mesajul trimis
    final Message message = Message(
        toid: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromid: user.uid,
        sent: time);

    final ref =
        firestore.collection('chats/${getConvId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'message'));
  }

  //update la statusul de read
  static Future<void> updateReadMessageStatus(Message message) async {
    firestore
        .collection('chats/${getConvId(message.fromid)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConvId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //face poza in conversatie si trimite ca mesaj
  static Future<void> sendImage(ChatUser chatUser, File file) async {
    //ia extensia imaginii
    final ext = file.path.split('.').last;
    //calea de la storage (din firebase)
    final ref = storage.ref().child(
        'images/${getConvId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //upload
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data uploaded: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    return firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> deleteMessage(Message message) async {
    firestore
        .collection('chats/${getConvId(message.toid)}/messages/')
        .doc(message.sent)
        .delete();

    //delete img
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message, String updateMsg) async {
    firestore
        .collection('chats/${getConvId(message.toid)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }
}
