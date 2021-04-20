import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../my_loading_indicator.dart';
import '../../screens/chat/user_details_screen_with_button.dart';
import 'message_bubble.dart';

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
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
          return StreamBuilder(
            stream: Firestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
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

  Future<void> deleteMessage(chatDocs, i) async {
    final curUser = await FirebaseAuth.instance.currentUser();

    if (curUser.uid == chatDocs[i]['userId']) {
      bool isDelete = await showAlertDialog();
      if (isDelete) {
        final doc = await Firestore.instance
            .collection('chat')
            .where('id', isEqualTo: chatDocs[i]['id'])
            .getDocuments();

        final docID = doc.documents.first.documentID;

        await Firestore.instance.collection('chat').document(docID).delete();

        print('deleted message $docID');
      }
    } else {
      Navigator.of(_context).pushNamed(
        UserDetailsScreenWithButton.routeName,
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
