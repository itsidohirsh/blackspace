import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  // Returns the current connected user, user id
  Future<String> getCurUserUid() async {
    final user = await FirebaseAuth.instance.currentUser;
    return user.uid;
  }

  // Returns the current connected user, user name
  Future<String> getCurUserName() async {
    final uid = await getCurUserUid();
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()['username'];
  }

  // Adds user information to the user in the users collection in the db
  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns the info of a user by its username
  Future<Map<String, dynamic>> getUserInfo(String username) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return userDoc.docs.single.data();
  }

  // Creats a new chat room for a private chat two users have started
  Future<void> addChatRoom(chatRoom, chatRoomId) async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  // Returns the chat messages of a current chat room by its room id
  getChats(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  // Adds a message to a certein chat room
  Future<void> addMessage(String chatRoomId, chatMessageData) async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Returns all the current user private chats
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChats(String itIsMyName) {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
