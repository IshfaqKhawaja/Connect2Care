import 'package:connect2care/widgets/messages.dart';
import 'package:connect2care/widgets/new_message.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final senderId = routeArgs['senderId'];
    final recieverId = routeArgs['recieverId'];
    final username = routeArgs['username'];
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Messages(
            senderId: senderId,
            recieverId: recieverId,
          ),
          NewMessage(
            senderid: senderId,
            recieverId: recieverId,
          ),
        ],
      ),
    );
  }
}
