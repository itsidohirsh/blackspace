import '../../providers/database.dart';
import 'package:flutter/material.dart';

import '../dm/private_chat_screen.dart';

class UserDetailsScreenWithButton extends StatefulWidget {
  static const routeName = '/user-details-screen-with-button';

  const UserDetailsScreenWithButton({Key key}) : super(key: key);

  @override
  _UserDetailsScreenWithButtonState createState() =>
      _UserDetailsScreenWithButtonState();
}

class _UserDetailsScreenWithButtonState
    extends State<UserDetailsScreenWithButton> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    final user = arguments['user'];

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("${user['username']}'s details"),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 75,
              backgroundImage: NetworkImage(user['image_url']),
            ),
            Column(
              children: [
                Text(
                  user['username'],
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 30),
                ),
                SizedBox(height: 10),
                Text(user['email']),
              ],
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text('Send a private message to ${user['username']}'),
              onPressed: () async {
                final myName = await DatabaseMethods().getCurUserName();
                final otherUser = arguments['user'];
                String chatRoomId = '${myName}_${user['username']}';
                Navigator.of(context).pushNamed(
                  PrivateChatScreen.routeName,
                  arguments: {
                    'user': otherUser,
                    'chatRoomId': chatRoomId,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
