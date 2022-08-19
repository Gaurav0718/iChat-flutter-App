import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ichat_app/allScreens/spalsh_page.dart';
import 'package:ichat_app/providers/auth_provider.dart';
import 'package:ichat_app/providers/chat_provider.dart';
import 'package:ichat_app/providers/home_provider.dart';
import 'package:ichat_app/providers/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isWhite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
              firebaseFirestore: firebaseFirestore,
              firebaseAuth: FirebaseAuth.instance,
              googleSignIn: GoogleSignIn(),
              prefs: this.prefs),
        ),
        Provider<SettingProvider>(
          create: (_) => SettingProvider(
              prefs: this.prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage),
        ),
        Provider<HomeProvider>(
            create: (_) =>
                HomeProvider(firebaseFirestore: this.firebaseFirestore)),
        Provider<ChatProvider>(
            create: (_) => ChatProvider(
                firebaseStorage: this.firebaseStorage,
                prefs: this.prefs,
                firebaseFirestore: this.firebaseFirestore)),
      ],
      child: MaterialApp(
        title: 'iChat App',
        theme: ThemeData(
          primaryColor: Colors.black,
        ),
        home: SpalshPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
