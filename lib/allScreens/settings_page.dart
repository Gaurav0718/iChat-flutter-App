import 'dart:ui';

import 'package:country_pickers/country.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:ichat_app/allConstants/constants.dart';
import 'package:ichat_app/allConstants/firestore_constants.dart';
import 'package:ichat_app/allModels/user_chat.dart';
import 'package:ichat_app/allWidgets/loading_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../main.dart';
import '../providers/setting_provider.dart';
import 'home_page.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        // iconTheme: IconThemeData(
        //   color: ColorConstants.primaryColor,
        // ),
        title: Text(
          AppConstants.settingsTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          // Navigator.of(context).pop();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage()));
        }, icon: Icon(Icons.arrow_back_sharp, color: ColorConstants.primaryColor,)),

      ),
      body: SettingsPageState(),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  _SettingsPageStateState createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {

  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  TextEditingController? controllerPhoneNumber;


  String dialCodeDigits = "+00";
  final TextEditingController _controller = TextEditingController();

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String phoneNumber = '';

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();
  final FocusNode focusNodePhoneNumber = FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal () {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "";
      nickname = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      aboutMe = settingProvider.getPref(FirestoreConstants.aboutMe) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
      phoneNumber = settingProvider.getPref(FirestoreConstants.phoneNumber) ?? "";
    });

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    }); // need to learn error handling on this line
    File? image;
    if(pickedFile != null) {
      image = File(pickedFile.path);
    }
    if(image != null) {
      setState(() {
        avatarImageFile = image as File? ;
        isLoading  = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
  String fileName = id;
  UploadTask uploadTask = settingProvider.uploadFile(avatarImageFile!, fileName);
  try{
    TaskSnapshot snapshot = await uploadTask;
    photoUrl = await snapshot.ref.getDownloadURL();
    UserChat updateInfo = UserChat(id: id,
        photoUrl: photoUrl,
        nickname: nickname,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber);
    settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson()).then((data) async {
      await settingProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
      setState(() {
        isLoading = false;
      });
    }).catchError((err){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }on FirebaseException catch (e) {
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: e.message ?? e.toString());

  }
  }

 void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;

      if(dialCodeDigits != "+00" && _controller.text != "") {
        phoneNumber = dialCodeDigits + _controller.text.toString();
      }
    });
    UserChat updateInfo = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: nickname,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber);
    settingProvider.updateDataFirestore(FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
    .then((data) async {
      await settingProvider.setPrefs(FirestoreConstants.nickname, nickname);
      await settingProvider.setPrefs(FirestoreConstants.aboutMe, aboutMe);
      await settingProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
      await settingProvider.setPrefs(FirestoreConstants.phoneNumber, phoneNumber);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Update Sucess");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
 }

  final countryPicker = FlCountryCodePicker();
  CountryCode? countryCode;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
            padding: EdgeInsets.only(left: 15,right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton( onPressed: getImage,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: avatarImageFile == null ? photoUrl.isNotEmpty ? ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.network(photoUrl, fit: BoxFit.cover, width: 90, height: 90,
                        errorBuilder:  (context,object, stackTrace) {
                      return Icon(Icons.account_circle, size: 90, color: ColorConstants.greyColor,);
                        },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
                      if(loadingProgress == null) return child;
                      return Container(
                        width: 90, height: 90,
                        child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ?
                          loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        ),
                        )
                        );
                        }
                    ),
                  ) : Icon(
                    Icons.account_circle,
                    size: 90,
                    color: ColorConstants.greyColor,
                  ) : ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.file(
                      avatarImageFile!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text("Name", style: TextStyle(
                        fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor
                      ),
                      ),
                      margin: EdgeInsets.only(left: 10,bottom: 5,top: 10),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.grey
                          ),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.greyColor2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorConstants.primaryColor
                              )
                            ),
                            hintText: "Write your name .... ",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(color: ColorConstants.greyColor)
                          ),
                          controller: controllerNickname,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: focusNodeNickname,
                        ),
                      ),
                    ),
                    Container(
                      child: Text("About Me", style: TextStyle(
                          fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor
                      ),
                      ),
                      margin: EdgeInsets.only(left: 10,bottom: 5,top: 10),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          style: TextStyle(
                              color: Colors.grey
                          ),
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ColorConstants.greyColor2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorConstants.primaryColor
                                  )
                              ),
                              hintText: "Write something about yourself",
                              contentPadding: EdgeInsets.all(5),
                              hintStyle: TextStyle(color: ColorConstants.greyColor)
                          ),
                          controller: controllerAboutMe,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: focusNodeAboutMe,
                        ),
                      ),
                    ),
                    Container(
                      child: Text("Phone Number", style: TextStyle(
                          fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: ColorConstants.primaryColor
                      ),
                      ),
                      margin: EdgeInsets.only(left: 10,bottom: 5,top: 10),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          cursorHeight: 25,
                          keyboardType: TextInputType.number,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 18
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              padding: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () async{
                                      final code = await countryPicker.showPicker(context: context);
                                      setState(() {
                                     countryCode = code;
                                        });
                                      },
                                    child: Row(
                                      children: [
                                        Container(
                                          child: countryCode!=null ? countryCode!.flagImage : null,
                                        ),
                                        SizedBox(width: 5,),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorConstants.primaryColor,
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                            child: Text(countryCode?.dialCode ?? "+1", style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                              hintText: phoneNumber,
                              contentPadding: EdgeInsets.all(5),
                              hintStyle: TextStyle(color: Colors.grey)
                          ),
                          controller: controllerPhoneNumber,
                          onChanged: (value) {
                            phoneNumber = value;
                          },
                          focusNode: focusNodePhoneNumber,
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 10, top: 30, bottom: 5),
                    //   child: SizedBox(
                    //     width: 400,
                    //     height: 60,
                    //     child: GestureDetector(
                    //       onTap: () async {
                    //         final code = await countryPicker.showPicker(context: context);
                    //         if(code!=null) print(code);
                    //       },
                    //       child: Container(
                    //       padding: const EdgeInsets.symmetric(
                    //       horizontal: 8.0, vertical: 4.0),
                    //       margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    //        decoration: const BoxDecoration(
                    //               color: Colors.blue,
                    //             borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    //           child: Text('Show Picker',
                    //             style: const TextStyle(color: Colors.white)),
                    //         ),
                    //     ),
                    //     )
                    // ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 50, bottom: 50),
                        child: TextButton(
                          onPressed: handleUpdateData,
                          child: Text("Update Now", style: TextStyle(
                            fontSize: 18, color: Colors.white
                          ),),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.primaryColor),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.fromLTRB(30, 10, 30, 10),
                            )
                          ),

                        ),
                      ),
                    )



                  ],
                )
              ],
            )
        ),
        Positioned(
          child: isLoading ? LoadingView() : SizedBox.shrink(),
        )
      ],
    );
  }
}

