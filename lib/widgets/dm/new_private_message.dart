import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewPrivateMessage extends StatefulWidget {
  final String chatRoomId;
  final user;

  NewPrivateMessage({
    Key key,
    @required this.chatRoomId,
    @required this.user,
  }) : super(key: key);

  @override
  _NewPrivateMessageState createState() => _NewPrivateMessageState();
}

class _NewPrivateMessageState extends State<NewPrivateMessage> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();

    final user = await FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    String _chatRoomId = await checkChatRoomId();

    final doc = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(_chatRoomId)
        .get();

    if (!doc.exists) {
      // If Chat room doesn't exist
      await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(_chatRoomId)
          .set(
        {
          'chatRoomId': _chatRoomId,
          'users': [
            userData['username'],
            widget.user['username'],
          ],
        },
      );
    }

    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(_chatRoomId)
        .collection('chats')
        .add(
      {
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData['username'],
        'userImage': userData['image_url'],
        'id': Timestamp.now(),
      },
    );

    _controller.clear();
    setState(() {
      _enteredMessage = '';
    });
  }

  Future<String> checkChatRoomId() async {
    String _chatRoomId;
    String _firstName;
    String _lastName;

    final doc = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.chatRoomId)
        .get();

    if (doc.exists) {
      return widget.chatRoomId;
    } else {
      _chatRoomId = widget.chatRoomId;
      _firstName = _chatRoomId.split('_')[0];
      _lastName = _chatRoomId.split('_')[1];
      _chatRoomId = '${_lastName}_$_firstName';
      return _chatRoomId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        elevation: 10,
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                          hintText: 'Send message...',
                          border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          _enteredMessage = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    color: Theme.of(context).accentColor,
                    icon: Icon(Icons.send),
                    onPressed:
                        _enteredMessage.trim().isEmpty ? null : _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
