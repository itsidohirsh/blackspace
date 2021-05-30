import 'package:flutter/material.dart';

import '../../providers/database.dart';
import '../../widgets/chat/chat_messages.dart';
import '../../widgets/chat/new_message.dart';
import '../Information_screen.dart';
import '../dm/dm_screen.dart';
import '../splash_screen.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Push notification
  // @override
  // void initState() {
  //   super.initState();
  //   final fbm = FirebaseMessaging();
  //   fbm.requestNotificationPermissions();
  //   fbm.configure(
  //     onMessage: (msg) {
  //       print(msg);
  //       return;
  //     },
  //     onLaunch: (msg) {
  //       print(msg);
  //       return;
  //     },
  //     onResume: (msg) {
  //       print(msg);
  //       return;
  //     },
  //   );
  // }

  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseMethods().getCurUserName(),
      builder: (context, nameSnapshot) {
        if (!nameSnapshot.hasData) {
          return SplashScreen();
        } else {
          return FutureBuilder(
            future: DatabaseMethods().getUserInfo(nameSnapshot.data),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return SplashScreen();
              } else {
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
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 100),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                        userSnapshot.data['image_url'],
                                      ),
                                      radius: 40,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${userSnapshot.data['username']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 32,
                                              ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Welcom to Blackspace'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.settings,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Text(
                                  'Information',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .pushNamed(SettingsScreen.routeName);
                                },
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                      appBar: AppBar(
                        brightness: Brightness.dark,
                        title: _curIndex == 0
                            ? Text('Chat')
                            : Text('Direct Messages'),
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
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                          DMScreen(),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
