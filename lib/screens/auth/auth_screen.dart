import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../widgets/auth/auth_form.dart';
import '../chat/chat_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String username,
    String password,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(authResult.user.uid + '.jpg');

        await ref.putFile(image);

        final url = await ref.getDownloadURL();

        // Add user to firestore db
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        });
      }
    } catch (_) {
      String _message = 'Invalid email or password';

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }

    if (FirebaseAuth.instance.currentUser != null && _isLoading != false) {
      Navigator.of(context).popAndPushNamed(ChatScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: AuthForm(
          _submitAuthForm,
          _isLoading,
        ),
      ),
    );
  }
}
