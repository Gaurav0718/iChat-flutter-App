import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:ichat_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {

    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
      Fluttertoast.showToast(msg: "Sign in cancelled");
      break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "sign in sucess");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "sign in cancelled");
break;
      default:
        break;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              child: Image.asset("images/back.png"),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                bool isSuccess  = await authProvider.handleSignIn();
                if(isSuccess){
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomePage()));
                }
              },
              child: Image.asset("images/google_login.jpg"),
            ),
          ),
          Positioned(child:
          authProvider.status == Status.authenticating ? LoadingView() : SizedBox.shrink())
        ],
      ),
    );
  }
}
