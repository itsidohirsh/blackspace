import 'package:flutter/material.dart';

import '../../providers/database.dart';
import '../../widgets/dm/chat_room_tile.dart';
import '../../widgets/my_loading_indicator.dart';

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
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      left: 10,
                      bottom: 0,
                    ),
                    child: Column(
                      children: [
                        ChatRoomsTile(
                          userName: snapshot
                              .data.documents[index].data['chatRoomId']
                              .toString()
                              .replaceAll("_", "")
                              .replaceAll(myName, ""),
                          chatRoomId:
                              snapshot.data.documents[index].data["chatRoomId"],
                        ),
                        Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  );
                })
            : MyLoadingIndicator();
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
    return chatRoomsList();
  }
}
