import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../provider/user_data_provider.dart';

class UserDetailsFetcher {
  static Future<void> fetchUserDetails(
      BuildContext context, String email) async {
    // Load the .env file
    await dotenv.load(fileName: ".env");

    // Retrieve the base URL from the environment variables
    String? baseURL = dotenv.env['API_URL_BASE'];

    // Check if the base URL is defined
    if (baseURL != null) {
      // Construct the complete URL by concatenating with the endpoint
      String apiUrl = '$baseURL/update/$email/';

      try {
        // Send the GET request
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        // Handle the response
        if (response.statusCode == 200) {
          // Parse the response JSON
          final responseData = jsonDecode(response.body);

          // Fetch and update the image
          String? imagePath = responseData['image'];

          if (imagePath != null && imagePath.isNotEmpty) {
            // Add the base URL of your Django server to the image path
            String imageUrl = '$baseURL$imagePath';

            // Download the image
            var response = await http.get(Uri.parse(imageUrl));
            if (response.statusCode == 200) {
              // Save the image to a temporary file
              String fileName = imageUrl.split('/').last;

              final tempDir = await getTemporaryDirectory();

              final file = File('${tempDir.path}/$fileName');
              await file.writeAsBytes(response.bodyBytes);
            }
            if (response.statusCode == 404) {
              imagePath = '/media/images/default.jpeg';
            }
            print('image path: $imageUrl');
          } else {
            // Assign default image path if imagePath is null or empty
            imagePath = '/media/images/default.jpeg';
          }

          // Print or process the user details
          print('User details: $responseData');

          // set values in provider
          Provider.of<UserDataProvider>(context, listen: false)
              .updateUserDetails(
            context,
            id: responseData['id'] ?? '',
            name: responseData['name'] ?? '',
            surname: responseData['surname'] ?? '',
            username: responseData['username'] ?? '',
            email: responseData['email'] ?? '',
            dob: (responseData['dob'] ?? ''),
            phoneNumber: responseData['phone_number'] ?? '',
            imagePath: imagePath ?? '',
            // Add constructor parameters for additional fields
          );
        } else {
          // Handle errors here
          print('Failed to get user details: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network errors here
        print('Error: $e');
      }
    } else {
      // Print a message if BASE_URL is not defined in .env
      print('BASE_URL is not defined in .env file');
    }
  }
}
