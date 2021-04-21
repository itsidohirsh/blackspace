import 'package:flutter/material.dart';

import '../../widgets/dm/new_private_message.dart';
import '../../widgets/dm/private_messages.dart';
import '../chat/user_detail_screen_withOut_button.dart';

class PrivateChatScreen extends StatefulWidget {
  static const routeName = '/private-chat-screen';

  const PrivateChatScreen({Key key}) : super(key: key);

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments;

    final chatRoomId = arguments['chatRoomId'];
    final user = arguments['user'];

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 75,
        title: Row(
          children: [
            Text('Message ' + user['username']),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  UserDetailsScreenWithOutButton.routeName,
                  arguments: {'user': user},
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(user['image_url']),
                radius: 30,
              ),
            ),
          ],
        ),
        leadingWidth: 50,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: PrivateMessages(
                chatRoomId: chatRoomId,
                user: user,
              ),
            ),
            NewPrivateMessage(
              chatRoomId: chatRoomId,
              user: user,
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
