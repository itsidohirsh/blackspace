import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  Future<String> getCurUserUid() async {
    final user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  Future<String> getCurUserName() async {
    final uid = await getCurUserUid();
    final doc =
        await Firestore.instance.collection('users').document(uid).get();
    return doc.data['username'];
  }

  Future<void> addUserInfo(userData) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  Future<Map<String, dynamic>> getUserInfo(String username) async {
    final userDoc = await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .getDocuments();
    return userDoc.documents.single.data;
  }

  // Future<QuerySnapshot> getUserInfo(String username) async {
  //   return await Firestore.instance
  //       .collection("users")
  //       .where("username", isEqualTo: username)
  //       .getDocuments()
  //       .catchError((e) {
  //     print(e.toString());
  //   });
  // }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  Future<void> addChatRoom(chatRoom, chatRoomId) async {
    await Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) async {
    await Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Stream<QuerySnapshot> getUserChats(String itIsMyName) {
    return Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
