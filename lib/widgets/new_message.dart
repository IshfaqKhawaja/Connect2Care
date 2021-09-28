import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewMessage extends StatefulWidget {
  final senderid;
  final recieverId;
  NewMessage({this.senderid, this.recieverId});

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredText = '';
  final _textController = TextEditingController();

  void _sendMessage() async {
    // print(widget.senderid);
    // print(widget.recieverId);
    if (_enteredText.isNotEmpty) {
      try {
        _textController.text = '';

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.senderid)
            .collection('users')
            .doc(widget.recieverId)
            .collection('messages')
            .add({
          'text': _enteredText,
          'createdAt': Timestamp.now(),
          'date': DateTime.now().toIso8601String(),
          'userId': widget.senderid,
          'read': 0,
          'type': 'text',
        });
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.recieverId)
            .collection('users')
            .doc(widget.senderid)
            .collection('messages')
            .add({
          'text': _enteredText,
          'createdAt': Timestamp.now(),
          'date': DateTime.now().toIso8601String(),
          'userId': widget.senderid,
          'read': 0,
          'type': 'text',
        });
        var response = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.recieverId)
            .get();
        // print('response is ${response['details']['username']}');
        // print('username is $username');
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.senderid)
            .collection('users')
            .doc(widget.recieverId)
            .set({
          'username': response['details']['username'],
          'createdAt': Timestamp.now(),
          'unread': 0,
          'recentText': _enteredText,
        });
        response = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderid)
            .get();

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.recieverId)
            .collection('users')
            .doc(widget.senderid)
            .set({
          'username': response['details']['username'],
          'createdAt': Timestamp.now(),
          'unread': 1,
          'recentText': _enteredText,
        });

        setState(() {
          _enteredText = '';
        });
      } on PlatformException catch (err) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('$err'),
        ));
      } catch (err) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Send a Message',
              ),
              onChanged: (value) {
                setState(() {
                  _enteredText = value;
                });
              },
            )),
            IconButton(
              onPressed: _enteredText.isEmpty ? null : _sendMessage,
              icon: Icon(
                Icons.send,
                color: _enteredText.isEmpty
                    ? Colors.grey
                    : Theme.of(context).errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
