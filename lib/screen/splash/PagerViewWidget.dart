import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentors/HexColor.dart';
import 'package:rentors/bloc/LoginBloc.dart';
import 'package:rentors/event/SocialLoginEvent.dart';
import 'package:rentors/generated/l10n.dart';
import 'package:rentors/screen/splash/Page1Widget.dart';
import 'package:rentors/screen/splash/Page2Widget.dart';
import 'package:rentors/screen/splash/Page3Widget.dart';
import 'package:rentors/state/OtpState.dart';
import 'package:rentors/state/SignInWithEmailState.dart';
import 'package:rentors/util/Utils.dart';
import 'package:rentors/widget/ProgressDialog.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'dart:convert' show utf8;
import 'dart:math';
import 'package:crypto/crypto.dart';
class PagerViewWidget extends StatelessWidget {
  LoginBloc mBloc = new LoginBloc(LoadingState());
  ProgressDialog dialog;
  final PageController _controller = PageController(
    initialPage: 0,
  );

  checkLogin(BuildContext context) async {
    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      var user = await Utils.getUser();
      if (user != null) {
        Navigator.of(context).popAndPushNamed("/home");
      } else {
        Navigator.of(context).pushNamed("/otp");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // checkLogin(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              children: [Page1Widget(), Page2Widget(), Page3Widget()],
            ),
            Positioned.fill(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed("/otp");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                          child: Text(
                            S.of(context).connectViaMobile,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          margin: EdgeInsets.only(left: 30, right: 30),
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5),
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Divider(
                                color: Colors.white,
                                thickness: 1.5,
                              )),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(S.of(context).or,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                          Expanded(
                              child: Divider(
                                color: Colors.white,
                                thickness: 1.5,
                              )),
                        ]),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/email");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              S.of(context).connectViaEmail,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 20, bottom: 20),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                          )),
                      InkWell(
                          onTap: () {
                            signInWithGoogle().then((value) => {
                              mBloc.add(SocialLoginEvent(
                                  'gplus',
                                  value.user.uid,
                                  value.user.displayName,
                                  value.user.displayName,
                                  'token')),
                              mBloc.listen((state) {
                                if (state is ProgressDialogState) {
                                  dialog = ProgressDialog(context,
                                      isDismissible: true);
                                  dialog.show();
                                } else {
                                  if (dialog != null && dialog.isShowing()) {
                                    dialog.hide();
                                  }
                                  if (state is SignInWithEmailState) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                        "/home", (Route<dynamic> route) => false);
                                  }
                                }
                              })
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            child: Stack(
                              children: [
                                Image.asset('assets/img/google.png',width: 25,),
                                Center(child: Text(
                                  'Sign in with Google',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                                ),)
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 10),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                          )),
                      Platform.isIOS?
                      InkWell(
                          onTap: () {
                            signInWithApple().then((value) => {
                              mBloc.add(SocialLoginEvent(
                                  'apple',
                                  value.user.uid,
                                  value.user.displayName,
                                  value.user.displayName,
                                  '')),
                              mBloc.listen((state) {
                                if (state is ProgressDialogState) {
                                  dialog = ProgressDialog(context,
                                      isDismissible: true);
                                  dialog.show();
                                } else {
                                  if (dialog != null && dialog.isShowing()) {
                                    dialog.hide();
                                  }
                                  if (state is SignInWithEmailState) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                        "/home", (Route<dynamic> route) => false);
                                  }
                                }
                              })
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: HexColor('#000000'),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            child:Stack(
                              children: [
                                Align(child: Padding(
                                  child: Image.asset('assets/img/apple_logo.png',width: 20,),
                                  padding: EdgeInsets.only(top: 2,left: 10),
                                ),alignment: AlignmentDirectional.centerStart,),
                                Align(child: Text(
                                  'Sign in with Apple',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 18,),
                                ),alignment: AlignmentDirectional.center,),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 10),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                          ))
                          :SizedBox(),
                      InkWell(
                          onTap: () {
                            signInWithFacebook().then((value) => {
                              mBloc.add(SocialLoginEvent(
                                  'fb',
                                  value.user.uid,
                                  value.user.displayName,
                                  value.user.displayName,
                                  'token')),
                              mBloc.listen((state) {
                                if (state is ProgressDialogState) {
                                  dialog = ProgressDialog(context,
                                      isDismissible: true);
                                  dialog.show();
                                } else {
                                  if (dialog != null && dialog.isShowing()) {
                                    dialog.hide();
                                  }
                                  if (state is SignInWithEmailState) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                        "/home", (Route<dynamic> route) => false);
                                  }
                                }
                              })
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: HexColor('#3B5998'),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            child: Stack(
                              children: [
                                Image.asset('assets/img/facebook.png',width: 25),
                                Center(child: Text(
                                  'Sign in with Facebook',
                                  textAlign: TextAlign.center,
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                                ))
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10, bottom: 20),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                          )),


                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {

    var result =  await FacebookAuth.instance.login();
    print(result.message);
    final facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken.token);

    return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }
  Future<bool> isAppleSignInAvailable() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      debugPrint('$systemName $version, $name $model');
      var iosVer = double.parse(version);
      //debugPrint(iosVer);
      if(iosVer >= 13){
        return true;
      }
      else{
        return true;
      }
      // iOS 13.1, iPhone 11 Pro Max iPhone
    }
    debugPrint('return false');
    print('return False');
    return false;
  }
}

