import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final message;
  final datetime;
  final isMe;
  final read;

  MessageBubble({this.message, this.datetime, this.isMe, this.read});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: 140,
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: isMe ? Colors.purple[50] : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.roboto(
                    color: isMe ? Colors.black : Colors.white),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isMe)
                    Icon(
                      Icons.done_all,
                      size: 20,
                      color: read == 0 ? Colors.grey : Colors.purple,
                    ),
                  Text(
                    DateFormat().add_jm().format(
                          DateTime.parse(datetime),
                        ),
                    style: GoogleFonts.roboto(
                        color: isMe ? Colors.black : Colors.white),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
