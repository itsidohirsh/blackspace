import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/chat/user_detail_screen_withOut_button.dart';
import '../chat/message_bubble.dart';
import '../my_loading_indicator.dart';

class PrivateMessages extends StatefulWidget {
  final String chatRoomId;
  final user;

  PrivateMessages({
    Key key,
    @required this.chatRoomId,
    @required this.user,
  }) : super(key: key);

  @override
  _PrivateMessagesState createState() => _PrivateMessagesState();
}

class _PrivateMessagesState extends State<PrivateMessages> {
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return FutureBuilder(
      future: Future(() => FirebaseAuth.instance.currentUser),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return MyLoadingIndicator();
        } else {
          return FutureBuilder(
            future: messagesStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return MyLoadingIndicator();
              } else {
                return StreamBuilder(
                  stream: snapshot.data,
                  builder: (context, chatSnapshot) {
                    if (chatSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return MyLoadingIndicator();
                    } else {
                      final QuerySnapshot<Map<String, dynamic>> chatDocs =
                          chatSnapshot.data;
                      return ListView.builder(
                        reverse: true,
                        itemCount: chatDocs.docs.length,
                        itemBuilder: (ctx, i) => InkWell(
                          // New Fucos node
                          onTap: () {
                            FocusScope.of(_context).requestFocus(FocusNode());
                          },
                          // Message deletion
                          onLongPress: () async {
                            try {
                              await deleteMessage(chatDocs.docs, i);
                            } catch (e) {
                              ScaffoldMessenger.of(_context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not complete process, Internet connection error',
                                  ),
                                ),
                              );
                              print(e);
                            }
                          },
                          child: MessageBubble(
                            chatDocs.docs[i]['text'],
                            chatDocs.docs[i]['username'],
                            chatDocs.docs[i]['userImage'],
                            chatDocs.docs[i]['userId'] ==
                                futureSnapshot.data.uid,
                            key: ValueKey(chatDocs.docs[i].id),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  Future<Stream<QuerySnapshot>> messagesStream() async {
    String _chatRoomId;
    String _firstName;
    String _lastName;

    final doc = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.chatRoomId)
        .get();

    if (doc.exists) {
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _chatRoomId = widget.chatRoomId;
      _firstName = _chatRoomId.split('_')[0];
      _lastName = _chatRoomId.split('_')[1];
      _chatRoomId = '${_lastName}_$_firstName';
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(_chatRoomId)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Future<void> deleteMessage(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocs, i) async {
    final curUser = FirebaseAuth.instance.currentUser;

    if (curUser.uid == chatDocs[i]['userId']) {
      bool isDelete = await showAlertDialog();
      if (isDelete) {
        print('Trying to delete message...');

        final doc = await FirebaseFirestore.instance
            .collection('chatRoom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .where('id', isEqualTo: chatDocs[i]['id'])
            .get();

        final docID = doc.docs.first.id;

        await FirebaseFirestore.instance
            .collection('chatRoom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(docID)
            .delete();

        print('Deleted message $docID');
      } else {
        print('Deletion cancled');
      }
    } else {
      Navigator.of(_context).pushNamed(
        UserDetailsScreenWithOutButton.routeName,
        arguments: {
          'user': await FirebaseFirestore.instance
              .collection('users')
              .doc(chatDocs[i]['userId'])
              .get(),
        },
      );
    }
  }

  Future<bool> showAlertDialog() async {
    bool isDelete = false;

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Theme.of(_context).primaryColor),
      ),
      onPressed: () {
        isDelete = false;
        Navigator.of(_context).pop();
        FocusScope.of(_context).requestFocus(FocusNode());
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Theme.of(_context).errorColor),
      ),
      onPressed: () {
        isDelete = true;
        Navigator.of(_context).pop();
        FocusScope.of(_context).requestFocus(FocusNode());
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete message?"),
      content: Text("Would you like to delete that message from everyone?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: _context,
      builder: (_) {
        return alert;
      },
    );

    return isDelete;
  }
}
