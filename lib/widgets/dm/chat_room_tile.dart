import '../my_loading_indicator.dart';

import '../../providers/database.dart';
import 'package:flutter/material.dart';

import '../../screens/dm/private_chat_screen.dart';

class ChatRoomsTile extends StatefulWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({
    Key key,
    @required this.userName,
    @required this.chatRoomId,
  }) : super(key: key);

  @override
  _ChatRoomsTileState createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMethods().getUserInfo(widget.userName),
      builder: (context, snapshot) {
        user = snapshot.data;
        if (!snapshot.hasData) {
          return MyLoadingIndicator();
        }
        return ListTile(
          onTap: () async {
            print('Navigation to private chat screen with ${widget.userName}');
            Navigator.of(context).pushNamed(
              PrivateChatScreen.routeName,
              arguments: {
                'user': user,
                'chatRoomId': widget.chatRoomId,
              },
            );
          },
          // tileColor: Theme.of(context).primaryColor,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(user['image_url']),
            radius: 30,
          ),
          title: Text(
            widget.userName,
          ),
        );
      },
    );
  }
}
