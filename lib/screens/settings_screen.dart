import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings-screen';

  const SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete a message\n',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    'To delete a message you sent, long press on your message.',
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact a user\n',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    'To see more details about a user, long press on a message they have sent.\n\nFrom there you can send them a message.',
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            RaisedButton(
              child: Text('Sign Out'),
              onPressed: () async {
                await signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AuthScreen.routeName,
      (route) => route == '/',
    );
  }
}
