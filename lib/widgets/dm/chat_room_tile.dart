import '../../providers/database.dart';
import 'package:flutter/material.dart';

import '../../screens/dm/private_chat_screen.dart';

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({
    Key key,
    @required this.userName,
    @required this.chatRoomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () async {
          print('Navigation to private chat screen with $userName');
          final Map<String, dynamic> user =
              await DatabaseMethods().getUserInfo(userName);
          Navigator.of(context).pushNamed(
            PrivateChatScreen.routeName,
            arguments: {
              'user': user,
              'chatRoomId': chatRoomId,
            },
          );
        },
        tileColor: Theme.of(context).primaryColor,
        leading: CircleAvatar(
          child: Text(
            userName.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        title: Text(
          userName,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
