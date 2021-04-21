import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/user_detail_screen_withOut_button.dart';
import 'screens/chat/user_details_screen_with_button.dart';
import 'screens/dm/private_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/my_loading_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blackspace',
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.black,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.black,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return MyLoadingIndicator();
          }
          if (userSnapshot.hasData) {
            return ChatScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        UserDetailsScreenWithButton.routeName: (ctx) =>
            UserDetailsScreenWithButton(),
        UserDetailsScreenWithOutButton.routeName: (ctx) =>
            UserDetailsScreenWithOutButton(),
        ChatScreen.routeName: (ctx) => ChatScreen(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AuthScreen.routeName: (ctx) => AuthScreen(),
        PrivateChatScreen.routeName: (ctx) => PrivateChatScreen(),
      },
    );
  }
}
