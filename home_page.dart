import 'package:flutter/material.dart';
import 'package:weather_app/weather_screen.dart';
import 'package:weather_app/weather_screen_2.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        toolbarHeight: 70,
        elevation: 20,
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20.0),
              ),
           ),
          title: const Text(
            'Weather App',
           style: TextStyle(
             fontWeight: FontWeight.bold,
             fontSize: 30,
            ),
          ),
             centerTitle: true,
      ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/weatherapp.png'),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed:  () {
                        _showPopupMessage(context);
                        // Navigator.push(
                        //   context,
                            //MaterialPageRoute(builder: (context) => WeatherScreenTwo(),),
                  },
                      child: Text('Click here to enter your city manually'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed:  () {
                      _showPopupMessageTwo(context);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => WeatherScreen(),),
                      // );
                    },
                    child: Text('Click here to choose from a list of cities'),
                  ),
                ],
              ),
            ),
          )
    );
  }

  void _showPopupMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text('If you choose this option then, you will be able to access Weather Data of the cities all over the World!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('GO BACK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreenTwo(),),
                );// Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPopupMessageTwo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text('If you choose this option then, you can only access the Weather Data of the cities listed!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('GO BACK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen(),),
                );// Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


}
