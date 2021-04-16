import 'package:flutter/material.dart';

import '../dm/private_chat_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  static const routeName = '/user-details-screen';

  const UserDetailsScreen({Key key}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments;
    final user = arguments['user'];

    return Scaffold(
      appBar: AppBar(
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  PrivateChatScreen.routeName,
                  arguments: {'user': arguments['user']},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
