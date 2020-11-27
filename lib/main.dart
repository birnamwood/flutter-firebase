import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

//JSON
import 'dart:convert';
//post
import 'package:http/http.dart' as http;

void main() {
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
    String name = "sign in";
    IdTokenResult token;

  Future<AuthResult> signInAnon() async {
    AuthResult result = await firebaseAuth.signInAnonymously();
    print(result.user);
    return result;
  }

  Future<String> send() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    IdTokenResult tokenId = await user.getIdToken();
    String token = tokenId.token;

    if (token != null) {
      String url = "http://192.168.255.165:8000/api/v1/uid";
      Map<String, String> headers = {
        'content-type': 'application/json',
        'Authrization': '$token',
      };
      print(headers);
      String body = json.encode({'token': "token"});
      http.Response res = await http.post(url, headers: headers, body: body);
      print(res);
    }
    return "OK";
  }

  void signOut() {
    firebaseAuth.signOut();
    print('sign out');
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
            signInAnon().then((AuthResult result) {
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
          ]
        )
      )
    );
  }
}