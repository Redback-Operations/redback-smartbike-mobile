import 'package:flutter/material.dart';
import 'package:phone_app/components/bottom_button.dart';
import 'package:phone_app/utilities/constants.dart';
import '../components/main_app_background.dart';
import 'contact.dart';
import 'home_page.dart';

class InformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'About Us',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text(
                "Redback Operation Mission",
                style: kSubSubTitleOfPage,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Redback Operations aims to turn small steps of virtuality into bigger steps of reality, making you Smarter, Fitter, and Better. Bad weather? Too much traffic? Worry not, our Smart Bike Project not only transforms your indoor cycling experience but also features an interactive VR Game and accessible Mobile App to bring the world to you.",
                style: kSimpleTextWhite,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius:
                      BorderRadius.circular(12), // Add rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Latest News", style: kSimpleTextPurple),
                    SizedBox(height: 8),
                    Text(
                      "Here are all the news from the team",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              BottomButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUsScreen(),
                    ),
                  );
                },
                buttonText: "Contact Us",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
