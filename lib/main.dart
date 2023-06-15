import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/screens/splash_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/localizations_delegate.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';
import 'utils/localization/locale_constant.dart';

//Firebase Notification initialization
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print('Message map: ${message.toMap()}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceUtil.getInstance();
  await PreferenceUtils.init();
  HttpOverrides.global = MyHttpOverrides();
  Stripe.publishableKey =
      PreferenceUtils.getString(Constants.appStripePublishKey).isNotEmpty
          ? PreferenceUtils.getString(Constants.appStripePublishKey)
          : 'N/A';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

//Firebase Notification initialization
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyCHI5EEBZQWNQ_mVxuxO4RAtQacZ1drBcE',
        appId: '1:849512019728:android:3527b2e5b26a7bc1961795',
        messagingSenderId: '849512019728',
        projectId: 'foodcartdeliveryapp'),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final fcmToken = await messaging.getToken();
  print('fcmToken:= $fcmToken');
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print('Message map: ${message.toMap()}');
    print("onMessageOpenedApp: ${message.data}");

    // if (message.data["navigation"] == "/your_route") {
    //   int _yourId = int.tryParse(message.data["id"]) ?? 0;
    //   Navigator.push(navigatorKey.currentState!.context,
    //       MaterialPageRoute(builder: (context) => Staff(isActionBar: true)));
    // }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  ///Managing local notification///

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      // android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
    //      onSelectNotification: (payload) async {
    //   print("onMessageOpenedAppLocal: $payload");

    // }
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  ///End of managing local notification///

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message map: ${message.toMap()}');
    print('Message data: ${message.data}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      print('Message also contained a notification: ${message.notification}');
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, channel.name,
            channelDescription: channel.description,
            // icon: '@mipmap/launcher_icon',
            priority: Priority.high,
            // other properties...
          ),
        ),
        // payload: message.notification.title
        //         .contains("Do you want to confirm your booking")
        //     ? "confirm" + message.data['booking']
        //     : message.data['booking']
      );
    }
  });

  runApp(MyApp(
    model: CartModel(),
  ));
}

class MyApp extends StatefulWidget {
  final CartModel model;

  const MyApp({Key? key, required this.model}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      enableLoadingWhenNoData: true,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      child: ScopedModel<CartModel>(
        model: widget.model,
        child: MaterialApp(
          locale: _locale,
          supportedLocales: [
            Locale('en', ''),
            Locale('es', ''),
            Locale('ar', ''),
          ],
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Constants.colorBackground,
          ),
          home: SplashScreen(
            model: widget.model,
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, host, port) => true;
  }
}
