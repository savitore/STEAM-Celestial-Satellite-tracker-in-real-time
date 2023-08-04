import 'package:flutter/material.dart';

import '../utils/colors.dart';

class Help extends StatelessWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 20, 20),
                      child: Text('Help Page',overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40)),
                    ),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
