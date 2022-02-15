import 'dart:math';

import 'package:flutter/material.dart';
import 'package:chat/Screens/videoCall/call.dart';
import 'package:chat/Screens/videoCall/call_method.dart';
import 'package:chat/Screens/videoCall/call_screen.dart';
import 'package:chat/Screens/videoCall/user.dart';
import 'package:chat/Screens/videoCall/voiceCall_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({User from, User to, context, status, callType}) async {
    Call call = Call(
        callerId: from.uid,
        callerName: from.name,
        callerPic: from.profilePhoto,
        receiverId: to.uid,
        receiverName: to.name,
        receiverPic: to.profilePhoto,
        channelId: Random().nextInt(1000).toString(),
        stype: status,
        callType: callType);

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      if (status == "videocall") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(call: call),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VoiceCallScreen(
                  call: call, recName: to.name, recImage: to.profilePhoto),
            ));
      }
    }
  }
}
