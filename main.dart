import 'package:flutter/material.dart';
import 'package:weather_app/home_page.dart';
import 'package:weather_app/themes.dart';
// import 'package:weather_app/weather_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}


//   void updateTheme() {
//     // Call build() to trigger a rebuild when the theme changes
//     runApp(MyApp());


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: HomePage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      themeMode: Provider.of<ThemeProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }
}
