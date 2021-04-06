//flutter packages are called here
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/views/pages/login_signup/login_form.dart';
import 'package:talawa/views/pages/login_signup/register_form.dart';
import 'package:talawa/views/pages/login_signup/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  //providing the initial states to the variables
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  loginScreenForm() => Center(
        child: Container(
            constraints: const BoxConstraints(
                maxWidth: 300.0, minWidth: 250.0, minHeight: 300.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30.0),
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                    //padding: EdgeInsets.all(100.0),
                    padding: EdgeInsets.fromLTRB(0,50,0,0),
                    child: Center(child: Image(image: AssetImage(UIData.talawaLogo))),
                  ),
                  LoginForm(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an account?",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 2.0),
                          child: TextButton(

                            child: const Text(
                                  "SIGN UP!",
                                  textAlign: TextAlign.start,
                                  style:
                                      const TextStyle(color: Colors.white,decoration: TextDecoration.underline),
                                ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterPage()));
                              },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
      );
  //main build starts here
  @override
  build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage(UIData.cloud1), fit: BoxFit.cover),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: loginScreenForm(),
            ),
          ),
        ));
  }
}
