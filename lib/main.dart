import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//JSON
import 'dart:convert';
//post
import 'package:http/http.dart' as http;

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}


class MyHomePageState extends State<MyHomePage> {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

    String name = "sign in";
    String token;
    String fcmToken;

  Future<UserCredential> signInAnon() async {
    UserCredential userCredential = await firebaseAuth.signInAnonymously();
    print(userCredential);
    return userCredential;
  }

  Future<String> send() async {
    User user = firebaseAuth.currentUser;
    token = await user.getIdToken();
      print(token);

    if (token != null) {
      String url = "http://192.168.255.165:8000/system/v1/message/post";
      Map<String, String> headers = {
        'content-type': 'application/json',
        'Authrization': 'Bearer $token',
      };
      String body = json.encode({
        'linkClinicId': "1",
        'subject': "空診療所:次回予約のご案内",
        'body': "モリタ ビバリー 様\n\n " +
                "こんにちは、空診療所です。\n" +
                "\n" +
                "以下のようにご予約をお受けしておりましたが\n" +
                "\n" +
                "空 太郎の急病により、急遽診療をお休みさせていただきます。\n" +
                "\n" +
                "2020年12月31日12:00\n定期検診\n改行\n" +
                "痛みがある場合や、出血が止まらないなどありましたら\n" +
                "無理をなさらずにご連絡ください。\n" +
                "\n" +
                "\n" +
                "当院は予約制となっておりますので、お時間にはゆとりをもってお越しください。",
        'cardNo': ["1"],
        });
      // String body = json.encode({
      //   'macAddress': "f7ds8g:g76",
      //   'osVersion': "1.15.13",
      //   'deviceName': "deviceName",
      //   'fcmToken': fcmToken,
      //   });
      // String body = json.encode({
      //   'read': false,
      //   'limit': 5,
      //   'all': true,
      //   'clinicId': 1,
      //   'cardNo': "1"
      //   });
      http.Response res = await http.post(url, headers: headers, body: body);
      print(res.body);
    }
    return "OK";
  }

  void signOut() {
    firebaseAuth.signOut();
    print('sign out');
  }

  void getFCM() {
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
    firebaseMessaging.getToken().then((String fcm) {
      fcmToken = fcm;
      print(fcmToken);
    });
  }

  @override 
  Widget build(BuildContext context) {
    final loginButton = Container(
      padding: EdgeInsets.all(10.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.deepOrange,
        elevation: 10.0,
        child: MaterialButton(
          minWidth: 150.0,
          height: 50.0,
          color: Colors.orange,
          child: Text(name),
          onPressed: () {
              name = "signed in";
            signInAnon().then((UserCredential result) {
            });
          },
        ),
      )
    );

    final logoutButton = Container(
      padding: EdgeInsets.all(10.0),
      child: FlatButton(
        color: Colors.white,
        onPressed: () {
          signOut();
        },
        child: Text(
          "Sign Out",
          style: TextStyle(color: Colors.black),
        )
      )
    );

    final sendButton = Container(
      padding: EdgeInsets.all(10.0),
      child: FlatButton(
        color: Colors.blue,
        onPressed: () {
          send();
        },
        child: Text(
          "Send",
          style: TextStyle(color: Colors.black),
        )
      )
    );

    final fcmButton = Container(
      padding: EdgeInsets.all(10.0),
      child: FlatButton(
        color: Colors.blue,
        onPressed: () {
          getFCM();
        },
        child: Text(
          "GetFCMToken",
          style: TextStyle(color: Colors.black),
        )
      )
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("login"),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            loginButton,
            logoutButton,
            sendButton,
            fcmButton,
          ]
        )
      )
    );
  }
}