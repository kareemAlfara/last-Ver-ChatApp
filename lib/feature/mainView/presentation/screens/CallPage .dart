import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const int appID = 1204968830; // ضع AppID هنا
const String appSign = "b70739c070ccd42f1c9910fc04d2bee5ea49289a1a80f4a066cd7ac44cc9a365"; // ضع AppSign هنا

class CallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final bool isVideo;

  const CallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    this.isVideo = true,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      callID: callID,
      config: isVideo
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}
