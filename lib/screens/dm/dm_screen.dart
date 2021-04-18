import 'package:flutter/material.dart';

class DMScreen extends StatelessWidget {
  const DMScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Center(
          child: Text('Direct Messages'),
        ),
      ),
    );
  }
}
