import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/chat/user_detail_screen_withOut_button.dart';
import '../chat/message_bubble.dart';
import '../my_loading_indicator.dart';

class PrivateMessages extends StatefulWidget {
  String chatRoomId;
  var user;

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
      future: FirebaseAuth.instance.currentUser(),
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
                      final chatDocs = chatSnapshot.data.documents;
                      return ListView.builder(
                        reverse: true,
                        itemCount: chatSnapshot.data.documents.length,
                        itemBuilder: (ctx, i) => InkWell(
                          // New Fucos node
                          onTap: () {
                            FocusScope.of(_context).requestFocus(FocusNode());
                          },
                          // Message deletion
                          onLongPress: () async {
                            try {
                              await deleteMessage(chatDocs, i);
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
                            chatDocs[i]['text'],
                            chatDocs[i]['username'],
                            chatDocs[i]['userImage'],
                            chatDocs[i]['userId'] == futureSnapshot.data.uid,
                            key: ValueKey(chatDocs[i].documentID),
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

    final doc = await Firestore.instance
        .collection('chatRoom')
        .document(widget.chatRoomId)
        .get();

    if (doc.exists) {
      return Firestore.instance
          .collection('chatRoom')
          .document(widget.chatRoomId)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _chatRoomId = widget.chatRoomId;
      _firstName = _chatRoomId.split('_')[0];
      _lastName = _chatRoomId.split('_')[1];
      _chatRoomId = '${_lastName}_$_firstName';
      return Firestore.instance
          .collection('chatRoom')
          .document(_chatRoomId)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Future<void> deleteMessage(chatDocs, i) async {
    final curUser = await FirebaseAuth.instance.currentUser();

    if (curUser.uid == chatDocs[i]['userId']) {
      bool isDelete = await showAlertDialog();
      if (isDelete) {
        final doc = await Firestore.instance
            .collection('chatRoom')
            .document(widget.chatRoomId)
            .collection('chats')
            .where('id', isEqualTo: chatDocs[i]['id'])
            .getDocuments();

        final docID = doc.documents.first.documentID;

        await Firestore.instance
            .collection('chatRoom')
            .document(widget.chatRoomId)
            .collection('chats')
            .document(docID)
            .delete();

        print('deleted message $docID');
      }
    } else {
      Navigator.of(_context).pushNamed(
        UserDetailsScreenWithOutButton.routeName,
        arguments: {
          'user': await Firestore.instance
              .collection('users')
              .document(chatDocs[i]['userId'])
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
