import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  /// Property that defines the project GitHub.
  final _projectGitHub = 'https://github.com/savitore/STEAM-Celestial-Satellite-tracker-in-real-time';

  /// Property that defines the instruction manual.
  final _instructionManual = 'https://docs.google.com/document/d/1NfXiyhhtKBtD2GL_H1Qew8CYwpoZ0U3u9v3ifMiTAcE/edit';

  /// Property that defines the ATCommands
  final _atCommands = 'https://www.instructables.com/AT-command-mode-of-HC-05-Bluetooth-module/';

  void _openLink(String link) async {
    final Uri liLaunchUri = Uri.parse(link);

    if (await canLaunchUrl(liLaunchUri)) {
      await launchUrl(liLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  final ScrollController _scrollController = ScrollController();
  bool _showTextInAppBar = false;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 60) {
      setState(() {
        _showTextInAppBar = true;
      });
    } else {
      setState(() {
        _showTextInAppBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ThemeColors.backgroundCardColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeColors.textPrimary,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,color: ThemeColors.textPrimary,),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: _showTextInAppBar ? const Text('Help Page',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)) : const Text(''),
        bottom: _showTextInAppBar ? PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1,
          ),
        ) : null,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Help Page',
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.textPrimary,
                              fontSize: 40
                          )
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width > 600 ? 600 : width*0.9,
                            alignment: Alignment.center,
                            child: const Image(
                                image: AssetImage('assets/logo.png')),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions for Setting up the Visualization:',
                              style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                                text: TextSpan(
                                    text: '◼️  Please go to this project \'s ',
                                    style: TextStyle(
                                      color: ThemeColors.textPrimary,
                                      fontSize: 20,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: 'GitHub',
                                          style: TextStyle(
                                              color: ThemeColors.secondaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = (){
                                              _openLink(_projectGitHub);
                                            }
                                      ),
                                      TextSpan(
                                        text: ' to know how to set up the Liquid Galaxy rig.',
                                        style: TextStyle(
                                          color: ThemeColors.textPrimary,
                                          fontSize: 20,
                                        ),
                                      )
                                    ]
                                )
                            ),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  After the setup is complete, go to the LG connection in Settings page, and fill in the credentials to connect to LG rig.'),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  Then, go to the home screen and tap on the satellite you want to visualize. You will be navigated to the Satellite Information screen, which contains all the information about that satellite. If TLE Information is available, you will see a "View in LG" button. Hit that button. You will be able to see the satellite\'s orbit in the LG rig. You will see something like this:'),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: width > 600 ? 600 : width/2,
                                  alignment: Alignment.center,
                                  child: const Image(
                                      image: AssetImage('assets/help1.png')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildDescriptionParagraph('◼️  Click on the "Orbit" button to go on an Orbit tour in the LG rig. The balloon can be hidden by using the "Balloon visibility" switch. The orbit period can be changed by using the "Orbit period" slider. You can also go on a Simulation tour by clicking on the "Simulate" button.'),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  Go to the Settings page and click on "LG tools" to perform some LG commands.'),
                            const SizedBox(height: 40),
                            Text(
                              'Instructions for Setting up Arduino-controlled pointer:',
                              style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                                text: TextSpan(
                                    text: '◼️  Please go to the ',
                                    style: TextStyle(
                                      color: ThemeColors.textPrimary,
                                      fontSize: 20,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: 'Instruction Manual',
                                          style: TextStyle(
                                              color: ThemeColors.secondaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = (){
                                              _openLink(_instructionManual);
                                            }
                                      ),
                                      TextSpan(
                                        text: ' to know how to set up the Arduino-controlled pointer.',
                                        style: TextStyle(
                                          color: ThemeColors.textPrimary,
                                          fontSize: 20,
                                        ),
                                      )
                                    ]
                                )
                            ),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  After the setup is complete, select a satellite from the home screen and go to the Satellite Information screen. If the satellite is in range, you will see a "View in 3D" button. Hit that button. You will see something like this:'),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: width > 500 ? 400 : width/2,
                                  alignment: Alignment.center,
                                  child: const Image(
                                      image: AssetImage('assets/help2.jpg')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildDescriptionParagraph('◼️  Select your HC-05 device from the list of paired devices. Hit the "Connect" button to connect to the Bluetooth device.'),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  Calibrate your Arduino-controlled pointer to 0°N by going to the Compass Screen, when you click on "Open Compass".'),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: width > 500 ? 400 : width/2,
                                  alignment: Alignment.center,
                                  child: const Image(
                                      image: AssetImage('assets/help3.jpg')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildDescriptionParagraph('◼️  Click on "View in 3D" button. You can now see the direction of the satellite from the Arduino-controlled pointer. You can also see the servo angles by clicking on "SHOW ANGLES" button.'),
                            const SizedBox(height: 40),
                            Text(
                              'Troubleshooting:',
                              style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDescriptionParagraph('◼️  If you are unable to connect to the LG rig, make sure that the application and the LG rig are both on the same network. Also, make sure that the credentials that you enter in the LG Connection screen are correct.'),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  The Arduino-controlled pointer feature is targeted for Android versions till Android 11. Any Android version greater than 11 is incompatible to work the Arduino-controlled pointer.'),
                            const SizedBox(height: 10),
                            _buildDescriptionParagraph('◼️  While using the pointer, make sure that all the components are correctly connected as required.'),
                            const SizedBox(height: 10),
                            RichText(
                                text: TextSpan(
                                    text: '◼️  If after sending data to the Arduino board, you are unable to see the satellite\'s direction, it is possible that your HC-05 device is not working properly. Perform ',
                                    style: TextStyle(
                                      color: ThemeColors.textPrimary,
                                      fontSize: 20,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: 'AT Commands',
                                          style: TextStyle(
                                              color: ThemeColors.secondaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = (){
                                              _openLink(_atCommands);
                                            }
                                      ),
                                      TextSpan(
                                        text: ' and check if the device responds. If it doesn\'t, replace the device and try again.',
                                        style: TextStyle(
                                          color: ThemeColors.textPrimary,
                                          fontSize: 20,
                                        ),
                                      )
                                    ]
                                )
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'Credits:',
                              style: TextStyle(
                                color: ThemeColors.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDescriptionParagraph('◼️  This app has been developed thanks to mentor, Otávio J. França Oliveira, organization admin, Andreu Ibáñez Perales, Liquid Galaxy LAB testers: Mohamed Zazou, Navdeep Singh and Imad Laichi, SatNOGS project author, Michell Algarra and Sayed Nowroz, who inspired the Arduino-controlled pointer.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  /// Builds a [Widget] that will be used to render a paragraph according to the
  /// given [text].
  Widget _buildDescriptionParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        color: ThemeColors.textPrimary,
        fontSize: 20,
      ),
      overflow: TextOverflow.visible,
    );
  }
}
