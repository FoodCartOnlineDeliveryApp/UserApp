import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../retrofit/api_client.dart';
import '../retrofit/api_header.dart';
import '../retrofit/base_model.dart';
import '../retrofit/server_error.dart';
import 'SharedPreferenceUtil.dart';
import 'constants.dart';

class FCMNotification {
  static Future addRemoveFCMToken(BuildContext context, {int processType = 1}) async {
    try {
      Constants.onLoading(context);
      final userId = SharedPreferenceUtil.getString(
        Constants.loginUserId,
      );
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.deleteToken(); // deleting old token
      final fcmToken = await messaging.getToken(); // creating new token
      int platform;
      if (Platform.isAndroid) {
        platform = 1;
      } else {
        platform = 2;
      }

      Map<String, dynamic> body = {
        "user_id": userId,
        "user_type": "User",
        "user_platform": platform,
        "token": fcmToken,
        "process_type": processType
      };
      print("fcmRequestBody $body");

      final response =
          await RestClient(RetroApi().dioData()).addRemoveFCMToken(body);
      print("fcmResponse $response");
      Constants.hideDialog(context);
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
  }
}
