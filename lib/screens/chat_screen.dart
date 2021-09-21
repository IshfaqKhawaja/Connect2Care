import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect2care/screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool getUserList = false;
  Widget chatUsers(String userId) {
    return Card(
      elevation: 6,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(userId)
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> chatSnapShots) {
          if (chatSnapShots.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final chats = chatSnapShots.data!.docs;
          // print(chats);
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, index) {
              if (chats[index].id != userId)
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                  padding: EdgeInsets.all(2),
                  child: Card(
                    child: Container(
                      color: chats[index]['unread'] == 1
                          ? Colors.grey[200]
                          : Colors.white,
                      child: ListTile(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .doc(userId)
                              .collection('users')
                              .doc(chats[index].id)
                              .update({'unread': 0});

                          Navigator.of(context)
                              .pushNamed(Chat.routeName, arguments: {
                            "recieverId": chats[index].id,
                            "senderId": userId,
                            'username': chats[index]['username'],
                          });
                        },
                        leading: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Text(
                              chats[index]['username'][0],
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          chats[index]['username'],
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          chats[index]['recentText'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              else
                return SizedBox();
            },
          );
          ;
        },
      ),
    );
  }

  Widget userList(userId) {
    return Card(
      elevation: 6,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> chatSnapShots) {
          if (chatSnapShots.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final chats = chatSnapShots.data!.docs;
          print(chats);
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (ctx, index) {
              if (chats[index].id != userId)
                return Container(
                  margin: EdgeInsets.all(1),
                  padding: EdgeInsets.all(4),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(Chat.routeName, arguments: {
                          "recieverId": chats[index].id,
                          "senderId": userId,
                          'username': chats[index]['details']['username'],
                        });
                      },
                      leading: Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Text(
                            chats[index]['details']['username'][0],
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        chats[index]['details']['username'],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              else
                return SizedBox();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    print('userId $userId');
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(20),
      child: Stack(children: [
        getUserList ? userList(userId) : chatUsers(userId),
        Positioned(
          right: 15,
          bottom: 15,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                getUserList = !getUserList;
              });
            },
            child: Icon(Icons.message),
          ),
        ),
      ]),
    );
  }
}
