import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

class About extends StatelessWidget {
  About({super.key});


  final _mentors = [
    'Andreu Ibáñez Perales',
    'Otávio J. França Oliveira'
  ];

  /// Property that defines the author email.
  final _authorEmail = 'krishna.agrawal@icloud.com';

  /// Property that defines the author GitHub profile name.
  final _authorGitHub = 'savitore';

  /// Property that defines the author LinkedIn profile name.
  final _authorLinkedIn = 'krishnaagr';

  /// Property that defines the organization Instagram.
  final _orgInstagram = '_liquidgalaxy';

  /// Property that defines the organization Twitter.
  final _orgTwitter = '_liquidgalaxy';

  /// Property that defines the organization GitHub profile name.
  final _orgGitHub = 'LiquidGalaxyLAB';

  /// Property that defines the organization LinkedIn profile name.
  final _orgLinkedIn = 'google-summer-of-code---liquid-galaxy-project';

  /// Property that defines the organization website URL.
  final _orgWebsite = 'www.liquidgalaxy.eu';

  /// Opens the email app with the given [email] in it.
  void _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the [account]'s GitHub profile.
  void _openGitHub(String account) async {
    final Uri ghLaunchUri = Uri.https('github.com', '/$account');

    if (await canLaunchUrl(ghLaunchUri)) {
      await launchUrl(ghLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the [account]'s LinkedIn profile.
  void _openLinkedIn(String account) async {
    final Uri liLaunchUri = Uri.https('linkedin.com', '/$account');

    if (await canLaunchUrl(liLaunchUri)) {
      await launchUrl(liLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the [account]'s Instagram profile.
  void _openInstagram(String account) async {
    final Uri liLaunchUri = Uri.https('instagram.com', '/$account');

    if (await canLaunchUrl(liLaunchUri)) {
      await launchUrl(liLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the [account]'s Twitter profile.
  void _openTwitter(String account) async {
    final Uri liLaunchUri = Uri.https('twitter.com', '/$account');

    if (await canLaunchUrl(liLaunchUri)) {
      await launchUrl(liLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the given [link].
  void _openLink(String link) async {
    final Uri liLaunchUri = Uri.parse(link);

    if (await canLaunchUrl(liLaunchUri)) {
      await launchUrl(liLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ThemeColors.backgroundCardColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,color: ThemeColors.textPrimary,),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'STEAM Celestial Satellite tracker in real time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 600,
                      alignment: Alignment.center,
                      child: const Image(
                          image: AssetImage('assets/logo.png')),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'Author - ',
                            style: TextStyle(
                              color: ThemeColors.primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'Krishna Agrawal',
                                style: TextStyle(
                                  color: ThemeColors.textPrimary,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ]
                        )
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            Icons.mail_rounded,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip: _authorEmail,
                          onPressed: () {
                            _sendEmail(_authorEmail);
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          splashRadius: 24,
                          icon: const Icon(
                            SimpleIcons.github,
                            color: Colors.black,
                          ),
                          tooltip: _authorGitHub,
                          onPressed: () {
                            _openGitHub(_authorGitHub);
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            SimpleIcons.linkedin,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip: _authorLinkedIn,
                          onPressed: () {
                            _openLinkedIn('in/$_authorLinkedIn');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Mentors - ',
                          style: TextStyle(
                            color: ThemeColors.primaryColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '${_mentors[1]}, ${_mentors[0]}',
                              style: TextStyle(
                                color: ThemeColors.textPrimary,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ]
                        )
                    ),
                    const SizedBox(height: 32),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'Organization - ',
                            style: TextStyle(
                              color: ThemeColors.primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'Liquid Galaxy project',
                                style: TextStyle(
                                  color: ThemeColors.textPrimary,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ]
                        )
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            SimpleIcons.instagram,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip: '@$_orgInstagram',
                          onPressed: () {
                            _openInstagram(_orgInstagram);
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            SimpleIcons.twitter,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip: '@$_orgTwitter',
                          onPressed: () {
                            _openTwitter(_orgTwitter);
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          splashRadius: 24,
                          icon: const Icon(
                            SimpleIcons.github,
                            color: Colors.black,
                          ),
                          tooltip: _orgGitHub,
                          onPressed: () {
                            _openGitHub(_orgGitHub);
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            SimpleIcons.linkedin,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip:
                          'Liquid Galaxy Project (Google Summer of Code)',
                          onPressed: () {
                            _openLinkedIn('company/$_orgLinkedIn');
                          },
                        ),
                        IconButton(
                          iconSize: 30,
                          icon: const Icon(
                            Icons.language_rounded,
                            color: Colors.black,
                          ),
                          splashRadius: 24,
                          tooltip: _orgWebsite,
                          onPressed: () {
                            _openLink('https://$_orgWebsite');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: double.infinity,
                      child: Image(image: AssetImage('assets/aLogo.png')),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Project description',
                      style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDescriptionParagraph(
                              '◼️  This project represents the orbit of a satellite orbiting earth on a Liquid Galaxy rig and an Arduino-controlled pointer through a mobile application.'),
                          const SizedBox(height: 10,),
                          _buildDescriptionParagraph('◼️  To view the direction of satellite on a 3D model, upload the code from my GitHub to Arduino and connect components as mentioned.'),
                          const SizedBox(height: 10,),
                          _buildDescriptionParagraph(
                              '◼️  The data is visible into the Google Earth (running on the Liquid Galaxy rig) as placemarks, polygons, balloons and more.'),
                          const SizedBox(height: 10,),
                          _buildDescriptionParagraph(
                              '◼️  It\'s possible to search, filter and sort satellites, synchronize the data between the application and the database, run some of the Liquid Galaxy system commands/tasks, check the orbit of satellites, play orbit tours and more.'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
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
        fontWeight: FontWeight.normal,
      ),
      overflow: TextOverflow.visible,
    );
  }
  }

