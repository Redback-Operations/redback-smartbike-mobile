import 'package:flutter/material.dart';
import 'package:phone_app/utilities/constants.dart';
import 'package:provider/provider.dart';

import '../components/bottom_button.dart';
import '../components/main_app_background.dart';
import '../models/user_details.dart';
import '../provider/user_data_provider.dart';

// TODO: figure out what possibly can we use this section for. I was here originally, but I deleted
// TODO: its navigation path from Settings as it did not offer enough functionality
// TODO: since you cannot upload email or username once the account is created, you can offer to add a backup email
// TODO: for MFA or sth

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  List<String> registeredEmails = [];
  @override
  void initState() {
    super.initState();
    // get current user data (we need email)
    UserDetails? userDetails =
        Provider.of<UserDataProvider>(context, listen: false).userDetails;
    String userEmail = userDetails!.email.toString();

    // only add id the list doesn't have it yet
    if (!registeredEmails.contains(userEmail)) {
      registeredEmails.add(userEmail);
    }
  }

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
          'Registered emails',
          style: kSubSubTitleOfPage,
        ),
        centerTitle: true,
      ),
      body: CustomGradientContainerSoft(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: registeredEmails.map((email) {
                    return ListTile(
                      title: Text(
                        email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            BottomButton(
                onTap: () {
                  _showAddEmailDialog(context);
                },
                buttonText: 'Add Email'),
          ],
        ),
      ),
    );
  }

  void _showAddEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final emailController = TextEditingController();
        return AlertDialog(
          //TODO: check the logic with backend

          title: Text('Add Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Enter Email'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newEmail = emailController.text;
                if (newEmail.isNotEmpty) {
                  setState(() {
                    registeredEmails.add(newEmail);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save Email'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmailScreen(),
  ));
}
