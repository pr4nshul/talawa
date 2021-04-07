//flutter packages are called here
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

// pages are called here
import 'package:provider/provider.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/view_models/vm_register.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/model/token.dart';
import 'package:talawa/views/pages/organization/join_organization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphql/utilities.dart' show multipartFileFrom;

//pubspec packages are called here
import 'package:image_picker/image_picker.dart';
import '../_pages.dart';

class RegisterForm extends StatefulWidget {
  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _originalPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();
  FocusNode confirmPassField = FocusNode();
  RegisterViewModel model = new RegisterViewModel();
  bool _progressBarState = false;
  Queries _signupQuery = Queries();
  var _validate = AutovalidateMode.disabled;
  Preferences _pref = Preferences();
  FToast fToast;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  File _image;
  bool _obscureText = true;

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    Provider.of<GraphQLConfiguration>(context, listen: false).getOrgUrl();
  }

  //function for registering user which gets called when sign up is press
  registerUser() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    final img = await multipartFileFrom(_image);
    print(_image);
    QueryResult result = await _client.mutate(MutationOptions(
      documentNode: gql(_signupQuery.registerUser(
          model.firstName, model.lastName, model.email, model.password)),
      variables: {
        'file': img,
      },
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _errorScaffold(result.hasException.toString().substring(16, 35));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);

      final Token accessToken =
          new Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);
      //Navigate user to join organization screen
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>JoinOrganization(fromProfile: false,)), (route) => false);
    }
  }

  //function called when the user is called without the image
  registerUserWithoutImg() async {
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(MutationOptions(
      documentNode: gql(_signupQuery.registerUserWithoutImg(
          model.firstName, model.lastName, model.email, model.password)),
    ));
    if (result.hasException) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _errorScaffold(result.exception.toString().substring(16, 35));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });

      final String userFName = result.data['signUp']['user']['firstName'];
      await _pref.saveUserFName(userFName);
      final String userLName = result.data['signUp']['user']['lastName'];
      await _pref.saveUserLName(userLName);
      final Token accessToken =
          new Token(tokenString: result.data['signUp']['accessToken']);
      await _pref.saveToken(accessToken);
      final Token refreshToken =
          new Token(tokenString: result.data['signUp']['refreshToken']);
      await _pref.saveRefreshToken(refreshToken);
      final String currentUserId = result.data['signUp']['user']['_id'];
      await _pref.saveUserId(currentUserId);

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>JoinOrganization(fromProfile: false,)), (route) => false);
    }
  }

  //get image using camera
  _imgFromCamera() async {
    final pickImage = await ImagePicker().getImage(source: ImageSource.camera);
    File image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  //get image using gallery
  _imgFromGallery() async {
    final pickImage = await ImagePicker().getImage(source: ImageSource.gallery);
    File image = File(pickImage.path);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
            key: _formKey,
            autovalidateMode: _validate,
            child: Column(
              children: <Widget>[
                addImage(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Add Profile Image',
                      style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.w400,fontStyle: FontStyle.italic)),
                ),
                SizedBox(
                  height: 25,
                ),
                AutofillGroup(
                  child: Column(
                    children: <Widget>[
                      // TextFormField(
                      //   autofillHints: <String>[AutofillHints.givenName],
                      //   textInputAction: TextInputAction.next,
                      //   textCapitalization: TextCapitalization.words,
                      //   controller: _firstNameController,
                      //   validator: (value) =>
                      //       Validator.validateFirstName(value),
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(color: Colors.white),
                      //   decoration: InputDecoration(
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.white,width: 5),
                      //       borderRadius: BorderRadius.circular(15.0),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.white,width: 2),
                      //       borderRadius: BorderRadius.circular(20.0),
                      //     ),
                      //     prefixIcon: Icon(Icons.person, color: Colors.white),
                      //     labelText: "First Name",
                      //     labelStyle: TextStyle(color: Colors.white),
                      //     alignLabelWithHint: true,
                      //     hintText: 'Earl',
                      //     hintStyle: TextStyle(color: Colors.grey),
                      //   ),
                      //   onSaved: (value) {
                      //     model.firstName = value;
                      //   },
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.familyName],
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        controller: _userNameController,
                        validator: Validator.validateUserName,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(backgroundColor: Colors.black54,fontSize:14,fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width:2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.person_pin, color: Colors.white),
                          labelText: "User Name",
                          labelStyle: TextStyle(color: Colors.white),
                          alignLabelWithHint: true,
                          hintText: 'John',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSaved: (value) {
                          model.lastName = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validator.validateEmail,
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(backgroundColor: Colors.black54,fontSize:14,fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width:5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          labelText: "Email ID",
                          labelStyle: TextStyle(color: Colors.white),
                          alignLabelWithHint: true,
                          hintText: 'foo@bar.com',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSaved: (value) {
                          model.email = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.password],
                        textInputAction: TextInputAction.next,
                        obscureText: _obscureText,
                        controller: _originalPasswordController,
                        validator: Validator.validatePassword,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(backgroundColor: Colors.black54,fontSize:14,fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                          suffixIcon: TextButton(
                            onPressed: _toggle,
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white),
                          focusColor: UIData.primaryColor,
                          alignLabelWithHint: true,
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                          FocusScope.of(context).requestFocus(confirmPassField);
                        },
                        onChanged: (_) {
                          setState(() {});
                        },
                        onSaved: (value) {
                          model.password = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autofillHints: <String>[AutofillHints.password],
                        obscureText: true,
                        focusNode: confirmPassField,
                        validator: (value) => Validator.validatePasswordConfirm(
                          _originalPasswordController.text,
                          value,
                        ),
                        controller: _confirmPasswordController,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          errorStyle: TextStyle(backgroundColor: Colors.black54,fontSize:14,fontWeight: FontWeight.bold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white,width: 2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.white),
                          focusColor: UIData.primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FlutterPwValidator(
                        width: 400,
                        height: 150,
                        minLength: 8,
                        uppercaseCharCount: 1,
                        specialCharCount: 1,
                        numericCharCount: 1,
                        defaultColor: Colors.white,
                        failureColor: Colors.red,
                        onSuccess: (_) {
                          setState(() {});
                        },
                        controller: _originalPasswordController,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)
                      )
                    ),
                    child: _progressBarState
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                              strokeWidth: 3,
                              backgroundColor: Colors.black,
                            ))
                        : Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      _validate = AutovalidateMode.always;
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        _image != null
                            ? registerUser()
                            : registerUserWithoutImg();
                        setState(() {
                          toggleProgressBarState();
                        });
                      }
                    },
                  ),
                ),
              ],
            )));
  }

  //widget used to add the image
  Widget addImage() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: UIData.secondaryColor,
              child: _image != null
                  ? CircleAvatar(
                      radius: 45,
                      backgroundImage: FileImage(
                        _image,
                      ),
                    )
                  : CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.lightBlue[50],
                      child: Icon(
                        Icons.camera_enhance_rounded,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  //used to show the method user want to choose their pictures
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt_outlined),
                    title: Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }

  /* _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              msg,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );*/

  //this method is called when the result is an exception
  // _exceptionToast(String msg) {
  //   Widget toast = Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(25.0),
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


  //function toggles _obscureText value
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
