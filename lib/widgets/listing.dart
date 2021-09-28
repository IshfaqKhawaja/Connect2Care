import 'package:connect2care/screens/chat.dart';
import 'package:connect2care/screens/edit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Listing extends StatelessWidget {
  final docId;
  final category;
  final title;
  final description;
  final location;
  final willpay;
  final amount;
  final userId;
  final recieverId;
  final username;
  final edit;
  Listing({
    this.docId,
    this.category,
    this.title,
    this.description,
    this.location,
    this.willpay,
    this.amount,
    this.userId,
    this.recieverId,
    this.username,
    this.edit,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xffe46b10)],
        ),
      ),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (willpay)
                      Chip(
                        backgroundColor: Colors.amber,
                        label: FittedBox(
                          child: Text(
                            'Incentive $amount',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 10,
                    ),
                    Chip(
                      backgroundColor: Colors.green,
                      label: Text(
                        category,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(
                      Icons.room_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      location,
                      style: GoogleFonts.roboto(
                        color: Colors.blueGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (userId != recieverId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(Chat.routeName, arguments: {
                          "recieverId": recieverId,
                          "senderId": userId,
                          'username': username,
                        });
                      },
                      icon: Icon(
                        Icons.reply,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              if (edit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return Dialog(
                                child: Edit(
                                  docId: docId,
                                  locationDetails: location,
                                  amount: amount,
                                  category: category,
                                  description: description,
                                  title: title,
                                  willPay: willpay,
                                ),
                              );
                            });
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
