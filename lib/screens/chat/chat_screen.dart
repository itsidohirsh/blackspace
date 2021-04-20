import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../providers/database.dart';
import '../../widgets/chat/chat_messages.dart';
import '../../widgets/chat/new_message.dart';
import '../dm/dm_screen.dart';
import '../settings_screen.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
        return;
      },
      onLaunch: (msg) {
        print(msg);
        return;
      },
      onResume: (msg) {
        print(msg);
        return;
      },
    );
  }

  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMethods().getCurUserName(),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              drawer: Drawer(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Container(
                        height: 200,
                        child: Center(
                          child: Text(
                            'Hello, ${snapshot.data}',
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'settings',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(SettingsScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              appBar: AppBar(
                title: _curIndex == 0 ? Text('Chat') : Text('Direct Messages'),
                centerTitle: true,
                bottom: TabBar(
                  onTap: (index) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      _curIndex = index;
                    });
                  },
                  tabs: [
                    Tab(text: 'Chat'),
                    Tab(text: "DM"),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: ChatMessages(),
                        ),
                        NewMessage(),
                      ],
                    ),
                  ),
                  DMScreen(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
