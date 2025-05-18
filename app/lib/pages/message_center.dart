import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/components/input_text_field.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';
import '../components/bottom_navigation_bar.dart';
import '../components/dropdown_choice.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'home_page.dart';

class MessageCenter extends StatefulWidget {
  const MessageCenter({super.key});

  @override
  _MessageCenterState createState() => _MessageCenterState();
}

class _MessageCenterState extends State<MessageCenter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
          title: Text(
            'My Messages',
            style: kSubSubTitleOfPage,
          ),
          centerTitle: true,
        ),
        body: CustomGradientContainerSoft(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 30.0, 0),
                    child: const Center(
                        //TODO:  add stuff here
                        ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
