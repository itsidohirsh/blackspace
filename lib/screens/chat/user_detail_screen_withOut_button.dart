import 'package:flutter/material.dart';

class UserDetailsScreenWithOutButton extends StatefulWidget {
  static const routeName = '/user-details-screen-withOut-button';

  const UserDetailsScreenWithOutButton({Key key}) : super(key: key);

  @override
  _UserDetailsScreenWithOutButtonState createState() =>
      _UserDetailsScreenWithOutButtonState();
}

class _UserDetailsScreenWithOutButtonState
    extends State<UserDetailsScreenWithOutButton> {
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
              radius: 125,
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
          ],
        ),
      ),
    );
  }
}
