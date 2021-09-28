import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect2care/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  final senderId;
  final recieverId;
  Messages({this.senderId, this.recieverId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(senderId)
          .collection('users')
          .doc(recieverId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> chatsSnapShot) {
        if (chatsSnapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final docs = chatsSnapShot.data!.docs;
        // print('docs $docs');

        return Expanded(
          child: ListView.builder(
              reverse: true,
              itemCount: docs.length,
              itemBuilder: (ctx, index) {
                final isMe = docs[index]['userId'] == senderId;
                // print(isMe);
                if (!isMe)
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(senderId)
                      .collection('users')
                      .doc(recieverId)
                      .collection('messages')
                      .doc(docs[index].id)
                      .update({'read': 1});

                return MessageBubble(
                  message: docs[index]['text'],
                  datetime: docs[index]['date'],
                  isMe: isMe,
                  read: docs[index]['read'],
                );
              }),
        );
      },
    );
  }
}
