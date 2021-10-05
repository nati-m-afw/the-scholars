import 'package:client/application/bloc_observer.dart';
import 'package:client/injectable.dart';
import 'package:client/presentation/core/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

Future main() async {
  // Bloc.observer = SimpleBlocObserver();
  await dotenv.load(fileName: "../.env");
  configureInjection(Environment.prod);
  runApp(AppWidget());
}
