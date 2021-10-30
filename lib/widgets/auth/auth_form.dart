import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pickers/user_image_picker.dart';
import 'dart:io';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitFn, this.isLoading, {Key? key}) : super(key: key);
  final bool isLoading;
  final void Function(
    String email,
    String userName,
    String password,
    File? image,
    bool isLogin,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;

  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  File? _userImage;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideImageAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideImageAnimation = Tween<Offset>(
            begin: const Offset(-1, 0), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _pickedImage(File image) {
    _userImage = image;
  }

  void _trySubmit() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();
    if (_userImage == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please pick an image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _userImage,
        _isLogin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var _userNameFocusNode = FocusNode();
    var _passwordFocusNode = FocusNode();
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLogin)
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linearToEaseOut,
                        child: FadeTransition(
                            opacity: _opacityAnimation,
                            child: SlideTransition(
                                position: _slideImageAnimation,
                                child: UserImagePicker(_pickedImage)))),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    key: const Key('email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    onFieldSubmitted: (value) {
                      if (_isLogin) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      } else {
                        FocusScope.of(context).requestFocus(_userNameFocusNode);
                      }
                    },
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _userEmail = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: decorationStyle(
                        'Email Address', const Icon(Icons.mail_rounded)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (!_isLogin)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linearToEaseOut,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TextFormField(
                            key: const Key('username'),
                            enableSuggestions: false,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.words,
                            focusNode: _userNameFocusNode,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _userName = value.toString();
                            },
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return 'Please enter at least 4 characters';
                              }
                              return null;
                            },
                            decoration: decorationStyle(
                                'User Name', const Icon(Icons.person_rounded)),
                          ),
                        ),
                      ),
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 15,
                    ),
                  TextFormField(
                    key: const Key('password'),
                    focusNode: _passwordFocusNode,
                    onFieldSubmitted: (value) {
                      _trySubmit();
                    },
                    onSaved: (value) {
                      _userPassword = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long';
                      }
                      return null;
                    },
                    decoration: decorationStyle(
                        'Password', const Icon(Icons.lock_open_rounded)),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  if (widget.isLoading)
                    CircularProgressIndicator(
                      color: Colors.deepPurple.withOpacity(.8),
                    ),
                  if (!widget.isLoading)
                    ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text(_isLogin ? 'LogIn' : 'Signup'),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(170, 36),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            primary: Colors.deepPurple.withOpacity(.8))),
                  if (!widget.isLoading)
                    TextButton(
                      onPressed: () {
                        if (_isLogin) {
                          _controller.forward();
                        } else {
                          _controller.reverse();
                        }
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'already have an account'),
                      style: TextButton.styleFrom(
                          primary: const Color.fromRGBO(91, 32, 71, 1)
                              .withOpacity(.9)),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration decorationStyle(
  String textField,
  Icon icons1,
) {
  return InputDecoration(
    focusedBorder: OutlineInputBorder(
      gapPadding: 1.0,
      borderSide: BorderSide(color: Colors.deepPurple.shade800),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      gapPadding: 1.0,
      borderSide: BorderSide(color: Colors.deepPurple.shade300),
      borderRadius: BorderRadius.circular(25),
    ),
    labelText: textField,
    labelStyle: TextStyle(
      fontSize: 18.0,
      color: const Color.fromRGBO(102, 68, 130, 1).withOpacity(0.7),
    ),
    icon: icons1,
    border: OutlineInputBorder(
      gapPadding: 1.0,
      borderRadius: BorderRadius.circular(25),
    ),
  );
}
