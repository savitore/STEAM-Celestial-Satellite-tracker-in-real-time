import 'package:flutter/material.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundCardColor, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ThemeColors.textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "FAQs Section",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            FAQItem(
                      question: 'How does the STEAM Celestial Satellite Tracker work?',
                      answer: 'The STEAM Celestial Satellite Tracker utilizes an Arduino-controlled pointer and Liquid Galaxy rig to visualize satellite orbits. The app provides real-time information about satellite movements and offers a unique way to interact with the satellite data.',
                    ),
                    FAQItem(
                      question: ' What satellite information does the app provide?',
                      answer: 'The app offers detailed information about various satellites, including their orbits, trajectories, and other relevant data. Explore a variety of satellites and learn more about their celestial movements.'
                     ),
                    FAQItem(
                      question: ' Is the app compatible with all Android devices?',
                      answer: 'The app is compatible with Android devices up to Android 11. Please note that the Arduino-controlled pointer functionality is specifically designed for Android devices.',
                    ),
                    FAQItem(
                      question: 'What Bluetooth module is compatible with the STEAM Celestial Satellite Tracker?',
                      answer: 'The HC-05 Bluetooth module is used for communication between the app and the Arduino-controlled pointer. Ensure your Bluetooth module is HC-05 for seamless connectivity.',
                    ),
                    FAQItem(
                      question: 'Can I use any Arduino board for the pointer setup?',
                      answer: 'The current implementation uses an Arduino UNO board. While other boards may work, it is recommended to stick with Arduino UNO for compatibility.',
                    ),
                    FAQItem(
                      question: 'How do I connect the app to Liquid Galaxy for satellite visualization?',
                      answer: 'Open the app and navigate to the Settings page by clicking on the gear icon. Choose the "LG Connection" option and enter the Liquid Galaxy host name, password, IP address, SSH connection port, and the number of screens. Click "Connect" to establish a connection.',
                    ),
                    FAQItem(
                      question:  'How can I contribute to the development of the app?',
                      answer: 'We welcome contributions! Feel free to report issues, bugs, or submit feature requests through our issue tracker. If you are interested in contributing code, you can submit a pull request.'
                      ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), 
        side: BorderSide(
          color: Colors.red, 
          width: 0.5, 
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}