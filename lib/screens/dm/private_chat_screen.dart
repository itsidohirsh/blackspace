import 'package:flutter/material.dart';

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

    final user = arguments['user'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Message ${user['username']}'),
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
        child: Text(user['email']),
      ),
    );
  }
}
