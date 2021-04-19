import 'package:flutter/material.dart';

import '../../providers/database.dart';
import '../../widgets/dm/chat_room_tile.dart';

class DMScreen extends StatefulWidget {
  @override
  _DMScreenState createState() => _DMScreenState();
}

class _DMScreenState extends State<DMScreen> {
  Stream chatRooms;
  String myName;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.documents[index].data['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(myName, ""),
                    chatRoomId:
                        snapshot.data.documents[index].data["chatRoomId"],
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    myName = await DatabaseMethods().getCurUserName();
    setState(() {
      chatRooms = DatabaseMethods().getUserChats(myName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: chatRoomsList(),
      ),
    );
  }
}
