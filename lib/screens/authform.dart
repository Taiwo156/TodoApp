import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username ='';
  bool _isLogin = true;


startauthentication() async {
  final isvalid = _formKey.currentState!.validate();
  FocusScope.of(context).unfocus(); // to close the keyboard

  if(isvalid) {
    _formKey.currentState!.save();
    submitform(_email, _password, _username);
  }
}

  submitform(String email, String password, String username) async{
    final auth = FirebaseAuth.instance;
    UserCredential authResult;

    try{
      if(_isLogin) {
        authResult = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      } else {
        authResult = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
        String uid = authResult.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': username,
          'email': email,
        });
      }
    }
    catch(err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: <Widget> [
          SizedBox(
            height: 100.0
            ),
          Padding(padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey, 
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
                keyboardType: TextInputType.emailAddress,
                key: ValueKey('email'),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  //icon: Icon(Icons.email),
                  hintText: 'Enter your email',
                  labelStyle: GoogleFonts.roboto(),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)
                    ),
                  ),
                ),
              ),

              if(!_isLogin)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: TextFormField(
                  
                  onSaved: (value) {
                    _username = value!;
                  },
                  keyboardType: TextInputType.text,
                  key: ValueKey('username'),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    //icon: Icon(Icons.person),
                    hintText: 'Enter your username',
                    labelStyle: GoogleFonts.roboto(),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.0),

              TextFormField(
                obscureText: true,
                validator: (value) {
                  if(value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
                keyboardType: TextInputType.visiblePassword,
                key: ValueKey('password'),
                decoration: InputDecoration(
                  labelText: 'Password',
                  //icon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                  labelStyle: GoogleFonts.roboto(),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.0,),

              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    startauthentication();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,            // enabled background
                    foregroundColor: Colors.white,           // text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    textStyle: GoogleFonts.roboto(fontSize: 18.0),
                  ),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ),
              SizedBox(height: 10.0,),
              Container(
                child: TextButton(onPressed: () { 
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                 },
                child: Text(
                  _isLogin ? 'Create an account' : 'I already have an account'),
                  ),
              )
            ]
          ))
          ),
        ]
      ),
    );
  }
}