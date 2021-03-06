import 'package:flutter/material.dart';
import 'package:chat/Screens/utils/colors.dart';
import 'package:chat/helper/sizeconfig.dart';
import 'package:chat/models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({Key key, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final messageBody = message.body;
    final fromMe = message.fromMe;
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(15.0),
        margin: fromMe
            ? EdgeInsets.only(
                right: 20.0,
                bottom: 20.0,
              )
            : EdgeInsets.only(
                left: 20.0,
                bottom: 20.0,
              ),
        decoration: BoxDecoration(
          gradient: fromMe ? chatBubbleGradient : chatBubbleGradient2,
          borderRadius: fromMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  topLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
        ),
        constraints: BoxConstraints(
          minHeight: 20.0,
          minWidth: 30.0,
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Center(
          child: Text(
            messageBody,
            style: TextStyle(
              color: fromMe ? Colors.black : Colors.black,
              fontSize: SizeConfig.safeBlockHorizontal * 4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
