import 'package:another_flushbar/flushbar_helper.dart';
import 'package:client/application/auth/auth_bloc.dart';
import 'package:client/application/auth/sign_in_form/sign_in_form_bloc.dart';
//import 'package:dartz/dartz_streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hexcolor/hexcolor.dart';

class SignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccess.fold(
            () {},
            (either) => either.fold((failure) {
                  FlushbarHelper.createError(
                      message: failure.map(
                    invalidEmailPasswordCombination: (_) =>
                        "Invalid email or password",
                    emailAlreadyInUse: (_) => "Email already in use",
                    networkError: (_) => "Check network connection",
                    serverError: (_) => "Invalid error",
                    cancelledByUser: (_) => "Cancelled",
                  )).show(context);
                }, (r) {
                  BlocProvider.of<AuthBloc>(context)
                      .add(const AuthEvent.authCheckRequested());
                }));
      },
      builder: (context, state) {
        return Scaffold(
          // backgroundColor: Colors.grey,
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: const [
                  -0.5,
                  1.5
                ],
                    colors: [
                  // HexColor("264653"),
                  HexColor("2A9D8F"),
                  HexColor("E9C46A"),
                  // HexColor("F4A261"),
                  // HexColor("E76F51")
                ])),
            child: LayoutBuilder(
              builder: (ctx, constraints) => Padding(
                padding: const EdgeInsets.all(60.0),
                child: GlassmorphicContainer(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  blur: 50,
                  border: 5,
                  borderRadius: 20,
                  borderGradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      stops: const [
                        -0.5,
                        1.5
                      ],
                      colors: [
                        // HexColor("264653"),
                        HexColor("2A9D8F").withOpacity(0.7),
                        HexColor("E9C46A").withOpacity(0.7),
                        // HexColor("F4A261"),
                        // HexColor("E76F51")
                      ]),
                  linearGradient: LinearGradient(colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black12.withOpacity(0.3)
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 20, left: 10, bottom: 90),
                          child: Center(
                            child: Text("DTU Scholars",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0)),
                          ),
                        ),
                        Form(
                            autovalidateMode: state.showErrorMessages
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // * Email Field
                                SizedBox(
                                  height: 75,
                                  child: TextFormField(
                                    key: const ValueKey("loginPageUserName"),
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    cursorColor: HexColor("E76F51"),
                                    decoration: const InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 10),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                      ),
                                      focusedErrorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 10),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                      ),
                                      focusColor: Color.fromRGBO(231, 111, 81, 1),
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(34, 36, 37, 0.9),
                                      prefixIcon: Icon(Icons.email, color: Color.fromRGBO(160, 165, 167, 1),),
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(160, 165, 167, 1)),
                                    ),
                                    autocorrect: false,
                                    onChanged: (value) =>
                                        BlocProvider.of<SignInFormBloc>(context)
                                            .add(SignInFormEvent.emailChanged(
                                                value)),
                                    validator: (_) =>
                                        BlocProvider.of<SignInFormBloc>(context)
                                            .state
                                            .emailAddress
                                            .value
                                            .fold(
                                                (failure) => failure.maybeMap(
                                                    invalidEmail: (_) =>
                                                        "Invalid Email",
                                                    orElse: () => null),
                                                (_) => null),
                                  ),
                                ),
                                // * Email Field

                                const SizedBox(height: 15), // * Spacer

                                // * Password Field
                                SizedBox(
                                  height: 75,
                                  child: TextFormField(
                                    key: const ValueKey("loginPagePassword"),
                                    keyboardType: TextInputType.visiblePassword,
                                    style: const TextStyle(color: Colors.white),
                                    cursorColor: HexColor("E76F51"),
                                    decoration: const InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 10),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                      ),
                                      focusedErrorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 10),
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                      ),
                                      focusColor: Color.fromRGBO(231, 111, 81, 1),
                                      filled: true,
                                      fillColor:
                                          Color.fromRGBO(34, 36, 37, 0.9),
                                      prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(160, 165, 167, 1),),
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(160, 165, 167, 1)),
                                    ),
                                    autocorrect: false,
                                    obscureText: true,
                                    onChanged: (value) =>
                                        BlocProvider.of<SignInFormBloc>(context)
                                            .add(
                                                SignInFormEvent.passwordChanged(
                                                    value)),
                                    validator: (_) =>
                                        BlocProvider.of<SignInFormBloc>(context)
                                            .state
                                            .password
                                            .value
                                            .fold(
                                                (failure) => failure.maybeMap(
                                                    invalidPassword: (_) =>
                                                        "Invalid Password",
                                                    orElse: () => null),
                                                (_) => null),
                                  ),
                                ),
                                // * Password Field

                                const SizedBox(height: 15), // * Spacer

                                // * Sign In Btn
                                SizedBox(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        key: const ValueKey(
                                            "loginPageLoginButton"),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () {
                                                BlocProvider.of<SignInFormBloc>(
                                                        context)
                                                    .add(const SignInFormEvent
                                                        .signInPressed());
                                              },
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors
                                                .grey, //background color of button
                                            side: const BorderSide(
                                                width: 3,
                                                color: Colors
                                                    .grey), //border width and color
                                            elevation: 3, //elevation of button
                                            shape: RoundedRectangleBorder(
                                                //to set border radius to button
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            padding: const EdgeInsets.all(
                                                10) //content padding inside button
                                            ),
                                        child: const Text("Log in",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight:
                                                    FontWeight.normal)))),
                                // * Sign In Btn

                                const SizedBox(height: 15), // * Spacer

                                // * Register Btn
                                SizedBox(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.grey[
                                            800], //background color of button
                                        side: const BorderSide(
                                            width: 2,
                                            color: Colors
                                                .grey), //border width and color
                                        elevation: 3, //elevation of button
                                        shape: RoundedRectangleBorder(
                                            //to set border radius to button
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        padding: const EdgeInsets.all(
                                            10) //content padding inside button
                                        ),
                                    key: const ValueKey(
                                        "loginPageRegisterButton"),
                                    onPressed: () {
                                      Navigator.popAndPushNamed(
                                          context, '/register');
                                    },
                                    child: const Text("Sign up",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal)),
                                  ),
                                ),
                                // * Register Btn
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
