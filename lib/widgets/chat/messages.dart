import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/splash_screen.dart';
import '../../screens/chat/user_details_screen.dart';
import 'message_bubble.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          return StreamBuilder(
            stream: Firestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return SplashScreen();
              } else {
                final chatDocs = chatSnapshot.data.documents;
                return ListView.builder(
                  reverse: true,
                  itemCount: chatSnapshot.data.documents.length,
                  itemBuilder: (ctx, i) => InkWell(
                    onLongPress: () async {
                      try {
                        await deleteMessage(context, chatDocs, i);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
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

  Future<void> deleteMessage(BuildContext context, chatDocs, i) async {
    final curUser = await FirebaseAuth.instance.currentUser();

    if (curUser.uid == chatDocs[i]['userId']) {
      bool isDelete = await showAlertDialog(context);
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
      Navigator.of(context).pushNamed(
        UserDetailsScreen.routeName,
        arguments: {
          'user': await Firestore.instance
              .collection('users')
              .document(chatDocs[i]['userId'])
              .get(),
        },
      );
    }
  }

  Future<bool> showAlertDialog(BuildContext context) async {
    bool isDelete = false;

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      onPressed: () {
        isDelete = false;
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
      onPressed: () {
        isDelete = true;
        Navigator.of(context).pop();
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
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return isDelete;
  }
}
