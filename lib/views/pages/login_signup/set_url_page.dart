import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:http/http.dart' as http;
import 'package:talawa/views/pages/login_signup/login_page.dart';
import 'package:talawa/views/pages/login_signup/sign_up_page.dart';

class UrlPage extends StatefulWidget {
  @override
  _UrlPageState createState() => _UrlPageState();
}

bool first = true;

void changeFirst() {
  first = false;
}

class _UrlPageState extends State<UrlPage> with TickerProviderStateMixin<UrlPage> {

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  var _media;
  final _formKey = GlobalKey<FormState>();
  final urlController = TextEditingController();
  String dropdownValue = 'http';
  Preferences _pref = Preferences();
  String orgUrl, orgImgUrl;
  String saveMsg = "Set URL";
  String urlInput;
  FToast fToast;
  bool isUrlCalled = false;
  //animation Controllers
  AnimationController controller;
  AnimationController loginController;
  AnimationController helloController;
  AnimationController createController;
  // animation
  Animation loginAnimation;
  Animation createAnimation;
  Animation animation;
  Animation helloAnimation;


  listenToUrl() {
    if (saveMsg == "URL SAVED!" && urlController.text != urlInput) {
      setState(() {
        saveMsg = "Set URL";
      });
    }
    urlInput = urlController.text;
  }

  Future<void> checkAndSetUrl() async {
    setState(() {
      isUrlCalled = true;
    });

    try {
      await http.get('${dropdownValue.toLowerCase()}://${urlController.text}/');

      setApiUrl();
      _setURL();
    } catch (e) {
      _errorScaffold('Incorrect Organization URL Entered');
    }

    setState(() {
      isUrlCalled = false;
    });
  }

  Future setApiUrl() async {
    setState(() {
      orgUrl =
          "${dropdownValue.toLowerCase()}://${urlController.text}/";
      orgImgUrl =
          "${dropdownValue.toLowerCase()}://${urlController.text}/";
    });
    await _pref.saveOrgUrl(orgUrl);
    await _pref.saveOrgImgUrl(orgImgUrl);
  }

  void _setURL() {
    setState(() {
      saveMsg = "URL SAVED!";
    });
  }

  // _exceptionToast(String msg) {
  //   Widget toast = Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15.0),
  //       color: Colors.red,
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Expanded(
  //           child: Text(
  //             msg,
  //             style: TextStyle(fontSize: 15.0, color: Colors.white),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   fToast.showToast(
  //     child: toast,
  //     gravity: ToastGravity.BOTTOM,
  //     toastDuration: Duration(seconds: 5),
  //   );
  // }

  //Created Snack bar for displaying errors
  _errorScaffold(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(fontSize: 15.0, color: Colors.white,fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: (){
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void assignAnimation(bool firstTime) {
    if (!firstTime) {
      animation = Tween(begin: 1.0, end: 1.0).animate(controller);

      helloAnimation = Tween(begin: 1.0, end: 1.0).animate(helloController);

      createAnimation = Tween(begin: 1.0, end: 1.0).animate(createController);

      loginAnimation = Tween(begin: 1.0, end: 1.0).animate(loginController);
    } else {
      loginAnimation = Tween(begin: 0.0, end: 1.0).animate(loginController);

      createAnimation = Tween(begin: 0.0, end: 1.0).animate(createController);

      animation = Tween(begin: 0.0, end: 1.0).animate(controller);

      helloAnimation = Tween(begin: 0.0, end: 1.0).animate(helloController);
    }
  }
  Future<void> load() async {
      await controller?.forward();
      await helloController?.forward();
      await createController?.forward();
      await loginController?.forward();
      changeFirst();
  }
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    urlController.addListener(listenToUrl);
    // Initializing all the animationControllers
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    loginController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    helloController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    createController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }



  @override
  Widget build(BuildContext context) {
    assignAnimation(first);
    load();
    Widget mainScreen() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FadeTransition(
            opacity: animation,
            child: Container(
              //padding: EdgeInsets.all(100.0),
              padding: EdgeInsets.fromLTRB(0,50,0,0),
              child: Center(child: Image(image: AssetImage(UIData.talawaLogo))),
            ),
          ),
          Container(
            width: _media != null
                ? _media.size.width
                : MediaQuery.of(context).size.width,
            child: FadeTransition(
              opacity: helloAnimation,
              child: Center(
                child: Text(
                  "Talawa",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
              ),
            ),
          ),
          Container(
            //container with login,url and sign up button
            padding: EdgeInsets.fromLTRB(0, 30, 0, 50),
            child: Column(
              children: <Widget>[
                FadeTransition(
                  opacity: createAnimation,
                  child: Container(
                    width: _media != null
                        ? _media.size.width
                        : MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 20.0, right: 30.0, top: 10.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.black,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: DropdownButton<String>(  //http dropdown menu
                                  value: dropdownValue,
                                  icon: Icon(Icons.arrow_drop_down_circle_rounded,
                                      color: Colors.white),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  style: TextStyle(color: Colors.white,fontSize: 18),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                      saveMsg = 'Set URL';
                                    });
                                  },
                                  items: <String>[
                                    'http',
                                    'https'
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded( // org url form field
                              child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    keyboardType: TextInputType.url,
                                    validator: (value) =>
                                        Validator.validateURL(
                                            urlController.text),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white,width: 5),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white,width: 3),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      prefixIcon: Icon(Icons.add_link,
                                          color: Colors.white,size: 30,),
                                      labelText: "Type Organization URL Here",
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                     // alignLabelWithHint: true,
                                      hintText: 'www.organisation.com',
                                      hintStyle:
                                          TextStyle(color: Colors.grey),
                                    ),
                                    controller: urlController,
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row( // set url button
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                                   primary: Colors.black.withOpacity(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide(color: Colors.white,width: 4),
                                  ),
                                ),
                                child: isUrlCalled
                                    ? SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                            backgroundColor: Colors.white),
                                      )
                                    : Text(
                                        saveMsg,
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                      ),
                                //color: Colors.white,
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    await checkAndSetUrl();
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FadeTransition(
                  //changed opacity animation to match login button animation
                  opacity: loginAnimation,
                  child: Container(
                    width: _media != null
                        ? _media.size.width
                        : MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        left: 50.0, right: 50.0, top: 10.0),
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                         Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black12,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,width: 5)
                              ),
                            ),
                            onPressed: saveMsg != "URL SAVED!"
                                ? null
                                : () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUpPage()),
                                               // RegisterPage()),
                                      );
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Image(image: AssetImage("assets/Icons/add_user.png"),fit: BoxFit.cover,color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,height: 32,width: 32,),
                                  Text(
                                    "Create an Account",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Image(image: AssetImage("assets/Icons/add_user.png"),fit: BoxFit.cover,color: Colors.white.withOpacity(0),height: 32,width: 32,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                FadeTransition(
                  opacity: loginAnimation,
                  child: Container(
                    width: _media != null
                        ? _media.size.width
                        : MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        left: 50.0, right: 50.0, top: 10.0),
                    alignment: Alignment.center,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                         Expanded(
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               primary:  Colors.black12,
                               padding: EdgeInsets.zero,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(15.0),
                                 side: BorderSide(color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,width: 5)
                               ),
                             ),
                             onPressed: saveMsg != "URL SAVED!"
                                 ? null
                                 : () async {
                                     if (_formKey.currentState.validate()) {
                                       _formKey.currentState.save();
                                       Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                               builder: (context) =>
                                                   LoginPage()));
                                     }
                                   },
                             child: Container(
                               padding: const EdgeInsets.symmetric(
                                 vertical: 20.0,
                                 horizontal: 20.0,
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: <Widget>[
                                   Icon(Icons.login,color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,size: 26,),
                                    Text(
                                      "Login",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        //color: UIData.quitoThemeColor,
                                        color: saveMsg!= "URL SAVED!"?Colors.grey: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        //fontWeight: FontWeight.bold
                                      ),
                                    ),
                                   Icon(Icons.email_outlined ,color: Colors.white.withOpacity(0),size: 26), //adding icon for symmetry
                                 ],
                               ),
                             ),
                           ),
                         ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(UIData.cloud1), fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: mainScreen(),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    controller.dispose();
    helloController.dispose();
    createController.dispose();
    loginController.dispose();
    super.dispose();
  }
}
