import 'package:flutter/material.dart';
import 'package:ichat_app/allScreens/home_page.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';

class SpalshPage extends StatefulWidget {
  const SpalshPage({Key? key}) : super(key: key);

  @override
  _SpalshPageState createState() => _SpalshPageState();
}

class _SpalshPageState extends State<SpalshPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                child: Image.asset(
              "images/splash.png",
              height: 300,
              width: 300,
            )),
            SizedBox(
              height: 20,
            ),
            Text(
              "Welcome to the i-Chat App",
              style: TextStyle(
                color: ColorConstants.themeColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
